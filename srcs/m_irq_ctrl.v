module irq_ctrl (
    input  wire        clk,
    input  wire        rst,
    input  wire        sel, 
    input  wire        we,
    input  wire        re,
    input  wire [15:0] wdata,
    output reg  [15:0] rdata,
    input  wire [2:0]  addr,
    output wire        rdy,

    input  wire [7:0]  src_irq,     // raw interrupt lines (level)
    input  wire        in_irq,      // CPU in ISR
    input  wire        int_en,      // CPU interrupt enable
    input  wire        irq_ret,     // from CPU: return from interrupt

    output wire        irq_take,    // to CPU: take interrupt now
    output reg  [15:0] irq_vector   // to CPU: vector PC
);

    // MMIO ready (single-cycle)
    assign rdy = sel;     // single-cycle access when selected

    // Pending/mask bookkeeping
    reg [7:0] pending;    // latched pending interrupts
    reg [7:0] mask;       // interrupt enable mask
    reg [7:0] servicing;  // currently serviced source (prevents re-latch)

    // masked level requests (new or still asserted)
    wire [7:0] masked = (src_irq & mask) & ~servicing;

    // any pending or newly asserted
    wire [7:0] next_pend = pending | masked;
    wire       any_pend  = |next_pend;

    reg [2:0] sel_idx;
    reg [7:0] sel_onehot;

    // Nesting depth / priority tracking
    // decide to take interrupt when: something pending, enabled, priority greater than current
    localparam DEPTH = 2; // max interrupt nesting depth
    reg [DEPTH-1:0] depth;
    reg [2:0] pri_stack [DEPTH-1:0]; // store priority level (irq line) at each depth

    // effective depth for same cycle irq_take decision
    // when irq_ret is asserted, consider depth-1 for priority comparison
    wire [DEPTH-1:0] depth_eff = (irq_ret && (depth != 0)) ? (depth - 1'b1) : depth;
    wire [2:0] cur_pri = (depth_eff == 0) ? 3'd0 : pri_stack[depth_eff - 1];

    wire can_preempt = (depth_eff == 0) ? 1'b1 : (sel_idx > cur_pri);
    
    assign irq_take = any_pend & int_en & can_preempt; // allow nested IRQs

    // Fixed priority encoder (highest index wins)
    // simple fixed priority-based encoder on next_pend[3:0]
    // the higher the irq line number, the greater the priority
    always @(*) begin 
        sel_idx    = 3'd0;
        sel_onehot = 8'b0000_0000;
        casex (next_pend[3:0])
            4'b1xxx: begin sel_idx = 3'd3; sel_onehot = 8'b0000_1000; end // UART_RX
            4'b01xx: begin sel_idx = 3'd2; sel_onehot = 8'b0000_0100; end // PARIO 
            4'b001x: begin sel_idx = 3'd1; sel_onehot = 8'b0000_0010; end // TIMER1
            4'b0001: begin sel_idx = 3'd0; sel_onehot = 8'b0000_0001; end // TIMER0
            default: begin sel_idx = 3'd0; sel_onehot = 8'b0000_0000; end
        endcase
    end

    // Pending computation (sources + MMIO)
    reg [7:0] pending_next;

    always @(*) begin
        // start from OR of old pending and newly asserted & masked sources
        pending_next = next_pend;

        // if CPU takes an interrupt, clear that source's pending bit
        if (irq_take)
            pending_next = pending_next & ~sel_onehot;

        // apply MMIO writes on top
        if (sel && we) begin
            case (addr)
                3'b100: pending_next = pending_next |  wdata[7:0]; // IRQ_FORCE
                3'b110: pending_next = pending_next & ~wdata[7:0]; // IRQ_CLEAR
                default: ;
            endcase
        end
    end

    // sequential state update
    always @(posedge clk) begin
        if (rst) begin
            pending <= 8'h00;
        end else begin
            pending <= pending_next;
        end
    end

    // Servicing latch (blocks re-latching while source is active)
    // latch taken IRQs with sel_onehot, clear when source de-asserts
    always @(posedge clk) begin
        if (rst) begin
            servicing <= 8'h00;
        end else begin
            // keep bits set only while the raw request is still asserted
            servicing <= (servicing & src_irq);
            if (irq_take) begin
                servicing <= (servicing & src_irq) | sel_onehot;
            end
        end
    end

    // Vector generation
    // generate irq_vector based on selected source index
    always @(*) begin
        if (irq_take) begin
            case (sel_idx)
                3'd0: irq_vector = 16'h0020;  // TIMER0
                3'd1: irq_vector = 16'h0040;  // TIMER1
                3'd2: irq_vector = 16'h0060;  // PARIO
                3'd3: irq_vector = 16'h0080;  // UART_RX
                default: irq_vector = 16'hFFFF;
            endcase
        end else begin
            irq_vector = 16'hFFFF;
        end
    end

    // Depth + priority stack update
    integer k; 
    always @(posedge clk) begin
        if (rst) begin
            depth <= {DEPTH{1'b0}}; 
            for (k = 0; k < DEPTH; k = k + 1) begin
                pri_stack[k] <= 3'd0;
            end
        end else begin
            case ({irq_take, irq_ret}) 
                2'b10: begin
                    if (depth < DEPTH) begin
                        pri_stack[depth] <= sel_idx; 
                        depth <= depth + 1'b1;
                    end
                end
                2'b01: begin
                    if (depth > 0) begin
                        depth <= depth - 1'b1;
                    end
                end
                2'b11: begin
                    if (depth == 0) begin
                        pri_stack[0] <= sel_idx;
                        depth <= 1'b1;
                    end else begin
                        pri_stack[depth-1] <= sel_idx; // replace current top, depth unchanged
                    end
                end
                default: ; 
            endcase
        end
    end


    // simple mask register: all enabled for now, MMIO writable
    always @(posedge clk) begin
        if (rst)
            mask <= 8'hFF;
        else if (sel && we && addr == 3'b010)
            mask <= wdata[7:0]; // IRQ_MASK
    end

    // MMIO readback
    always @(posedge clk) begin
        if (rst) begin
            rdata <= 16'h0000;
        end else if (sel && re) begin
            case (addr)
                3'b000: rdata <= {8'h00, pending}; // IRQ_PEND
                3'b010: rdata <= {8'h00, mask};    // IRQ_MASK
                default: rdata <= 16'h0000;
            endcase
        end else begin
            rdata <= 16'h0000;
        end
    end

endmodule // irq_ctrl
