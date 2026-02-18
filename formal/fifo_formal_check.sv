// WARNING: this code is for formal checking, not for synthesis

`ifdef FORMAL

module fifo_formal_check #(
    parameter WIDTH = 10,
    parameter DEPTH = 10
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

    logic [WIDTH-1:0] ref_data;
    logic             ref_empty;
    logic             ref_full;

    `ifdef DUALPORT_WITH_LATENCY

        fifo_dualport_with_latency #(
            .WIDTH ( WIDTH ),
            .DEPTH ( DEPTH )
        ) fifo_dualport_with_latency (
            .clk_i   ( clk_i   ),
            .rst_i   ( rst_i   ),
            .wr_en_i ( wr_en_i ),
            .rd_en_i ( rd_en_i ),
            .data_i  ( data_i  ),
            .data_o  ( data_o  ),
            .empty_o ( empty_o ),
            .full_o  ( full_o  )
        );

    `elsif DUALPORT

        fifo_dualport #(
            .WIDTH ( WIDTH ),
            .DEPTH ( DEPTH )
        ) fifo_dualport (
            .clk_i   ( clk_i   ),
            .rst_i   ( rst_i   ),
            .wr_en_i ( wr_en_i ),
            .rd_en_i ( rd_en_i ),
            .data_i  ( data_i  ),
            .data_o  ( data_o  ),
            .empty_o ( empty_o ),
            .full_o  ( full_o  )
        );

    `elsif SINGLEPORT

        fifo_singleport #(
            .WIDTH (WIDTH ),
            .DEPTH (DEPTH )
        ) fifo_singleport (
            .clk_i   ( clk_i   ),
            .rst_i   ( rst_i   ),
            .wr_en_i ( wr_en_i ),
            .rd_en_i ( rd_en_i ),
            .data_i  ( data_i  ),
            .data_o  ( data_o  ),
            .empty_o ( empty_o ),
            .full_o  ( full_o  )
        );

    `else

        $error("No configuration. Define FIFO for test.");

    `endif

    // We assume that DFF FIFO actually works and SRAM-based solutions
    // should have the same data on output
    fifo_dff #(
        .WIDTH ( WIDTH ),
        .DEPTH ( DEPTH )
    ) fifo_dff (
        .clk_i         ( clk_i        ),
        .rst_i         ( rst_i        ),
        .wr_en_i       ( wr_en_i      ),
        .rd_en_i       ( rd_en_i      ),
        .data_i        ( data_i       ),
        .data_o        ( ref_data     ),
        .empty_o       ( ref_empty    ),
        .full_o        ( ref_full     ),
        .almost_full_o (              )
    );

        logic [$clog2(DEPTH+1)-1:0] formal_cnt;
        logic was_full;

        initial assume(rst_i);

        // Behavioural code, no point in always_ff
        always @(posedge clk_i) begin
            if (!rst_i) begin

                if (wr_en_i && !rd_en_i)
                    formal_cnt <= formal_cnt + 1'b1;
                else if (!wr_en_i && rd_en_i)
                    formal_cnt <= formal_cnt - 1'b1;

                if (full_o && !rd_en_i)
                    assume(!wr_en_i);

                if (empty_o)
                    assume(!rd_en_i);

                if (empty_o)
                    `ifdef DUALPORT_WITH_LATENCY
                        a_empty: assert(formal_cnt == '0 ||
                                       ($past(formal_cnt == 1 && rd_en_i && wr_en_i)) ||
                                       ($past(formal_cnt == '0 && wr_en_i)));
                    `else
                        a_empty: assert(formal_cnt == '0);
                    `endif

                if (full_o) begin
                    a_full: assert(formal_cnt == DEPTH);
                    was_full <= '1;
                end

                if (!empty_o)
                    a_match_model: assert(data_o == ref_data);

                c_empty: cover(empty_o);
                `ifdef DUALPORT_WITH_LATENCY
                    c_empty_rw: cover(empty_o && formal_cnt == 1);
                `endif
                c_full: cover(full_o);
                c_empty_after_full: cover(was_full && empty_o);

            end else begin

                formal_cnt <= '0;
                was_full   <= '0;
                c_reset: cover(rst_i);

            end
        end

endmodule

`endif
