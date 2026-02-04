// periph_bus.v: Peripheral bus module
`timescale 1ns/1ps
module periph_bus
( 
    input wire         clk,
    input wire         rst, 
    input wire [15:0]  addr,
    input wire         sel,
    input wire         we,
    input wire         re,
    input wire [15:0]  wdata,
    output wire [15:0] rdata,
    output wire        rdy,
    input  wire [3:0]  par_i,
    output wire [3:0]  par_o, 
    input  wire        uart_rx,
    output wire        uart_tx,

    input wire         int_en,
    input wire         in_irq, 
    output wire [15:0] irq_vector,
    output wire        irq_take,
    input wire         irq_ret 
); 

    // Peripheral address map
    localparam [3:0] PERIPH_TIMER = 4'h0;     // Timer0: addr[11:8] = 0, range 0x8000-0x80FF
    localparam [3:0] PERIPH_TIMER1 = 4'h1;    // Timer1: addr[11:8] = 1, range 0x8100-0x81FF
    localparam [3:0] PERIPH_PARIO  = 4'h2;    // PARIO:  addr[11:8] = 2, range 0x8200-0x82FF
    localparam [3:0] PERIPH_UART = 4'h3;   // UART MMIO: addr[11:8] = 3, range 0x8300-0x83FF
    localparam [3:0] PERIPH_IRQ   = 4'hF;     // IRQ regs: addr[11:8] = 0xF, range 0x8F00-0x8FFF

    // Peripheral select signals
    wire sel_timer, sel_timer1, sel_pario, sel_uart, sel_irq;
    assign sel_timer  = sel && (addr[11:8] == PERIPH_TIMER);
    assign sel_timer1 = sel && (addr[11:8] == PERIPH_TIMER1);
    assign sel_pario  = sel && (addr[11:8] == PERIPH_PARIO);
    assign sel_uart   = sel && (addr[11:8] == PERIPH_UART);
    assign sel_irq    = sel && (addr[11:8] == PERIPH_IRQ);

    // Ready signals from peripherals
    wire timer_rdy, timer1_rdy, pario_rdy, uart_rdy, irq_rdy;
    wire timer_int_req, timer1_int_req, pario_int_req, uart_int_req;

    // INTCAUSE bits
    localparam integer IRQ_TIMER0 = 0;
    localparam integer IRQ_TIMER1 = 1;
    localparam integer IRQ_PARIO  = 2;
    localparam integer IRQ_UART   = 3;

    // interrupt cause wiring (for sw interrupts)
    // currently we use hw vectored interrupts
    // here for legacy reasons, it can still be used if desired
    wire [7:0] int_cause;
    assign int_cause[IRQ_TIMER0] = timer_int_req;
    assign int_cause[IRQ_TIMER1] = timer1_int_req; 
    assign int_cause[IRQ_PARIO]  = pario_int_req;
    assign int_cause[IRQ_UART]   = uart_int_req;
    assign int_cause[7:4] = 4'b0;

    // read vectors
    wire [15:0] timer_rdata, timer1_rdata, pario_rdata, uart_rdata, irq_rdata;

    // timer0 
    timer16 u_timer (
        .clk(clk),
        .rst(rst),
        .sel(sel_timer),
        .we(we),
        .re(re),
        .addr(addr[2:1]), // two LSBs for reg index
        .wdata(wdata),
        .rdata(timer_rdata),
        .rdy(timer_rdy),
        .int_req(timer_int_req)
    );

    // timer1 (higher priority timer for nesting tests)
    timerH u_timer1 (
        .clk(clk),
        .rst(rst),
        .sel(sel_timer1),
        .we(we),
        .re(re),
        .addr(addr[2:1]), // two LSBs for reg index
        .wdata(wdata),
        .rdata(timer1_rdata),
        .rdy(timer1_rdy),
        .int_req(timer1_int_req)
    );

    // pario 
    pario u_pario (
        .clk(clk),
        .rst(rst),
        .sel(sel_pario),
        .we(we),
        .re(re),
        .addr(addr[1:0]), // two LSBs for reg index
        .wdata(wdata),
        .rdata(pario_rdata),
        .rdy(pario_rdy),
        .i(par_i),
        .o(par_o),
        .int_req(pario_int_req)
    );

`ifdef SIM
    localparam integer UART_BAUD_RATE = 2_000_000;
`else
    localparam integer UART_BAUD_RATE = 115200;
`endif

    uart_mmio #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(UART_BAUD_RATE)
    ) u_uart (
        .clk(clk),
        .rst(rst),
        .sel(sel_uart),
        .we(we),
        .re(re),
        .addr(addr[1:0]),
        .wdata(wdata),
        .rdata(uart_rdata),
        .rdy(uart_rdy),
        .rx_in(uart_rx),
        .tx_out(uart_tx),
        .irq_req(uart_int_req)
    );

    // two timers + irq reg => rdy logic
    assign rdy = 
            sel_timer  ? timer_rdy  : 
            sel_timer1 ? timer1_rdy :
            sel_pario  ? pario_rdy  :
            sel_uart   ? uart_rdy   :
            sel_irq    ? irq_rdy    : 
                         1'b1;

    // read mux
    assign rdata = (sel_timer && re)  ? timer_rdata  : 
                   (sel_timer1 && re) ? timer1_rdata :
                   (sel_pario  && re) ? pario_rdata  :
                   (sel_uart   && re) ? uart_rdata   :
                   (sel_irq   && re)  ? irq_rdata    :  
                                        16'h0000;

    // Instantiate the interrupt controller
    irq_ctrl u_irq_ctrl (
        .clk(clk), .rst(rst),
        .sel(sel_irq),
        .we(we),
        .re(re),
        .wdata(wdata),
        .rdata(irq_rdata),
        .rdy(irq_rdy),
        .addr(addr[3:1]),

        .src_irq(int_cause),
        .in_irq(in_irq),
        .int_en(int_en),
        .irq_take(irq_take),
        .irq_vector(irq_vector),
        .irq_ret(irq_ret)
    );

endmodule // periph_bus
