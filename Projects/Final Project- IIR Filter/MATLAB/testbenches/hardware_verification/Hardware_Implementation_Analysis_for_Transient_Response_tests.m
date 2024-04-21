% MATLAB Script for Analyzing Verilog Transient Response Test Output

% Assuming the path to the output file is correct
% Make sure to update it to where your file actually resides
data_path = 'C:\Users\mdest\OneDrive\Documents\VLSI\FIR Filter\Verilog\transient_response_output.txt';

% Load the FIR filter's output data for the impulse response
impulse_response = load(data_path);

% Create a time vector for plotting, adjust the sampling frequency as necessary
Fs = 48000; % Sampling frequency
% t_impulse = (0:length(impulse_response)-1) / Fs; % Time vector

% Plot Impulse Response
figure;
stem(t_impulse, impulse_response, 'LineWidth', 0.1, 'Marker', 'none');
title('Impulse Response');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 0.01]); % Adjust the x-axis limit as needed

% Note: Adjust the xlim value according to the specific range of interest
% This sets the x-axis limit to show the initial part of the impulse response
