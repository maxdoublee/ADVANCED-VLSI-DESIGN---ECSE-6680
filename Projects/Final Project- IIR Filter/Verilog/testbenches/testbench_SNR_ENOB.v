//IIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// SNR and ENOB testing

`timescale 1ns / 1ps

module testbench_SNR_ENOB_IIR;
    parameter DATA_WIDTH = 16;
    parameter CLOCK_PERIOD = 20.833; // Clock period in ns for a 48kHz sampling rate
    parameter SIMULATION_TIME = 100000; 

    reg clk, rst;
    wire signed [DATA_WIDTH-1:0] sine_wave_out;
    wire signed [15:0] noise_signal; // Noise signal
    wire signed [15:0] sine_wave_with_noise; // Sine wave combined with noise
    wire signed [31:0] data_out;

    // Instantiate the LFSR 
    lfsr_noise_generator lfsr (
        .clk(clk),
        .reset(rst),
        .noise_out(noise_signal)
    );

    // Instantiate the Sine Wave Generator
    sine_wave_generator swg (
        .clk(clk),
        .reset(rst),
        .sine_wave_out(sine_wave_out)
    );

    // Combine the sine wave and noise
    assign sine_wave_with_noise = sine_wave_out + noise_signal;

    iir_filter iir (
        .clk(clk),
        .rst(rst),
        .data_in(sine_wave_with_noise),
        .data_out(data_out)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Initialize and run the test
    initial begin
        rst = 1;
        #20 rst = 0; // Release reset after 20 ns

        // Run for a specified simulation time then finish
        #(SIMULATION_TIME) $finish;
    end

    // Capture IIR filter's output for external SNR and ENOB analysis
    integer file_id; 
    initial begin
        file_id = $fopen("output_signals.txt", "w");
        forever @(posedge clk) begin
            $fwrite(file_id, "%d\n", data_out); // Capture output every clock cycle
        end
        $fclose(file_id);
    end

endmodule
