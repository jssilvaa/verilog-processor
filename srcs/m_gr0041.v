// gr0041_min.v 
`timescale 1ns/1ps
module gr0041 (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] i_ad_rst,      // reset address 
    
    // to i-memory
    output wire        insn_ce,
    output wire [15:0] i_ad,
    input  wire [15:0] insn,
    input  wire        hit,

    // to d-memory / IO
    output wire [15:0] d_ad,          // data address
    input  wire        rdy,
    output wire        sw, sb,
    output wire        lw, lb,
    output wire [15:0] data_out,      // CPU → mem/periph
    input  wire [15:0] data_in,       // mem/periph → CPU

    input wire         irq_take,      // from irq_ctrl: we want to take an interrupt
    input wire  [15:0] irq_vector,    // from irq_ctrl: which vector to jump to
    output reg         in_irq,        // we're in an interrupt service routine 
    output wire        int_en,        // to irq_ctrl: interrupt enable from CPU
    output wire        iret_detected, // to irq_ctrl: iret instruction detected
    output wire        br_taken
);
    // IRQ nesting depth tracking
    reg [1:0] irq_depth;

    always @(posedge clk) begin
        if (rst) begin
            irq_depth <= 2'b00;
            in_irq    <= 1'b0;
        end else begin
            case ({irq_take, iret_detected}) 
                2'b10: irq_depth <= irq_depth + 3'd1; // enter ISR
                2'b01: irq_depth <= irq_depth - 3'd1; // exit ISR
                2'b11: irq_depth <= irq_depth;        // exit + enter = depth unchanged
                default: ; 
            endcase
            in_irq <= (irq_depth != 0) | irq_take;    // cpu within ISR if depth > 0 or taking new IRQ
        end
    end

    // cpu instance
    gr0040 u_cpu (
        .clk(clk),
        .rst(rst),
        .i_ad_rst(i_ad_rst),

        .insn(insn),
        .insn_ce(insn_ce),
        .i_ad(i_ad),

        .hit(hit), 
        .rdy(rdy),

        .d_ad(d_ad),
        .sw(sw), .sb(sb),
        .lw(lw), .lb(lb),

        .data_in(data_in),
        .data_out(data_out),
        .int_en(int_en),                // to irq_ctrl

        .irq_take(irq_take),            // from irq_ctrl
        .irq_vector(irq_vector),        // from irq_ctrl
        .iret_detected(iret_detected),
        .br_taken(br_taken)
    );

endmodule // gr0041
