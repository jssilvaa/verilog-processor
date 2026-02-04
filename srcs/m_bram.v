`timescale 1ns / 1ps
// 1 KiB BRAM (big-endian) with byte enables, true dual port
(* ram_style = "block", keep_hierarchy = "true", dont_touch = "true" *)
module bram_1kb_be(
    input wire clk, // clock
    input wire rst, // rst (sync)

    // Port A (instruction fetch)
    input wire a_en, 
    input wire [9:1] a_addr,    // word index (byte_address[9:1])
    output reg [7:0] a_dout_h,  // data out (high byte) MSB @ even address
    output reg [7:0] a_dout_l,  // data out (low byte)  LSB @ odd address

    // Port B (data access)
    input wire b_en,
    input wire b_we_h,            // write enable
    input wire b_we_l,            // write enable
    input wire [9:1] b_addr,      // word index (byte_address[9:1])
    input wire [7:0] b_din_h,     // data in (high byte) MSB @ even address
    input wire [7:0] b_din_l,     // data in (low byte)  LSB @ odd address
    output reg [7:0] b_dout_h,    // data out (high byte) MSB @ even address
    output reg [7:0] b_dout_l     // data out (low byte)  LSB @ odd address
    );

    // Synthesis hints, range is from 0x000 to 0x3FF (1 KiB)
    (* ram_style = "block" *) reg [7:0] mem_h [0:511]; // high byte (MSB) @ even address
    (* ram_style = "block" *) reg [7:0] mem_l [0:511]; // low byte  (LSB) @ odd  address
    
    // Initialize memory to NOPs 
    // Note: NOP is 0xF000, so high byte = 0xF0, low byte = 0x00
    // If NOP encoding changes ANYWHERE, this needs to be updated
    integer i;
    initial begin
        for (i = 0; i < 512; i = i + 1) begin
            mem_h[i] = 8'hF0;
            mem_l[i] = 8'h00;
        end
    end

    // Simulation init images (hi/lo byte lanes).
    //
    // Defaults are repo-relative so simulation works on any machin from the get-go 
    // you can override this later depending on your path choices 
    //   +MEM_HEX_HI=path/to/mem_hi.hex +MEM_HEX_LO=path/to/mem_lo.hex
    reg [1023:0] MEM_HEX_LO;
    reg [1023:0] MEM_HEX_HI;
    integer fh;
    initial begin
        if (!$value$plusargs("MEM_HEX_LO=%s", MEM_HEX_LO))
            MEM_HEX_LO = "srcs/mem/mem_lo.hex";
        if (!$value$plusargs("MEM_HEX_HI=%s", MEM_HEX_HI))
            MEM_HEX_HI = "srcs/mem/mem_hi.hex";

        fh = $fopen(MEM_HEX_LO, "r");
        if (fh == 0) $display("WARN: BRAM init file not found: %0s (LO byte lane)", MEM_HEX_LO);
        else $fclose(fh);
        fh = $fopen(MEM_HEX_HI, "r");
        if (fh == 0) $display("WARN: BRAM init file not found: %0s (HI byte lane)", MEM_HEX_HI);
        else $fclose(fh);

        $readmemh(MEM_HEX_LO, mem_l);
        $readmemh(MEM_HEX_HI, mem_h);
    end

    // Port A (i fetch)
    always @(posedge clk) begin
        if (rst) begin
            a_dout_h <= 8'hF0; // NOP
            a_dout_l <= 8'h00; 
        end else if (a_en) begin
            a_dout_h <= mem_h[a_addr];
            a_dout_l <= mem_l[a_addr];
        end
    end

    // Port B (d load/store)
    reg [7:0] memh_q, meml_q; 
    always @(posedge clk) begin
        if (~rst & b_en) begin
          // writes go to the memory arrays
          if (b_we_h) begin mem_h[b_addr] <= b_din_h; end
          if (b_we_l) begin mem_l[b_addr] <= b_din_l; end 
        end 
    end

    // registered output
    always @(posedge clk) begin
        if (rst) begin
            b_dout_h <= 8'h00;
            b_dout_l <= 8'h00;
        end else if (b_en) begin
            b_dout_h <= mem_h[b_addr];
            b_dout_l <= mem_l[b_addr];
        end
    end

    // Debug regs (for waveform inspection)
    (* mark_debug = "true" *) reg [15:0] mem0_dbg, mem1_dbg, mem2_dbg;
    always @(posedge clk) begin
        if (b_en)
        case (b_addr)
            9'd0: mem0_dbg <= {b_we_h ? b_din_h : b_dout_h,
                               b_we_l ? b_din_l : b_dout_l};
            9'd1: mem1_dbg <= {b_we_h ? b_din_h : b_dout_h,
                               b_we_l ? b_din_l : b_dout_l};
            9'd2: mem2_dbg <= {b_we_h ? b_din_h : b_dout_h,
                               b_we_l ? b_din_l : b_dout_l};    
            default:;
        endcase
    end

endmodule // bram_1kb_be