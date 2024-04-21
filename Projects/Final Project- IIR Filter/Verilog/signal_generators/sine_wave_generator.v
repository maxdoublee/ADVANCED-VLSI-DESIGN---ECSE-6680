//FIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// Sine wave generator with amplitude control

module sine_wave_generator (
    input wire clk,
    input wire reset,
    input wire [15:0] amplitude, 
    output reg [15:0] sine_wave_out
);

parameter LUT_SIZE = 960; 
reg [15:0] sine_wave_lut[0:LUT_SIZE-1]; // LUT for sine wave
integer i;

initial begin
    $readmemh("C:/Users/mdest/OneDrive/Documents/VLSI/FIR Filter/MATLAB/hardware_inputs/sine_wave_values.hex", sine_wave_lut); //generated from MATLAB script
    i = 0;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        i <= 0;
    end else begin
        // Scale the output of the LUT by the amplitude control value
        sine_wave_out <= (sine_wave_lut[i] * amplitude) >>> 16;
        i <= i + 1;
        if (i >= LUT_SIZE) begin
            i <= 0; // Loop back to start
        end
    end
end

endmodule
