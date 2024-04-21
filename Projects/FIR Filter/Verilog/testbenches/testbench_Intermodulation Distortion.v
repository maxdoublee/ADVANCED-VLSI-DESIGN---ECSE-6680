//FIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// Intermodulation Distortion

`timescale 1ns / 1ps

module imd_testbench;

parameter DATA_WIDTH = 16;
parameter CLK_PERIOD = 20.833; // Clock period in ns for 48 kHz sampling rate
parameter SAMPLES = 48000; // Number of samples for the analysis period

reg clk;
reg rst;
wire signed [DATA_WIDTH-1:0] sine_wave_1_out, sine_wave_2_out;
reg [15:0] amplitude_control;
wire signed [DATA_WIDTH-1:0] imd_test_signal;
wire signed [31:0] filtered_output;

sine_wave_generator sine_gen1(
    .clk(clk), 
    .reset(rst), 
    .amplitude(amplitude_control), 
    .sine_wave_out(sine_wave_1_out)
);

sine_wave_generator sine_gen2(
    .clk(clk), 
    .reset(rst), 
    .amplitude(amplitude_control), 
    .sine_wave_out(sine_wave_2_out)
);

// Summation of two sine waves to create IMD test signal
assign imd_test_signal = sine_wave_1_out + sine_wave_2_out;

// FIR filter instantiation
fir_filter fir (.clk(clk), .rst(rst), .data_in(imd_test_signal), .data_out(filtered_output));

// Clock generation
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    rst <= 1;
    #100; // Wait for 100ns for global reset to settle
    rst <= 0;
    // Run the simulation for a specific period to gather enough data
    repeat (SAMPLES) @(posedge clk);
    $finish;
end

// Export the filtered output data for IMD analysis
integer file_id;
initial begin
    file_id = $fopen("imd_test_output_data.txt", "w");
    @(negedge rst); // Wait for the reset to be released
    forever @(posedge clk) begin
        $fwrite(file_id, "%d\n", filtered_output);
    end
    $fclose(file_id);
end

endmodule
