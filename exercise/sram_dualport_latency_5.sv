module sram_dualport_latency_5 #(
    parameter WIDTH  = 8,
    parameter DEPTH  = 8,
    parameter ADDR_W = $clog2(DEPTH)
) (
    input  logic              clk_i,
    input  logic              rst_i,
    input  logic              wen_i,
    input  logic              ren_i,
    input  logic [ADDR_W-1:0] waddr_i,
    input  logic [ADDR_W-1:0] raddr_i,
    input  logic [ WIDTH-1:0] data_i,
    output logic [ WIDTH-1:0] data_o,
    output logic              vld_o
);

    localparam LATENCY = 5;

    // We already have 1 cycle delay, so we have to delay for 1 less
    logic [  WIDTH-1:0] shift_reg [LATENCY-1];
    logic [LATENCY-1:0] shift_vld;

    logic [  WIDTH-1:0] sram      [DEPTH];
    logic [  WIDTH-1:0] sram_out;

    always_ff @(posedge clk_i) begin
        if (wen_i) begin
            sram[waddr_i] <= data_i;
        end
    end

    always_ff @(posedge clk_i) begin
        if (ren_i) begin
            sram_out <= sram[raddr_i];
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            shift_vld <= LATENCY'(0);
        end else begin
            shift_vld <= { shift_vld[LATENCY-2:0], ren_i};
        end
    end

    always_ff @(posedge clk_i) begin
        if (shift_vld[0])
            shift_reg[0] <= sram_out;

        for (int i = 1; i < LATENCY - 1; i++) begin
            if (shift_vld[i]) begin
                shift_reg[i] <= shift_reg[i-1];
            end
        end
    end

    assign vld_o  = shift_vld[LATENCY-1];
    assign data_o = shift_reg[LATENCY-2];

endmodule
