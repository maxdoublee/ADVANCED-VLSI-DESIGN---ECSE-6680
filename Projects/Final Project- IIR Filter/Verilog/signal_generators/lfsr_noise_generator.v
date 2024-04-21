//FIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// LFSR Noise Generator

module lfsr_noise_generator(
    input wire clk,
    input wire reset,
    output reg [15:0] noise_out
);

// LFSR with a 16-bit width
reg [15:0] lfsr_reg;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Initialize LFSR with a non-zero value
        lfsr_reg <= 16'hACE1; // Arbitrary seed, can be any non-zero value
    end else begin
        // Update LFSR value on each clock cycle
        // Polynomial: x^16 + x^14 + x^13 + x^11 + 1
        // Feedback taken from the XOR of bits 0, 2, 3, and 5
        lfsr_reg <= {lfsr_reg[14:0], lfsr_reg[15] ^ lfsr_reg[13] ^ lfsr_reg[12] ^ lfsr_reg[10]};
    end
end

// Output the current LFSR value as the noise signal
always @(posedge clk) begin
    noise_out <= lfsr_reg;
end

endmodule
