// IIR Filter Design and Implementation
// Max Destil
// RIN: 662032859

// Transient Response Testing

`timescale 1ns / 1ps

module transient_response_tb_IIR;

parameter DATA_WIDTH = 16;
parameter CLK_PERIOD = 20.833; // Clock period in ns for a 48kHz sampling rate
parameter FILTER_TAPS = 100;
parameter IMPULSE_DURATION = 1; // Number of clock cycles for impulse
parameter TOTAL_DURATION = 10000; 
parameter SOME_THRESHOLD = 10; // Define a threshold for settling

// Inputs
reg clk = 0;
reg rst;
reg signed [DATA_WIDTH-1:0] data_in = 0;
integer count = 0; // Counter to keep track of the test duration

// Outputs
wire signed [31:0] data_out;

// Instantiate the IIR filter
iir_filter #(.N(FILTER_TAPS)) uut (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .data_out(data_out)
);

// Metrics and Logging
real total_power = 0, harmonic_power = 0, thd_value;
integer stable_count = 0, required_stable_period = 1000;
real final_value = 0; // Expected final value after step input
integer amplitude_delta = 1000; // Change amplitude increment

// File ID for output data
integer file_id;

// Clock generation
always #(CLK_PERIOD/2) clk = ~clk;

// Automated Metric Calculation for Ringing and Settling Time
always @(posedge clk) begin
    if (!rst && count > IMPULSE_DURATION && count < TOTAL_DURATION) begin
        if (abs(data_out - final_value) < SOME_THRESHOLD) begin
            stable_count = stable_count + 1;
            if (stable_count >= required_stable_period) begin
                $display("Settling time reached at %t", $time);
                stable_count = 0; // Reset for next test or condition
            end
        end else begin
            stable_count = 0; // Reset if it goes out of threshold
        end
        if (count % 4800 == 0) begin 
            harmonic_power = harmonic_power + (data_out * data_out);
        end
        total_power = total_power + (data_out * data_out);
        count = count + 1;
    end else if (count >= TOTAL_DURATION) begin
        thd_value = sqrt(harmonic_power / total_power);
        $display("Calculated THD: %f", thd_value);
        $finish;
    end
end

// Dynamic Input Testing and Real-Time Monitoring
always @(posedge clk) begin
    if (!rst) begin
        // Dynamic amplitude adjustment
        if (count % 1000 == 0) begin
            data_in = data_in + amplitude_delta;
        end
    end
end

// Visualization and logging
initial begin
    $dumpfile("transient_response.vcd");
    $dumpvars(0, transient_response_tb_IIR);
    file_id = $fopen("transient_response_output.txt", "w");
    
    // Wait for reset release and system stabilization
    rst = 1;
    #100;
    rst = 0;
    #20;

    // Impulse and step input test
    for (count = 0; count < TOTAL_DURATION; count = count + 1) begin
        @(posedge clk) begin
            if (count == 0) begin
                data_in = 16'sd32767; // Impulse
            end else if (count == IMPULSE_DURATION) begin
                data_in = 0; // Return to zero
            end else if (count == IMPULSE_DURATION + 1) begin
                data_in = 16'sd32767; // Step
            end
            $fwrite(file_id, "%d\n", data_out); // Log output at every cycle
        end
    end
    
    $fclose(file_id);
    $finish;
end

endmodule