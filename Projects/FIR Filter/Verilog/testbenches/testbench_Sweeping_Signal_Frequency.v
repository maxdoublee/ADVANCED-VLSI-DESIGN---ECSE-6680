//FIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// Sweeping Signal Frequency Testing

`timescale 1ns / 1ps

module testbench_freq_sweep_tb;

parameter DATA_WIDTH = 16;
parameter CLK_PERIOD = 20.833; // Clock period in ns for a 48kHz sampling rate
parameter SWEEP_STEPS = 10;   // Number of steps in frequency sweep
parameter FS = 48000;         // Sampling frequency in Hz
parameter LUT_SIZE = 960;     // Size of your sine wave LUT
parameter START_FREQ = 1000;  // Start frequency in Hz for the sweep
parameter END_FREQ = 2000;    // End frequency in Hz for the sweep
parameter N = 32;             // Number of bits in phase accumulator

reg clk = 0, rst = 1;
real freq;
real freq_step = (END_FREQ - START_FREQ) / (SWEEP_STEPS - 1);
integer sweep_idx = 0;
reg [31:0] freq_control;

wire signed [DATA_WIDTH-1:0] sine_wave_out;
wire signed [15:0] noise_signal;
wire signed [15:0] sine_wave_with_noise;
wire signed [31:0] fir_out;

// Instantiate the sine wave generator with variable frequency control
sine_wave_generator_variable_freq sine_gen(
    .clk(clk),
    .reset(rst),
    .freq_control(freq_control),
    .sine_wave_out(sine_wave_out)
);

lfsr_noise_generator noise_gen(
    .clk(clk),
    .reset(rst),
    .noise_out(noise_signal)
);

fir_filter fir(
    .clk(clk),
    .rst(rst),
    .data_in(sine_wave_with_noise),
    .data_out(fir_out)
);

assign sine_wave_with_noise = sine_wave_out + noise_signal;

// Clock generation
always #(CLOCK_PERIOD/2) clk = ~clk;

initial begin
    rst = 1;
    #100 rst = 0;  // Release reset after a brief period
    
    for (sweep_idx = 0; sweep_idx < SWEEP_STEPS; sweep_idx = sweep_idx + 1) begin
        // Adjusting freq_control for each sweep step
        freq_control = ((START_FREQ + sweep_idx * freq_step) * (2**N)) / FS;
        #1000;  // Wait enough time for the system to stabilize at this frequency
    end
    $finish;
end

integer file_id;
initial begin
    file_id = $fopen("fir_freq_sweep_output.txt", "w");
    @(posedge clk) begin
        $fwrite(file_id, "%d\n", fir_out);  // Capture output every clock cycle
    end
    $fclose(file_id);
end

endmodule
