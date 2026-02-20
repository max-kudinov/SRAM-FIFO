module fifo_dualport_with_pipelined_sram #(
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

    sram_dualport_latency_5 #(
        .WIDTH ( WIDTH ),
        .DEPTH ( DEPTH )
    ) i_mem (
        .clk_i   (),
        .rst_i   (),
        .wen_i   (),
        .ren_i   (),
        .waddr_i (),
        .raddr_i (),
        .data_i  (),
        .data_o  (),
        .vld_o   ()
    );

    // Remove this when you start working on the exercise
    initial begin
        $error("Not implemented");
        $finish;
    end

endmodule
