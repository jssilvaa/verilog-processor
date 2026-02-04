`timescale 1ns / 1ps
module uart_rx (
    input clk,              // FPGA clock, currently @ 80 MHz
    input rst,              // Active-high reset
    input rx_in,            // Serial input
    output reg [7:0] data,      // Received data
    output reg data_valid,      // Data ready to read (1-cycle pulse)
    output reg  rx_out,      // For debugging: current bit being received
    output reg  rx_done,     // Reception complete (1 cycle pulse)
    output wire rx_busy,    // Reception in progress
    output wire [1:0] state_debug  // For debugging
);

    // Parameters
    parameter CLK_FREQ = 80_000_000;             // 80 MHz, match top level module clk 
    parameter BAUD_RATE = 115200;                // Baud rate 
    localparam BIT_TIME = (CLK_FREQ + (BAUD_RATE/2)) / BAUD_RATE;  // Bit time in clock cycles (rounded)
    localparam CTR_WIDTH = $clog2(BIT_TIME) + 1; // Counter width 
    localparam HALF_BIT = BIT_TIME / 2; 

    // State machine encoding
    localparam STATE_IDLE    = 2'd0;
    localparam STATE_START   = 2'd1;
    localparam STATE_DATA    = 2'd2;
    localparam STATE_STOP    = 2'd3;

    // Internal regs
    reg [1:0] state;
    reg [CTR_WIDTH-1:0] counter;
    reg [7:0] shift_reg;
    reg [2:0] bit_index;
    reg stop_ok;

    // RX input synchronizer
    reg rx_sync1;
    reg rx_sync2;
    wire rx_s = rx_sync2;

    // Status/debug
    assign rx_busy = (state != STATE_IDLE);
    assign state_debug = state;

    // RX state machine
    always @(posedge clk) begin
        if (rst) begin
            state       <= STATE_IDLE; 
            counter     <= 0;
            rx_out      <= 1;      // Idle high
            rx_done     <= 0;
            data_valid  <= 0;
            shift_reg   <= 8'd0;
            bit_index   <= 0;
            data        <= 8'd0;
            stop_ok     <= 1'b0;
            rx_sync1    <= 1'b1;
            rx_sync2    <= 1'b1;
        end else begin 
            rx_sync1 <= rx_in;   // 2-flop synchronizer for async RX
            rx_sync2 <= rx_sync1;

            rx_done <= 0; // Default: pulse for one cycle only
            data_valid <= 0;

            case (state)
                STATE_IDLE: begin  // wait for start bit 
                    rx_out <= 1;  // High when idle
                    if (!rx_s) begin // start bit
                        counter   <= 0;
                        state     <= STATE_START;
                        bit_index <= 0;
                        stop_ok   <= 1'b0;
                    end
                end

                STATE_START: begin  // Sample mid-start bit (confirm start)
                    if (counter == HALF_BIT - 1) begin
                        if (!rx_s) begin          // Confirm start bit
                            rx_out  <= 0;         // Output start bit
                            counter <= 0;
                            state   <= STATE_DATA;
                            bit_index <= 0; 
                        end else begin 
                            rx_out  <= 1;         // False start, go back to idle
                            counter <= 0; 
                            state <= STATE_IDLE;  // False start
                            bit_index <= 0; 
                        end
                    end else counter <= counter + 1;
                end

                STATE_DATA: begin  // Sample data bits (8 bits)
                    if (counter == HALF_BIT - 1) begin
                        shift_reg[bit_index] <= rx_s;
                        rx_out <= rx_s;
                    end

                    if (counter == BIT_TIME - 1) begin
                        counter <= 0;
                        if (bit_index == 3'd7) begin
                            state <= STATE_STOP;
                            bit_index <= 0;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        counter <= counter + 1;
                    end
                end

                STATE_STOP: begin  // Stop bit
                    rx_out <= 1;   // Stop bit is high
                    if (counter == HALF_BIT - 1) begin
                        stop_ok <= rx_s;
                    end
                    if (counter == BIT_TIME - 1) begin
                        counter <= 0;
                        state <= STATE_IDLE;
                        if (stop_ok) begin
                            data <= shift_reg;
                            rx_done <= 1;     // Pulse indicating reception complete
                            data_valid <= 1;
                        end
                    end else counter <= counter + 1;
                end

                default: begin
                    state <= STATE_IDLE; 
                end
            endcase
        end
    end

endmodule // uart_rx
