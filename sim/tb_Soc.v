`timescale 1ns/1ps
`default_nettype none

module tb_Soc;
    reg clk = 0;
    reg rst = 1;

    reg  [3:0] par_i = 4'h0;
    wire [3:0] par_o;

    reg  uart_rx = 1'b1;
    wire uart_tx;

    // DUT instantiation
    soc dut (
        .clk(clk),
        .rst(rst),
        .par_i(par_i),
        .par_o(par_o),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    task wait_clocks(input integer n);
        repeat (n) @(posedge clk);
    endtask // wait_clocks

    // UART timing derived from clock/baud
    localparam integer CLK_PERIOD_NS = 10;
    localparam integer CLK_FREQ      = 100_000_000;
`ifdef SIM
    localparam integer BAUD_RATE     = 2_000_000;
`else
    localparam integer BAUD_RATE     = 115200;
`endif
    localparam integer BIT_CYCLES    = (CLK_FREQ + (BAUD_RATE/2)) / BAUD_RATE;
    localparam integer BIT_TIME_NS   = BIT_CYCLES * CLK_PERIOD_NS;

    // Drive RX line with one UART frame (start, 8 data, stop)
    task uart_send_byte(input [7:0] b);
        integer k;
        begin
            uart_rx = 1'b0;
            #(BIT_TIME_NS);
            for (k = 0; k < 8; k = k + 1) begin
                uart_rx = b[k];
                #(BIT_TIME_NS);
            end
            uart_rx = 1'b1;
            #(BIT_TIME_NS);
        end
    endtask

`ifdef TB_UART_MMIO_TEST
    // MMIO helpers to poke UART registers directly (bypass CPU)
    reg [15:0] mmio_rd;
    reg [7:0]  mmio_expect;

    // Direct MMIO access to UART via periph_bus (bypasses CPU) for behavioral testing.
    task periph_write(input [1:0] a, input [15:0] d);
        begin
            force dut.u_periph.addr  = 16'h8300 | {14'b0, a};
            force dut.u_periph.wdata = d;
            force dut.u_periph.sel   = 1'b1;
            force dut.u_periph.we    = 1'b1;
            force dut.u_periph.re    = 1'b0;
            @(posedge clk);
            release dut.u_periph.sel;
            release dut.u_periph.we;
            release dut.u_periph.re;
            release dut.u_periph.addr;
            release dut.u_periph.wdata;
        end
    endtask

    task periph_read(input [1:0] a, output [15:0] d);
        begin
            force dut.u_periph.addr  = 16'h8300 | {14'b0, a};
            force dut.u_periph.wdata = 16'h0000;
            force dut.u_periph.sel   = 1'b1;
            force dut.u_periph.we    = 1'b0;
            force dut.u_periph.re    = 1'b1;
            @(posedge clk);
            d = dut.u_periph.rdata;
            release dut.u_periph.sel;
            release dut.u_periph.we;
            release dut.u_periph.re;
            release dut.u_periph.addr;
            release dut.u_periph.wdata;
        end
    endtask
`endif

`ifdef TB_USE_INTERNALS
    // Optional internal probes (RTL sim only). Leave TB_USE_INTERNALS undefined for netlist sims.
    wire [15:0] i_ad = dut.i_ad;
    wire [15:0] d_ad = dut.d_ad;
    wire        io_sel = dut.io_sel;
    wire        io_we  = dut.io_we;
    wire        io_re  = dut.io_re;
    wire        irq_take = dut.irq_take;
    wire [15:0] irq_vector = dut.irq_vector;
    wire        in_irq = dut.in_irq;
    wire        uart_irq = dut.u_periph.u_uart.irq_req;
    wire        uart_rx_pending = dut.u_periph.u_uart.rx_pending;
    wire [7:0]  uart_rx_data = dut.u_periph.u_uart.rx_data;
    wire        uart_tx_busy = dut.u_periph.u_uart.tx_busy;
`endif

    // Cycle counter after reset
    integer cycles = 0;
    always @(posedge clk) begin
        if (!rst) cycles <= cycles + 1;
    end

    // Basic reset sequencing
    initial begin
        wait_clocks(5);
        rst = 0;

        wait_clocks(10);
        wait_clocks(40);
        //$finish;
    end

    // Optional UART stimulus via plusarg: +UART_BYTE=xx
    integer b;
    initial begin
        if ($value$plusargs("UART_BYTE=%h", b)) begin
            wait_clocks(20);
            uart_send_byte(b[7:0]);
        end
    end

`ifdef TB_UART_MMIO_TEST
    // Behavioral UART MMIO test (RX then TX)
    initial begin
        wait_clocks(10);
        rst = 0;
        wait_clocks(10);

        // RX test: inject a byte and read it back via MMIO.
        mmio_expect = 8'hA5;
        uart_send_byte(mmio_expect);
        wait_clocks(2);
        wait (dut.u_periph.u_uart.irq_req == 1'b1);
        periph_read(2'b01, mmio_rd);
        if (mmio_rd[1] !== 1'b1) $display("UART MMIO RX pending not set as expected");
        periph_read(2'b00, mmio_rd);
        if (mmio_rd[7:0] !== mmio_expect)
            $display("UART MMIO RX mismatch got 0x%02h expected 0x%02h", mmio_rd[7:0], mmio_expect);

        // TX test: write a byte and poll tx_busy via status.
        periph_write(2'b00, 16'h005A);
        periph_read(2'b01, mmio_rd);
        if (mmio_rd[0] !== 1'b1) $display("UART MMIO TX busy not set after write");
        wait (dut.u_periph.u_uart.tx_busy == 1'b0);
        $display("UART MMIO test done");
    end
`endif

`ifdef TB_USE_INTERNALS
    // Edge-triggered debug prints for IRQ activity
    reg uart_irq_d;
    reg irq_take_d;
    always @(posedge clk) begin
        if (rst) begin
            uart_irq_d <= 1'b0;
            irq_take_d <= 1'b0;
        end else begin
            uart_irq_d <= uart_irq;
            irq_take_d <= irq_take;
            if (uart_irq && !uart_irq_d)
                $display("UART IRQ set  t=%0t  rx_data=0x%02h  rx_pending=%0b", $time, uart_rx_data, uart_rx_pending);
            if (irq_take && !irq_take_d)
                $display("IRQ take      t=%0t  vector=0x%04h  in_irq=%0b", $time, irq_vector, in_irq);
        end
    end
`endif

    // Text monitoring
    initial begin
`ifdef TB_USE_INTERNALS
        $display("time   cycles  rst  i_ad   d_ad   io_sel io_we io_re  irq_take vector  uart_irq rx_pend tx_busy par_o");
        $monitor("%0t %6d   %0b   0x%04h 0x%04h   %0b     %0b   %0b   %0b    0x%04h   %0b      %0b      %0b     0x%1h",
                 $time, cycles, rst, i_ad, d_ad, io_sel, io_we, io_re, irq_take, irq_vector, uart_irq, uart_rx_pending, uart_tx_busy, par_o);
`else
        $display("time   cycles  rst  par_o");
        $monitor("%0t %6d   %0b   0x%1h", $time, cycles, rst, par_o);
`endif
    end

    // VCD dump
    initial begin
        $dumpfile("waves_soc.vcd");
        $dumpvars(0, tb_Soc);
    end
endmodule
