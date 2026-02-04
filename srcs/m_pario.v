// m_pario.v: 8-bit parallel I/O peripheral (MMIO)
`timescale 1ns/1ps
module pario (
    input  wire        clk,
    input  wire        rst,
    input  wire        sel,
    input  wire        we,
    input  wire        re,
    input  wire [1:0]  addr,   // reg index
    input  wire [15:0] wdata,
    output reg  [15:0] rdata,
    output wire        rdy,

    input  wire [3:0]  i,
    output reg  [3:0]  o,
    output reg        int_req
);
    assign rdy = sel;  // single-cycle access when selected

    // Interrupt request when all inputs are high (example, more fun this way)
    always @(*) begin
        if (i == 4'hF)
            int_req = 1'b1;
        else
            int_req = 1'b0;    
    end

    // IRQ when all 4 LSB inputs are high
    always @(posedge clk) begin
        if (rst) begin
            o   <= 4'h0;
        end else if (sel && we) begin
            case (addr)
                2'b00: o   <= wdata[3:0]; // DATA
                default: ;
            endcase
        end
    end

    // Readback
    always @(*) begin
        if (!sel || !re) begin
            rdata = 16'h0000;
        end else begin
            case (addr)
                2'b00: rdata = {12'h000, o}; // read OUTPUT data
                2'b10: rdata = {12'h000, i}; // read INPUT data
                default: rdata = 16'h0000;
            endcase
        end
    end

endmodule
