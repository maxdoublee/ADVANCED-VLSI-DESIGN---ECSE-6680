// IIR Filter Design and Implementation
// Max Destil
// RIN: 662032859

// IIR filter implementation with advanced pipelining and multi-stage parallel processing

module iir_filter (
    input clk,
    input rst,
    input signed [15:0] data_in, 
    output reg signed [31:0] data_out
);

parameter ORDER = 10;
parameter COEFFICIENT_WIDTH = 16;

// Coefficients for feedforward (b) and feedback (a) paths
reg signed [COEFFICIENT_WIDTH-1:0] b[ORDER-1:0];
reg signed [COEFFICIENT_WIDTH-1:0] a[ORDER-1:0];

// States (Delays for both x[n-k] and y[n-k])
reg signed [15:0] x_reg[ORDER-1:0];
reg signed [31:0] y_reg[ORDER-1:0];

// Intermediate pipeline stages
reg signed [31:0] mult_results_b[ORDER-1:0], mult_results_a[ORDER-1:0];
reg signed [31:0] sum_stage1[ORDER/2-1:0], sum_stage2[ORDER/2-1:0];

initial begin
    $readmemh("C:/Users/mdest/OneDrive/Documents/Advanced_VLSI/ADVANCED-VLSI-DESIGN---ECSE-6680/Projects/Final Project- IIR Filter/MATLAB/design/coeff_b.txt", b);
    $readmemh("C:/Users/mdest/OneDrive/Documents/Advanced_VLSI/ADVANCED-VLSI-DESIGN---ECSE-6680/Projects/Final Project- IIR Filter/MATLAB/design/coeff_a.txt", a);
end

integer i;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < ORDER; i = i + 1) begin
            x_reg[i] <= 0;
            y_reg[i] <= 0;
            mult_results_b[i] <= 0;
            mult_results_a[i] <= 0;
        end
        for (i = 0; i < ORDER/2; i = i + 1) begin
            sum_stage1[i] <= 0;
            sum_stage2[i] <= 0;
        end
        data_out <= 0;
    end else begin
        x_reg[0] <= data_in;
        for (i = ORDER-1; i > 0; i = i - 1) begin
            x_reg[i] <= x_reg[i-1];
            y_reg[i] <= y_reg[i-1];
        end

        for (i = 0; i < ORDER; i = i + 1) begin
            mult_results_b[i] <= b[i] * x_reg[i];
            mult_results_a[i] <= a[i] * y_reg[i];
        end

        // Parallel sum calculation
        for (i = 0; i < ORDER/2; i = i + 1) begin
            sum_stage1[i] <= mult_results_b[2*i] + mult_results_b[2*i+1] - (mult_results_a[2*i] + mult_results_a[2*i+1]);
        end

        // Second stage of addition
        if (ORDER > 2) begin
            sum_stage2[0] <= sum_stage1[0] + sum_stage1[1];
            for (i = 1; i < ORDER/2 - 1; i = i + 1) begin
                sum_stage2[i] <= sum_stage2[i-1] + sum_stage1[i+1];
            end
            data_out <= sum_stage2[ORDER/2-2];
        end else begin
            data_out <= sum_stage1[0];
        end
        y_reg[0] <= data_out;
    end
end

endmodule