//FIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// FIR filter implementation with L=2 Parallel Processing

module fir_filter (
    input clk,
    input rst,
    input signed [15:0] data_in, 
    output reg signed [31:0] data_out
);

parameter N = 100; // Number of taps
parameter COEFFICIENT_WIDTH = 16; // Coefficient bit width
parameter N_HALF = N / 2; // Half the number of taps for L=2 parallel processing

// Coefficient storage
reg signed [COEFFICIENT_WIDTH-1:0] coefficients[N-1:0];

initial begin
    $readmemh("C:/Users/mdest/OneDrive/Documents/VLSI/FIR Filter/MATLAB/hardware_inputs/quantized_coefficients.txt", coefficients);
end

// FIR filter internal signals
reg signed [15:0] shift_reg[N-1:0]; 
reg signed [31:0] mult[N-1:0];
reg [31:0] mult_reg[N-1:0]; // Pipeline stage after multiplication
reg [31:0] accum_reg_half1, accum_reg_half2; // Pipeline stage for accumulation in each half 

integer i;

// Shift input samples and perform multiplication
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset logic for registers
        for (i = 0; i < N; i = i + 1) begin
            shift_reg[i] <= 0;
            mult[i] <= 0;
         end
    end else begin
        // Shift input samples through the shift register
        shift_reg[0] <= data_in;
        for (i = 1; i < N; i = i + 1) begin
            shift_reg[i] <= shift_reg[i-1];
        end

        // Perform multiplication
        for (i = 0; i < N; i = i + 1) begin
            mult[i] = shift_reg[i] * coefficients[i];
        end
    end
end

// Define a new counter
reg [7:0] counter; 

// Reset and increment the counter
always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 0;
    end else begin
        counter <= counter + 1;
        if (counter >= N-1) begin
            counter <= 0; // Reset the counter after reaching the last tap
        end
    end
end

// Accumulate results with pipelining for both halves and combine results
always @(posedge clk) begin
    if (rst) begin
        // Reset logic for accumulators and data output
        for (i = 0; i < N; i = i + 1) begin
            mult_reg[i] <= 0;
        end
        accum_reg_half1 <= 0;
        accum_reg_half2 <= 0;
        data_out <= 0; 
    end else begin
        // Pipeline the multiplication results and accumulation
        for (i = 0; i < N; i = i + 1) begin
            mult_reg[i] <= mult[i];
        end
        accum_reg_half1 <= mult_reg[0];
        accum_reg_half2 <= mult_reg[N_HALF];
        
        for (i = 1; i < N_HALF; i = i + 1) begin
            accum_reg_half1 <= accum_reg_half1 + mult_reg[i];
        end
        for (i = N_HALF + 1; i < N; i = i + 1) begin
            accum_reg_half2 <= accum_reg_half2 + mult_reg[i];
        end
        
        // Combine results from both halves when the counter indicates the last tap
        if (counter == N-1) begin
            data_out <= accum_reg_half1 + accum_reg_half2;
        end
    end
end

endmodule