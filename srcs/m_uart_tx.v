`timescale 1ns / 1ps
module uart_tx (
    input clk,              // FPGA clock (currently @ 80 MHz)
    input rst,              // Active-high reset
    input [7:0] data,       // 8-bit data to transmit
    input tx_start,         // Trigger transmission
    output reg  tx_out,      // Serial output
    output reg  tx_done,     // Transmission complete (1 cycle pulse)
    output wire tx_busy,    // Transmission in progress
    output wire [1:0] state_debug  // For debugging
);

    // Parameters
    parameter CLK_FREQ = 80_000_000;  // 80 MHz, match top level module clk 
    parameter BAUD_RATE = 115200;     // Baud rate

    localparam BIT_TIME = (CLK_FREQ + (BAUD_RATE/2)) / BAUD_RATE;  // Clock cycles per bit (rounded)
    localparam CTR_WIDTH = $clog2(BIT_TIME) + 1; // Counter width

    // State machine encoding
    localparam STATE_IDLE  = 2'd0;
    localparam STATE_START = 2'd1;
    localparam STATE_DATA  = 2'd2;
    localparam STATE_STOP  = 2'd3;

    // Internal regs
    reg [1:0] state;                    // tracks state machine 
    reg [CTR_WIDTH-1:0] counter;        // bit time counter 
    reg [7:0] shift_reg;                // shift reg for data bits
    reg [2:0] bit_index;                // index for data bits (0-7)

    // Status/debug
    assign tx_busy = (state != STATE_IDLE);
    assign state_debug = state;

    // TX state machine
    always @(posedge clk) begin
        if (rst) begin
            state     <= STATE_IDLE;
            counter   <= 0;
            tx_out    <= 1;        // Idle high
            tx_done   <= 0;
            shift_reg <= 8'd0;
            bit_index <= 0;
        end else begin
            tx_done <= 0;       // Default: pulse for one cycle only
            
            case (state)
                STATE_IDLE: begin
                    tx_out <= 1;  // High when idle
                    if (tx_start) begin
                        shift_reg <= data;
                        state <= STATE_START;
                        counter <= 0;
                        bit_index <= 0;
                    end
                end
                
                STATE_START: begin
                    tx_out <= 0;  // Start bit
                    if (counter == BIT_TIME - 1) begin
                        counter <= 0;
                        state <= STATE_DATA;
                    end else begin
                        counter <= counter + 1;
                    end
                end
                
                STATE_DATA: begin
                    tx_out <= shift_reg[bit_index];  // Output current bit (LSB first)
                    if (counter == BIT_TIME - 1) begin
                        counter <= 0;
                        if (bit_index == 7) begin
                            state <= STATE_STOP;
                            bit_index <= 0;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        counter <= counter + 1;
                    end
                end
                
                STATE_STOP: begin
                    tx_out <= 1;  // Stop bit
                    if (counter == BIT_TIME - 1) begin
                        counter <= 0;
                        state <= STATE_IDLE;
                        tx_done <= 1;  // Pulse indicating completion
                    end else begin
                        counter <= counter + 1;
                    end
                end
                
                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule // uart_tx
