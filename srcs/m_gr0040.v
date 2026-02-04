`timescale 1ns / 1ps
// Global widths
`define W    16  // register width
`define N    15  // register MSB
`define AN   15  // address MSB
`define IN   15  // instruction MSB

// Opcode decode
`define JAL     (op==0)
`define ADDI    (op==1)
`define RR      (op==2)
`define RI      (op==3)
`define LW      (op==4)
`define LB      (op==5)
`define SW      (op==6)
`define SB      (op==7)
`define IMM     (op==8)
`define Bx      (op==9)
`define SYS     (op==10) // system instructions
`define CLI     (op==11) // clear interrupts
`define STI     (op==12) // set interrupts
`define NOP     (op==4'hF)
`define ALU     (`RR|`RI)

// Function decode
`define ADD     (fn==0)
`define SUB     (fn==1)
`define AND     (fn==2)
`define XOR     (fn==3)
`define ADC     (fn==4)
`define SBC     (fn==5)
`define CMP     (fn==6)
`define SRL     (fn==7)
`define SRA     (fn==8)
`define GETCC   (fn==9) // get condition codes
`define SETCC   (fn==10) // set condition codes
`define SUM     (`ADD|`SUB|`ADC|`SBC)
`define LOG     (`AND|`XOR)
`define SR      (`SRL|`SRA)

