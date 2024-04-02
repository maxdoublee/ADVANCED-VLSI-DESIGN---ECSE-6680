//FIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// Total Harmonic Distortion

`timescale 1ns / 1ps

module thd_testbench;

// Parameters for the test
parameter DATA_WIDTH = 16;
parameter CLK_PERIOD = 20.833; // Clock period in ns for a 48kHz sampling rate
parameter SAMPLES = 48000; // Adjust this based on the length of the test

// Test signals
reg clk = 0;
reg rst = 1;
wire signed [DATA_WIDTH-1:0] sine_wave_out;
reg [15:0] amplitude_control;
wire signed [31:0] filtered_output;

// Generate the clock signal
always #(CLK_PERIOD/2) clk = ~clk;

// Instantiate the sine wave generator
sine_wave_generator sine_gen(
    .clk(clk), 
    .reset(rst), 
    .amplitude(amplitude_control), 
    .sine_wave_out(sine_wave_out)
);

// Instantiate your FIR filter
fir_filter fir(.clk(clk), .rst(rst), .data_in(sine_wave_out), .data_out(filtered_output));

initial begin
    // Initialize the simulation
    rst <= 1;
    #100; // Wait for 100ns for global reset to settle
    rst <= 0;

    // Run the simulation for a predefined number of samples
    repeat (SAMPLES) @(posedge clk);
    $finish; // End the simulation
end

// Export the filtered output for THD analysis
integer file_id;
initial begin
    file_id = $fopen("filtered_output_data.txt", "w");
    @(negedge rst); // Wait for the reset to be released
    forever @(posedge clk) begin
        $fwrite(file_id, "%d\n", filtered_output); // Write the filtered output at every clock cycle
    end
    $fclose(file_id); // Close the file at the end of the simulation
end

endmodule
