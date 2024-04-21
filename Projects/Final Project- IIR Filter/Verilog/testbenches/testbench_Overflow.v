//IIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// Overflow Testing

`timescale 1ns / 1ps

module overflow_testbench_IIR;

parameter DATA_WIDTH = 16;
parameter CLK_PERIOD = 20.833; // Clock period in ns for a 48kHz sampling rate
parameter TEST_DURATION = 48000; // Number of clock cycles to run the test

reg clk;
reg rst;
reg signed [DATA_WIDTH-1:0] overflow_input_signal = 16'h7FFF; // Directly apply max amplitude
wire signed [31:0] data_out;

iir_filter iir(
    .clk(clk),
    .rst(rst),
    .data_in(overflow_input_signal), // Connect the overflow test signal to IIR input
    .data_out(data_out)
);

// Clock generation
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
    // Initialize
    rst = 1;
    #100;
    rst = 0; // Release reset
    
    // Apply max amplitude and then monitor output
    #20 overflow_input_signal = 16'h7FFF; // Set maximum input
    #20 overflow_input_signal = 0; // Reset input to zero to observe recovery
    
    // Run the test for a specific duration
    #(TEST_DURATION * CLK_PERIOD);
    
    $finish; // End the simulation
end

// Stability and performance monitoring
always @(posedge clk) begin
    if (!rst) begin  // Monitor only when not in reset
        if (data_out[31]) begin  
            $display("Time %t: Warning - High output level detected %h", $time, data_out);
        end
    end
end

// Capture the IIR filter's output to a file for analysis
integer file_id; 
initial begin
    file_id = $fopen("overflow_test_output.txt", "w");
    forever @(posedge clk) begin
        $fwrite(file_id, "%d\n", data_out);
    end
    $fclose(file_id);
end

endmodule
