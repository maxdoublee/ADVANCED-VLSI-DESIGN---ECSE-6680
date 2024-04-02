% MATLAB Script for Analyzing Verilog Frequency Sweep Test Output

% Load FIR filter coefficients
% Assume coefficients are stored in a MATLAB file or variable `b`
% b = [your FIR filter coefficients];

% Define simulation parameters
fs = 48000; % Sampling frequency in Hz
sweep_steps = 10; % Number of steps in frequency sweep
Fpass_Hz = 0.2 * (fs / 2); % Passband edge frequency in Hz
Fstop_Hz = 0.23 * (fs / 2); % Stopband edge frequency in Hz
freqs = linspace(Fpass_Hz, Fstop_Hz, sweep_steps);

% Load the output data from Verilog simulation
fileID = fopen('fir_freq_sweep_output.txt','r');
data_out = fscanf(fileID, '%d\n');
fclose(fileID);

% Assuming equal distribution of samples among frequency steps
samples_per_step = length(data_out) / sweep_steps;

% Initialize results storage
snr_results = zeros(1, sweep_steps);

for idx = 1:sweep_steps
    % Extract the data for the current frequency step
    data_segment = data_out(1 + (idx-1)*samples_per_step : idx*samples_per_step);
    
    % Convert to double for processing
    data_segment = double(data_segment);
    
    % Generate the original sine wave for this step
    t = 0:1/fs:(length(data_segment)/fs)-(1/fs);
    original_signal = sin(2 * pi * freqs(idx) * t).';
    
    % Calculate SNR
    signal_power = bandpower(original_signal);
    noise_power = bandpower(data_segment - original_signal);
    snr_results(idx) = 10 * log10(signal_power / noise_power);
end

% Display results
fprintf('\nFrequency Sweep SNR Results:\n');
for idx = 1:length(freqs)
    fprintf('Frequency: %.2f Hz, SNR: %.2f dB\n', freqs(idx), snr_results(idx));
end