// control_unit: decode and control
module control_unit(
  input wire clk,
  input wire rst,
  input wire [`IN:0] insn,
  input wire hit,
  input wire rdy,
  input wire ccz, ccn, ccc, ccv,
  input wire irq_take,
  output reg irq_save, // latches irq_take to save old pc in the link register
  output wire [3:0] op,
  output wire [3:0] rd,
  output wire [3:0] rs,
  output wire [3:0] fn,
  output wire [3:0] imm,
  output wire [11:0] i12,
  output wire [3:0] cond,
  output wire [7:0] disp,
  output wire insn_ce,
  output reg imm_pre,
  output reg [11:0] i12_pre,
  output wire rf_we,
  output wire lw,
  output wire lb,
  output wire sw,
  output wire sb,
  output wire int_en,
  output wire br_taken,
  output wire iret_detected,
  output wire valid_insn_ce,
  output wire exec_ce,
  output wire restore_cc
);

  // Instruction fields
  assign op = insn[15:12];
  assign rd = insn[11:8];
  assign rs = insn[7:4];
  assign fn = `RI ? insn[7:4] : insn[3:0];
  assign imm = insn[3:0];
  assign i12 = insn[11:0];
  assign cond = insn[11:8];
  assign disp = insn[7:0];

  // Load/store strobes
  assign lw = hit & `LW;
  assign lb = hit & `LB;
  assign sw = hit & `SW;
  assign sb = hit & `SB;
  wire mem = hit & (`LB|`LW|`SB|`SW);

  // Instruction clock enable
  assign insn_ce = rst | ~(mem & ~rdy);         // stall on memory access
  assign exec_ce = hit & insn_ce;               // execute on valid instruction (ALU runs, flags are written, load/stores)
  assign valid_insn_ce = exec_ce & ~irq_take;   // valid instruction excluding irq handling (not an interrupt cycle)

  // Immediate prefix tracking
  always @(posedge clk) begin
    if (rst)
      imm_pre <= 0;
    else if (exec_ce)
      imm_pre <= `IMM;
  end
  
  always @(posedge clk) begin
    if (exec_ce)
      i12_pre <= i12;
  end
  
  // Register file write enable
  assign rf_we = hit & insn_ce & ~rst &
  ((`ALU&~`CMP)|`ADDI|`LB|`LW|`JAL);

  // Conditional branch decode
  `define BR      0
  `define BEQ     2
  `define BC      4
  `define BV      6
  `define BLT     8
  `define BLE     'hA
  `define BLTU    'hC
  `define BLEU    'hE

  // Branch predicate
  reg t;
  always @(*) begin
    if (rst) begin
      t  = 0;
    end else begin
      case (cond & 4'b1110)
        `BR:   t = 1;
        `BEQ:  t = ccz;
        `BC:   t = ccc;
        `BV:   t = ccv;
        `BLT:  t = ccn ^ ccv;
        `BLE:  t = (ccn ^ ccv) | ccz;
        `BLTU: t = ~ccz & ~ccc;
        `BLEU: t = ccz | ~ccc;
        default: t = 0;
      endcase
    end
  end

  // Branch taken
  assign br_taken = exec_ce & ~irq_save & (`JAL | (hit & `Bx & (cond[0] ? ~t : t)));

  // Interrupt enable / masking
  wire is_cli = hit & exec_ce & `CLI;
  wire is_sti = hit & exec_ce & `STI;
  
  // Global interrupt enable
  reg gie; 
  wire interlocked_insns = `IMM | `ALU & (`ADC | `SBC | `CMP); 

  always @(posedge clk) begin
      if (rst) gie <= 1'b1;             // might change this later in the startup by explicitly STI at boot, and having 1'b0 here
      else if (irq_take) gie <= 1'b0;   // mask interrupts before saving cpu context, must set them after prologue 
      else if (is_cli) gie <= 1'b0;
      else if (is_sti) gie <= 1'b1; 
  end

  // Interrupt enable signal
  assign int_en = hit & gie & ~interlocked_insns; // gated to avoid multi-cycle immediates

  // IRQ bookkeeping
  always @(posedge clk) irq_save <= irq_take;
  
  // iret detection
  assign iret_detected = hit & (insn == 16'h0EE0); // because iret is JAL r14, r14, #0

  // Condition code restore (SYS)
  assign restore_cc = `SYS & (fn == 4'hA); // SETCC instruction
  
endmodule // control unit


module gr0040(
clk, rst, i_ad_rst,
insn_ce, i_ad, insn, hit, int_en,
d_ad, rdy, sw, sb, lw, lb, 
data_in, data_out, br_taken,
irq_take, irq_vector, iret_detected);

    // Top-level ports
    input  clk;              // clock
    input  rst;              // reset (sync)
    input [`AN:0] i_ad_rst;  // reset vector
    
    output insn_ce;          // insn clock enable 
    output [`AN:0] i_ad;     // next insn address
    input  [`IN:0] insn;     // current insn
    input  hit;              // insn is valid
    output int_en;           // OK to intr. now
    
    output [`AN:0] d_ad;     // load/store addr
    input  rdy;              // memory ready
    output sw, sb;           // executing sw (sb)
    output lw, lb;           // executing lw (lb)
    
    //inout  [`N:0] data;   // results, load data (bidirectional: CPU drives ALU/PC results, memory drives loads)
    input  [`N:0] data_in;   // data bus input from memory
    output [`N:0] data_out;  // data bus output to memory
    
    output br_taken;         // branch taken signal

    // Interrupt handling
    input  wire        irq_take;    // interrupt taken
    input  wire [15:0] irq_vector;  // interrupt vector
    output wire        iret_detected;

    // Decode/control signals
    wire [3:0] op;
    wire [3:0] rd;
    wire [3:0] rs;
    wire [3:0] fn;
    wire [3:0] imm;
    wire [11:0] i12;
    wire [3:0] cond;
    wire [7:0] disp;
    wire imm_pre;
    wire [11:0] i12_pre;
    wire rf_we; // register file write enable
    wire ccz, ccn, ccc, ccv; // condition codes
    
    // IRQ/control plumbing
    wire irq_save; 
    wire valid_insn_ce; 
    wire restore_cc;
    wire exec_ce; 
    
    // Control unit
    control_unit ctrl (
      .clk(clk), .rst(rst), .insn(insn), .hit(hit), .rdy(rdy),
      .op(op), .rd(rd), .rs(rs), .fn(fn), .imm(imm), .i12(i12),
      .cond(cond), .disp(disp),
      .insn_ce(insn_ce), .imm_pre(imm_pre), .i12_pre(i12_pre),
      .rf_we(rf_we), .lw(lw), .lb(lb), .sw(sw), .sb(sb), .int_en(int_en), .br_taken(br_taken),
      .ccz(ccz), .ccn(ccn), .ccc(ccc), .ccv(ccv), .irq_take(irq_take),
      .iret_detected(iret_detected), .valid_insn_ce(valid_insn_ce), .irq_save(irq_save),
      .restore_cc(restore_cc), .exec_ce(exec_ce)
    );
    
    // Datapath
    datapath dp (
      .clk(clk), .rst(rst), .hit(hit), .valid_insn_ce(valid_insn_ce),
      .i_ad_rst(i_ad_rst),
      .op(op), .rd(rd), .rs(rs), .fn(fn),
      .imm(imm), .i12(i12), .cond(cond), .disp(disp),
      .imm_pre(imm_pre), .i12_pre(i12_pre), .rf_we(rf_we),
      .data_in(data_in), .data_out(data_out),
      .i_ad(i_ad), .d_ad(d_ad), .br_taken(br_taken),
      .ccz(ccz), .ccn(ccn), .ccc(ccc), .ccv(ccv),

      .irq_take(irq_take),
      .irq_save(irq_save),
      .irq_vector(irq_vector),
      .restore_cc(restore_cc),
      .exec_ce(exec_ce)
    );

endmodule

// datapath: ALU, register file, PC, condition codes, result mux
module datapath(
  input  wire        clk,
  input  wire        rst,
  input  wire        hit,
  input  wire        valid_insn_ce,
  input  wire        exec_ce,
  input  wire [`AN:0] i_ad_rst,
  // control signals
  input  wire [3:0]  op,
  input  wire [3:0]  rd,
  input  wire [3:0]  rs,
  input  wire [3:0]  fn,
  input  wire [3:0]  imm,
  input  wire [11:0] i12,
  input  wire [3:0]  cond,
  input  wire [7:0]  disp,
  input  wire        imm_pre,
  input  wire [11:0] i12_pre,
  input  wire        rf_we,
  input  wire        br_taken,
  // interrupt handling
  input  wire        irq_take,
  input  wire        irq_save, 
  input  wire [15:0] irq_vector,
  input  wire        restore_cc,

  // memory -> cpu (loads)
  input  wire [`N:0] data_in,
  // cpu -> memory (stores)
  output wire [`N:0] data_out,

  // outputs
  output wire [`AN:0] i_ad,
  output wire [`AN:0] d_ad,
  output reg          ccz, ccn, ccc, ccv
);

  // pc logic
  (* mark_debug = "true"*) reg [`AN:0] pc;
  reg [`AN:0] pc_q;
  wire [`N:0] pcincd;
  // flags and psw
  reg c;
  wire [4:0] psw_vector; 
  // alu out
  wire [15:0] alu_res;
  // declared here before first use to avoid XVlog warnings


  // 1. Register file
  wire [`N:0] dreg;   // writeback mirror (wr_o)
  wire [`N:0] sreg;   // source (o)
  wire [`N:0] regfile_din_normal; // from ALU/memory

  wire rf_we_final; 
  wire [3:0]  rf_wr_ad_final; 
  wire [`N:0] regfile_din; 

  // normal writeback from alu/memory 
  assign regfile_din_normal = (`LW | `LB) ? data_in : alu_res;

  // interrupt link by hardware (r14)
  wire is_getcc = `SYS & (fn == 4'h9);

  // write enable
  assign rf_we_final = 
      (irq_save | is_getcc) ? 1'b1 : 
                              rf_we;
  
  // destination reg 
  assign rf_wr_ad_final = 
      irq_save ? 4'hE : 
                 rd;
  
  // data into regfile 
  assign regfile_din = 
      irq_save ? pc_q                : 
      is_getcc ? {11'b0, psw_vector} : 
                 regfile_din_normal;

  ram16x16d regfile (
    .clk   (clk),
    .we    (rf_we_final),
    .wr_ad (rf_wr_ad_final),
    .ad    (`RI ? rd : rs),
    .d     (regfile_din),
    .wr_o  (dreg),
    .o     (sreg)
  );

  // 2. PC update
  always @(posedge clk) begin
    pc_q <= pc; 
    if (br_taken) 
      pc_q <= pcincd; 

    if (rst)
      pc <= 16'h0100 - 16'h0002; // main vector
    else if (exec_ce | irq_take) 
      pc <= i_ad;
  end

  // 3. Immediate build
  wire word_off    = `LW | `SW | `JAL;
  wire sxi         = (`ADDI | `ALU) & imm[3];
  wire [10:0] sxi11 = {11{sxi}};
  wire i_4         = sxi | (word_off & imm[0]);
  wire i_0         = ~word_off & imm[0];
  wire [`N:0] imm16 = imm_pre ? {i12_pre, imm}
                              : {sxi11, i_4, imm[3:1], i_0};

  // 4. ALU operands
  wire [`N:0] a = `RR ? dreg : imm16;
  wire [`N:0] b = sreg;

  // 5. Adder / Subtractor
  wire [`N:0] sum;
  wire        add = ~(`ALU & (`SUB | `SBC | `CMP));
  wire        ci  = add ? c : ~c;
  wire        c_W, x;

  addsub adder (
    .add (add),
    .ci  (ci),
    .a   (a),
    .b   (b),
    .sum (sum),
    .x   (x),
    .co  (c_W)
  );

  // 6. Condition codes
  wire z  = (sum == 0);
  wire n  = sum[`N];
  wire co = add ? c_W : ~c_W;
  wire v  = c_W ^ sum[`N] ^ a[`N] ^ b[`N];

  // pack processor status word: carry + CCs
  assign psw_vector = {c, ccz, ccn, ccc, ccv};
  
  // restore condition codes from register file (SETCC instruction)
  reg [3:0] cc_restore;
  reg c_restore;

  wire is_setcc = `SYS & (fn == 4'hA);
  always @(*) begin 
    if (is_setcc) begin
      cc_restore = sreg[3:0];
      c_restore  = sreg[4];
    end else begin
      cc_restore = 4'b0;
      c_restore  = 1'b0;
    end
  end 
  
  // condition code logic 
  wire update_cc = exec_ce & (((`RR | `RI) & (`SUM | `CMP)) | `ADDI); // will require changes 
  always @(posedge clk) begin
    if (rst)
      {ccz, ccn, ccc, ccv} <= 4'b0;
    else if (restore_cc) 
      {ccz, ccn, ccc, ccv} <= cc_restore;
    else if (update_cc)
      {ccz, ccn, ccc, ccv} <= {z, n, co, v};
  end

  // carry latch for ADC/SBC
  always @(posedge clk) begin
    if (rst)
      c <= 1'b0;
    else if (restore_cc)
      c <= c_restore; 
    else if (exec_ce)
      c <= co & (`ALU & (`ADC | `SBC));
  end

  // 7. Logic / Shift units
  wire [`N:0] log = fn[0] ? (a ^ b) : (a & b);
  wire [`N:0] sr  = { (`SRA ? b[`N] : 1'b0), b[`N:1] };

  // 8. ALU / PC result (combinational)
  assign alu_res =
      ((`ALU & `SUM) | `ADDI) ? sum :
      (`ALU & `LOG)           ? log :
      (`ALU & `SR)            ? sr  :
      (`JAL)                  ? pc  :
                                16'h0000;

  // 9. CPU -> memory data (stores)
  assign data_out = dreg;   // store source

  // 10. PC update / branches
  wire [6:0]  sxd7   = {7{disp[7]}};
  wire [`N:0] sxd16  = {sxd7, disp, 1'b0};
  wire [`N:0] pcinc  = br_taken ? sxd16
                                : {14'b0, hit, 1'b0};
  assign pcincd = pcinc + pc;

  assign i_ad = rst ? 16'h0100
                    : irq_take     ? irq_vector
                    : (hit & `JAL) ? sum 
                    : pcincd;

  // 11. Data address for load/store
  assign d_ad = (sum << 1);

endmodule

// adder / subtractor with carry and overflow
module addsub(add, ci, a, b, sum, x, co);
    input  add, ci;
    input  [`N:0] a, b;
    output [`N:0] sum;
    output x, co;
    assign {co,sum,x} = add ? {a,ci} + {b,1'b1}
                            : {a,ci} - {b,1'b1};
endmodule // addsub

(*keep_hierarchy = "true", dont_touch = "true" *)
module ram16x16d(clk, we, wr_ad, ad,d,wr_o,o); // 16 registers of 16 bits
  input  clk;          // write clock
  input  we;           // write enable
  input  [3:0] wr_ad;  // write port addr
  input  [3:0] ad;     // read port addr
  input  [`N:0] d;     // write data in
  output [`N:0] wr_o;  // write port data out
  output [`N:0] o;     // read port data out

  reg [`N:0] mem [15:0];

  // debug registers
  (* mark_debug = "true" *) reg [15:0] r0, a0, a1, a2, t0, t1, t2, t3, s0, s1, s2, s3, fp, sp, lr, gp;
  always @(*) begin
          r0  = mem[0];
          a0  = mem[1];
          a1  = mem[2];
          a2  = mem[3];
          t0  = mem[4];
          t1  = mem[5];
          t2  = mem[6];
          t3  = mem[7];
          s0  = mem[8];
          s1  = mem[9];
          s2  = mem[10];
          s3  = mem[11];
          fp  = mem[12];
          sp  = mem[13];
          lr  = mem[14];
          gp  = mem[15];
  end

  reg [4:0] i;
  initial begin
    for (i = 0; i < 16; i = i + 1)
    mem[i] = 0;
  end

  always @(posedge clk) begin
    if (we && wr_ad != 4'b0000) // don't write to r0 (zero register)
      mem[wr_ad] = d;
  end

  assign o    = mem[ad];
  assign wr_o = mem[wr_ad];
endmodule // ram16x16d
