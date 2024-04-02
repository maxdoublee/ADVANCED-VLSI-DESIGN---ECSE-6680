% MATLAB Script to Analyze THD from Verilog Testbench Output

% Load filtered output data from the Verilog simulation
filtered_output_data = load('filtered_output_data.txt');

% Assuming your data is in a compatible format
% Convert the filtered output data if necessary
% For example, if your data is fixed-point, convert it to floating point

% Define the sampling frequency
fs = 48000; % Sampling frequency in Hz

% Calculate the THD
thd_value = thd(filtered_output_data, fs);

% Display the THD result
fprintf('\nTotal Harmonic Distortion (THD) from Hardware Implementation: %.2f dB\n', thd_value);