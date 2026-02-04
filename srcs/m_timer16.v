// timer16.v: 16-bit timer with interrupt request
`timescale 1ns/1ps
module timer16 (
    input  wire        clk,
    input  wire        rst,
    input  wire        sel,
    input  wire        we,
    input  wire        re,
    input  wire [1:0]  addr,   // two LSBs for reg index: there's CR0, CR1, CNT (the latter for debug)
    input  wire [15:0] wdata,
    output reg  [15:0] rdata,
    output wire        rdy,
    output reg         int_req
);
    assign rdy = sel;  // single-cycle access when selected

    // Control registers
    // For more information: https://pictutorials.com/The_Intcon_Register.htm
    // int_en + mode; CR0 Register (Control 0 Register)
    (* mark_debug = "true" *) reg int_en;       // Mask/unmask interrupt, e.g. T0IE in the INTCON register for PIC microcontrollers
    (* mark_debug = "true" *) reg timer_mode;   // 1 = timer on every clk, 0 = (future) external tick
    // int_req; CR1 Register (Control 1 Register) 
    (* mark_debug = "true" *) wire int_req_dbg; // T0IF flag in the INTCON 
    assign int_req_dbg = int_req;

    always @(posedge clk) begin
        if (rst) begin
            int_en     <= 1'b0;  // T0IE disabled by default
            timer_mode <= 1'b1;  // timer mode, currently only timer mode is defined 
        end else if (sel && we && (addr == 2'b00)) begin
            int_en     <= wdata[0];
            timer_mode <= wdata[1];
        end
    end

    // 16-bit counter
    (* mark_debug = "true" *) reg [15:0] cnt;
    wire        tick = timer_mode;   // just "1" every clk in timer mode
    wire [16:0] cnt_nxt = {1'b0, cnt} + 17'd1;
    wire        overflow = cnt_nxt[16];

    always @(posedge clk) begin
        if (rst)
            cnt <= 16'hFFF0; // start near overflow to see interrupts early 
        else if (tick)
            cnt <= cnt_nxt[15:0];
    end

    // Interrupt request latch (CR1)
    always @(posedge clk) begin
        if (rst)
            int_req <= 1'b0;
        else if (sel && we && (addr == 2'b01))
            int_req <= 1'b0;          // write to CR1 clears
        else if (tick && overflow && int_en)
            int_req <= 1'b1;
    end

    // Readback
    always @(*) begin
        if (!sel || !re) begin
            rdata = 16'h0000;
        end else begin
            case (addr)
                2'b00: rdata = {14'b0, timer_mode, int_en};
                2'b01: rdata = {15'b0, int_req};
                2'b10: rdata = cnt;        // debug: read current counter
                default:
                      rdata = 16'h0000;
            endcase
        end
    end

endmodule // timer16
