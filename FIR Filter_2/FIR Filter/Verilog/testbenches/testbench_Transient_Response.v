//FIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// Transient Response Testing

`timescale 1ns / 1ps

module transient_response_tb;

parameter DATA_WIDTH = 16;
parameter CLK_PERIOD = 20.833; // Clock period in ns for a 48kHz sampling rate
parameter FILTER_TAPS = 100;
parameter IMPULSE_DURATION = 1; // Number of clock cycles for impulse
parameter TOTAL_DURATION = 10000; 

// Inputs
reg clk = 0;
reg rst = 1;
reg signed [DATA_WIDTH-1:0] data_in = 0;
integer count = 0; // Counter to keep track of the test duration

// Outputs
wire signed [31:0] data_out;

// Instantiate the FIR filter module
fir_filter #(.N(FILTER_TAPS)) uut (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .data_out(data_out)
);

// File ID for output data
integer file_id;

// Clock generation
always #(CLOCK_PERIOD/2) clk = ~clk;

// Test sequence
initial begin
    // Initialize
    $dumpfile("transient_response.vcd");
    $dumpvars(0, transient_response_tb);
    file_id = $fopen("transient_response_output.txt", "w");
    
    // Wait for reset release and system stabilization
    rst = 1;
    #(CLOCK_PERIOD * 10);
    rst = 0;
    #(CLOCK_PERIOD * 10);

    // Impulse Response Test
    data_in = 16'sd32767; // Impulse
    #(CLOCK_PERIOD * IMPULSE_DURATION);
    data_in = 0; // Back to zero

    // Capture the impulse response
    for (count = 0; count < TOTAL_DURATION; count = count + 1) begin
        @(posedge clk) begin
            $fwrite(file_id, "%d\n", data_out);
            // Generate step input after impulse test
            if (count == IMPULSE_DURATION) begin
                data_in = 16'sd32767; // Step
            end
        end
    end
    
    $fclose(file_id);
    $finish;
end

endmodule
