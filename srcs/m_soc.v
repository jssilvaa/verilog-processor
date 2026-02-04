// SoC module 
// Creates CPU + Peripheral bus, and insn/data Harvard Architecture BRAM
// CPU is the gr0041 version wrapped for interrupt handling 

// notes: 
// some wires / ports are marked with "mark_debug" attribute for visibility in the waveform analyzer in Vivado 

`timescale 1ns/1ps
module soc
(
  input  wire        clk,
  input  wire        rst,
  input  wire [3:0]  par_i, 
  output wire [3:0]  par_o,
  input  wire        uart_rx,
  output wire        uart_tx
);
    // localparam 
    // for some reason reset_vec is not propagating to lower hierarchy modules
    // we might see this valued hardcoded within the int_wrapper / cpu
    // changes here must be reflected there as well
    localparam default_nop = 16'hF000; // NOP instruction
    localparam reset_vec   = 16'h0100; // reset vector address

    // Core - BRAM Communication 
    wire        insn_ce;
    wire [15:0] i_ad;
    wire hit = ~rst;  // always hit when not in reset

    // Data address and strobes 
    (* mark_debug = "true" *) wire [15:0] d_ad; // address bus
    wire        sw, sb, lw, lb;                 // strobes

    // SoC - CPU data buses
    (* mark_debug = "true" *) wire [15:0] cpu_do; // cpu_o : CPU to mem
    (* mark_debug = "true" *) wire [15:0] cpu_di; // mem_o : mem to CPU

    // Hi-Lo i-Memory Outputs
    wire [7:0] imem_dout_h;
    wire [7:0] imem_dout_l;

    // Hi-Lo d-Memory Outputs
    wire [7:0] dmem_dout_h;
    wire [7:0] dmem_dout_l;

    // Interrupt wires
    wire [7:0]  int_req;               // driven by periph_bus.timer
    wire [15:0] i_ad_rst = reset_vec;  // reset vector, here assigned to the localparam 

    // Instruction fetch registers
    (* mark_debug = "true" *) reg [15:0] insn_q;      // registered instruction from imem 
    wire br_taken;                                    // branch taken signal

    (* mark_debug = "true" *) wire [15:0] imem_dout = {imem_dout_h, imem_dout_l};
    wire imem_invalid = &(~imem_dout); // all bits zero indicates invalid instruction (here for warning and immediate failure)
    // as we explictly hold off from 0x0000. this can be relaxed later if needed

    always @(posedge clk) begin
        if (rst | imem_invalid) begin
            insn_q <= default_nop; 
        end else if (insn_ce) begin
            insn_q <= imem_dout;  
            if (br_taken) begin
                insn_q <= default_nop; 
            end
        end
    end

    // Ready control 
    reg loaded; // load bram in bram out regs 
    always @(posedge clk) begin
        if (rst) begin
            loaded <= 1'b0;
        end else if (insn_ce) begin
            loaded <= 1'b0;
        end else begin
            loaded <= (lw|lb);
        end
    end
    assign mem_rdy = ~((lw|lb) & ~loaded);

    // IO signals
    wire is_io = d_ad[15]; // MSB-based IO mapping
    wire mem_we_h = (sw | sb&~d_ad[0]) & ~is_io;
    wire mem_we_l = (sw | sb& d_ad[0]) & ~is_io;

    // Drive the mem to cpu data bus
    wire [15:0] mem_dout = {dmem_dout_h, dmem_dout_l};

    // IO peripheral signals
    wire        io_sel  = is_io;
    wire        io_we   = is_io & (sw | sb);
    wire        io_re   = is_io & (lw | lb);
    wire [15:0] io_wdata = cpu_do;
    wire [15:0] io_rdata;
    wire        io_rdy;

    assign cpu_di = is_io ? io_rdata : mem_dout;
    assign rdy    = is_io ? io_rdy    : mem_rdy;

    // interrupt controller wires 
    wire irq_take;              // interrupt taken signal
    wire [15:0] irq_vector;     // interrupt vector from periph_bus
    wire in_irq;                // cpu in interrupt service routine
    wire int_en_cpu;            // interrupt enable from cpu
    wire iret_detected;         // iret instruction detected signal (from cpu)

    // Instantiate the CPU + Interrupt wrapper
    gr0041 u_irq_cpu (
        .clk(clk), .rst(rst),
        .i_ad_rst(i_ad_rst),

        .insn_ce(insn_ce),
        .i_ad(i_ad),
        .insn(insn_q),
        .hit(~rst),

        .rdy(rdy),
        .sw(sw), .sb(sb),
        .lw(lw), .lb(lb),

        .d_ad(d_ad),
        .data_out(cpu_do),
        .data_in(cpu_di),
        .br_taken(br_taken),

        .irq_take(irq_take),
        .irq_vector(irq_vector),
        .in_irq(in_irq),
        .int_en(int_en_cpu),
        .iret_detected(iret_detected)
    );

    // Dual-port 1KB BRAM
    bram_1kb_be u_mem (
        .clk(clk), .rst(rst),
        .a_en(insn_ce),
        .a_addr(i_ad[9:1]),
        .a_dout_h(imem_dout_h),
        .a_dout_l(imem_dout_l),
        .b_en(sw | sb | lw | lb),
        .b_addr(d_ad[9:1]),
        .b_we_h(mem_we_h),
        .b_we_l(mem_we_l),
        .b_din_h(cpu_do[15:8]),
        .b_din_l(cpu_do[7:0]),
        .b_dout_h(dmem_dout_h),
        .b_dout_l(dmem_dout_l)
    );

    periph_bus u_periph (
        .clk(clk), .rst(rst),
        .addr(d_ad),
        .sel(io_sel),
        .we(io_we),
        .re(io_re),
        .wdata(io_wdata),
        .rdata(io_rdata),
        .rdy(io_rdy),
        .par_i(par_i),
        .par_o(par_o),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .int_en(int_en_cpu),
        .in_irq(in_irq),
        .irq_vector(irq_vector),
        .irq_take(irq_take),
        .irq_ret(iret_detected)
    );

endmodule // soc