module fifo_dualport_with_latency #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
) (
    input  logic             clk_i,
    input  logic             rst_i,
    input  logic             wr_en_i,
    input  logic             rd_en_i,
    input  logic [WIDTH-1:0] data_i,
    output logic [WIDTH-1:0] data_o,
    output logic             empty_o,
    output logic             full_o
);

    // ------------------------------------------------------------------------
    // Local parameters
    // ------------------------------------------------------------------------

    localparam W_PTR   = $clog2(DEPTH);
    localparam W_CNT   = $clog2(DEPTH + 1);
    localparam MAX_PTR = DEPTH - 1;

    // ------------------------------------------------------------------------
    // Local signals
    // ------------------------------------------------------------------------

    logic [W_PTR-1:0] wr_ptr_next;
    logic [W_PTR-1:0] rd_ptr_next;
    logic [W_PTR-1:0] wr_ptr_ff;
    logic [W_PTR-1:0] rd_ptr_ff;
    logic             empty_next;
    logic             full_next;
    logic [W_CNT-1:0] elem_cnt_next;
    logic [W_CNT-1:0] elem_cnt;

    logic             sram_read;
    logic             prefetch_next;
    logic             prefetch_ff;

    // ------------------------------------------------------------------------
    // SRAM
    // ------------------------------------------------------------------------

    assign prefetch_next = (elem_cnt_next == W_CNT'(1'b1)) && wr_en_i;
    assign sram_read     = prefetch_ff || (rd_en_i && !empty_next);

    always_ff @(posedge clk_i)
        if (rst_i)
            prefetch_ff <= '0;
        else
            prefetch_ff <= prefetch_next;


    sram_dualport #(
        .WIDTH ( WIDTH ),
        .DEPTH ( DEPTH )
    ) sram_dualport (
        .clk_i   ( clk_i     ),
        .wen_i   ( wr_en_i   ),
        .ren_i   ( sram_read ),
        .waddr_i ( wr_ptr_ff ),
        .raddr_i ( rd_ptr_ff ),
        .data_i  ( data_i    ),
        .data_o  ( data_o    )
    );

    // ------------------------------------------------------------------------
    // Main FIFO logic
    // ------------------------------------------------------------------------

    always_comb begin
        elem_cnt_next = elem_cnt;

        if ( wr_en_i && !rd_en_i)
            elem_cnt_next = elem_cnt_next + 1'b1;
        else if (!wr_en_i &&  rd_en_i)
            elem_cnt_next = elem_cnt_next - 1'b1;
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            elem_cnt <= '0;
        else
            elem_cnt <= elem_cnt_next;

    always_comb begin
        wr_ptr_next = wr_ptr_ff;
        rd_ptr_next = rd_ptr_ff;

        if (wr_en_i)
            wr_ptr_next = (wr_ptr_ff == MAX_PTR) ? '0 : wr_ptr_ff + 1'b1;

        if (sram_read)
            rd_ptr_next = (rd_ptr_ff == MAX_PTR) ? '0 : rd_ptr_ff + 1'b1;
    end

    always_ff @(posedge clk_i)
        if (rst_i)
            wr_ptr_ff <= '0;
        else
            wr_ptr_ff <= wr_ptr_next;

    always_ff @(posedge clk_i)
        if (rst_i)
            rd_ptr_ff <= '0;
        else
            rd_ptr_ff <= rd_ptr_next;

    assign empty_next = (elem_cnt_next == '0) || prefetch_next;
    assign full_next  = elem_cnt_next == DEPTH;

    always_ff @(posedge clk_i)
        if (rst_i) begin
            empty_o <= '1;
            full_o  <= '0;
        end else begin
            empty_o <= empty_next;
            full_o  <= full_next;
        end

endmodule
