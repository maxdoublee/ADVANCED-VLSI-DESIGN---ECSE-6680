//FIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// Dynamic Range Testing

`timescale 1ns / 1ps

module testbench_Dynamic_Range;

parameter DATA_WIDTH = 16;
parameter CLK_PERIOD = 20.833; // Clock period in ns for a 48kHz sampling rate
parameter SIMULATION_TIME = 100000; // Adjust based on needs
parameter AMPLITUDE_STEPS = 10; // Number of amplitude steps for dynamic range testing

reg clk, rst;
reg [15:0] amplitude_control;
wire signed [DATA_WIDTH-1:0] sine_wave_out;
wire signed [15:0] noise_signal; // Noise signal
wire signed [15:0] sine_wave_with_noise; // Sine wave combined with noise
wire signed [31:0] data_out;

// Instantiate noise generator
lfsr_noise_generator lfsr(
    .clk(clk),
    .reset(rst),
    .noise_out(noise_signal)
);

// Instantiate sine wave generator with amplitude control
sine_wave_generator swg (
    .clk(clk),
    .reset(rst),
    .amplitude(amplitude_control), // Updated to use amplitude control
    .sine_wave_out(sine_wave_out)
);

// Combine the sine wave and noise
assign sine_wave_with_noise = sine_wave_out + noise_signal;

// Instantiate FIR filter
fir_filter fir (
    .clk(clk),
    .rst(rst),
    .data_in(sine_wave_with_noise),
    .data_out(data_out)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLOCK_PERIOD/2) clk = ~clk;
end

// Test initialization and dynamic range testing
integer i;
initial begin
    rst = 1;
    #20 rst = 0; // Release reset after 20 ns
    
    // Dynamic range testing: Cycle through amplitude levels
    for (i = 0; i < AMPLITUDE_STEPS; i = i + 1) begin
        amplitude_control = (i * (65535 / AMPLITUDE_STEPS)); // Scale amplitude linearly
        #10000; // Wait for system to stabilize at this amplitude level
    end
    
    $finish; // End simulation
end

// File output for external analysis (MATLAB or Python)
integer file_id;
initial begin
    file_id = $fopen("output_signals_dynamic_range.txt", "w");
    forever @(posedge clk) begin
        $fwrite(file_id, "%d\n", data_out); // Capture output every clock cycle
    end
    $fclose(file_id);
end

endmodule