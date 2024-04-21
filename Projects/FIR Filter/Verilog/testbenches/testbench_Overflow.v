//FIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// Overflow Testing

`timescale 1ns / 1ps

module overflow_testbench;

parameter DATA_WIDTH = 16;
parameter CLK_PERIOD = 20.833; // Clock period in ns for a 48kHz sampling rate
parameter TEST_DURATION = 48000; // Number of clock cycles to run the test

reg clk;
reg rst;
reg signed [DATA_WIDTH-1:0] overflow_input_signal = 16'h7FFF; // Directly apply max amplitude
wire signed [31:0] data_out;

// Instantiate your FIR filter
fir_filter fir(
    .clk(clk),
    .rst(rst),
    .data_in(overflow_input_signal), // Connect the overflow test signal to FIR input
    .data_out(data_out)
);

// Clock generation
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    // Initialize
    rst = 1;
    #100;
    rst = 0; // Release reset
    
    // Run the test for a specific duration
    #(TEST_DURATION * CLK_PERIOD);
    
    $finish; // End the simulation
end

// Capture the FIR filter's output to a file for analysis
integer file_id; 
initial begin
    file_id = $fopen("overflow_test_output.txt", "w");
    forever @(posedge clk) begin
        $fwrite(file_id, "%d\n", data_out);
    end
    $fclose(file_id);
end

endmodule
