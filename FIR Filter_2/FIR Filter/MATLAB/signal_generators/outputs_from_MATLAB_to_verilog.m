% Define the sine wave
fs = 48000; % Sampling frequency
t = (0:fs/1000-1)'/fs; % Time vector for 1 second, adjust if needed
f = 1000; % Frequency of sine wave
input_signal = sin(2*pi*f*t);

% Ensure we only use 960 samples
input_signal = input_signal(1:960);

% Scale and convert to integer
% Assuming you're targeting a 16-bit signed input for Verilog, scale appropriately
scaled_signal = int16(input_signal * 32767);

% Open file
fileID = fopen('sine_wave_values.hex', 'w');

% Write each value as hex, ensuring only 960 entries are written
for i = 1:length(scaled_signal)
    hexValue = typecast(swapbytes(scaled_signal(i)), 'uint16'); % Use swapbytes for endianess correction if needed
    fprintf(fileID, '%04x\n', hexValue);
end

% Close file
fclose(fileID);