// m_uart_mmio.v: UART MMIO wrapper with RX IRQ
`timescale 1ns/1ps
module uart_mmio #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer BAUD_RATE = 115200
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        sel,
    input  wire        we,
    input  wire        re,
    input  wire [1:0]  addr,
    input  wire [15:0] wdata,
    output reg  [15:0] rdata,
    output wire        rdy,

    input  wire        rx_in,
    output wire        tx_out,
    output wire        irq_req
);
    // Single-cycle ready when selected
    assign rdy = sel;

    reg  [7:0] tx_data;
    reg        tx_start;
    wire       tx_busy;

    wire [7:0] rx_data_wire;
    reg  [7:0] rx_data;
    reg        rx_pending;
    wire       rx_valid;

    // Interrupt when RX data is pending
    assign irq_req = rx_pending;

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_tx (
        .clk(clk),
        .rst(rst),
        .data(tx_data),
        .tx_start(tx_start),
        .tx_out(tx_out),
        .tx_done(),
        .tx_busy(tx_busy),
        .state_debug()
    );

    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_rx (
        .clk(clk),
        .rst(rst),
        .rx_in(rx_in),
        .data(rx_data_wire),
        .data_valid(rx_valid),
        .rx_out(),
        .rx_done(),
        .rx_busy(),
        .state_debug()
    );

    // Write-side effects and RX latch
    always @(posedge clk) begin
        if (rst) begin
            tx_data    <= 8'h00;
            tx_start   <= 1'b0;
            rx_data    <= 8'h00;
            rx_pending <= 1'b0;
        end else begin
            tx_start <= 1'b0;

            if (rx_valid) begin
                rx_data    <= rx_data_wire;
                rx_pending <= 1'b1;
            end

            if (sel && we) begin
                case (addr)
                    2'b00: begin
                        if (!tx_busy) begin
                            tx_data  <= wdata[7:0];
                            tx_start <= 1'b1;
                        end
                    end
                    2'b01: begin
                        if (wdata[1]) rx_pending <= 1'b0;
                    end
                    default: ;
                endcase
            end

            if (sel && re && addr == 2'b00)
                rx_pending <= 1'b0;
        end
    end

    // Read mux
    always @(*) begin
        if (!sel || !re) begin
            rdata = 16'h0000;
        end else begin
            case (addr)
                2'b00: rdata = {8'h00, rx_data};
                2'b01: rdata = {14'b0, rx_pending, tx_busy};
                default: rdata = 16'h0000;
            endcase
        end
    end

endmodule
