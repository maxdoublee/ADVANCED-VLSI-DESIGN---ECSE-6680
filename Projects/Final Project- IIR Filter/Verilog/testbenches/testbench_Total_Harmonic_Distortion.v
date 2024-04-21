//IIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// Total Harmonic Distortion

`timescale 1ns / 1ps

module thd_testbench_IIR;

// Parameters for the test
parameter DATA_WIDTH = 16;
parameter CLK_PERIOD = 20.833; // Clock period in ns for a 48kHz sampling rate
parameter SAMPLES = 48000; 

// Test signals
reg clk;
reg rst;
wire signed [DATA_WIDTH-1:0] sine_wave_out;
reg [15:0] amplitude_control;
wire signed [31:0] filtered_output;

// THD Calculation Variables
real total_power = 0, harmonic_power = 0, thd_value;
integer count = 0;

// Generate the clock signal
always #(CLK_PERIOD/2) clk = ~clk;

// Instantiate the sine wave generator
sine_wave_generator sine_gen(
    .clk(clk), 
    .reset(rst), 
    .amplitude(amplitude_control), 
    .sine_wave_out(sine_wave_out)
);

iir_filter iir (
    .clk(clk), 
    .rst(rst), 
    .data_in(sine_wave_out), 
    .data_out(filtered_output)
);

always @(posedge clk) begin
    if (!rst) begin
        if (count < SAMPLES) begin
            total_power = total_power + filtered_output * filtered_output;
            if (count % 4800 == 0) begin
                harmonic_power = harmonic_power + filtered_output * filtered_output;
            end
            count = count + 1;
        end else if (count >= SAMPLES) begin
            thd_value = sqrt(harmonic_power/total_power);
            $display("Calculated THD: %f", thd_value);
            $finish;
        end
    end
end

initial begin
    $monitor("Time=%t, Output=%d, THD=%f", $time, filtered_output, thd_value); 
    // Initialize the simulation
    rst <= 1;
    #100; // Wait for 100ns for global reset to settle
    rst <= 0;
    #20 amplitude_control = 'h3FFF; // Example to set initial amplitude
    repeat (SAMPLES) @(posedge clk);
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
