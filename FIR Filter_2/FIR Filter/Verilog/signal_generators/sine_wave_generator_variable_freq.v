//FIR Filter Design and Implementation
//Max Destil
//RIN: 662032859

// Sine wave generator variable frequency

module sine_wave_generator_variable_freq (
    input wire clk,
    input wire reset,
    input wire [31:0] freq_control, 
    output reg [15:0] sine_wave_out
);

// 20ms of data sampled at 48 kHz
parameter LUT_SIZE = 960; // Number of entries in LUT
reg [15:0] sine_wave_lut[0:LUT_SIZE-1]; // LUT for sine wave
reg [31:0] phase_accumulator = 0; // Phase accumulator for frequency control
reg [31:0] phase_increment = 0; // Phase increment based on desired frequency

integer i;

initial begin
    $readmemh("C:/Users/mdest/OneDrive/Documents/VLSI/FIR Filter/MATLAB/hardware_inputs/sine_wave_values.hex", sine_wave_lut);  //generated from MATLAB script
    i = 0;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        phase_accumulator <= 0;
    end else begin
        phase_accumulator <= phase_accumulator + freq_control; // Adjust phase_increment as necessary
        i <= (phase_accumulator >> 16) % LUT_SIZE; // Use upper bits for LUT index
        sine_wave_out <= sine_wave_lut[i];
    end
end

endmodule
