% Define sampling frequency and signal frequency
fs = 48000; % Sampling frequency in Hz
f_sin = 1000; % Sine wave frequency in Hz

% Read in the hardware simulation data
fileID = fopen('output_signals.txt','r');
simulated_data = fscanf(fileID, '%d');
fclose(fileID);

% Convert data to a voltage level if necessary (depending on your DAC conversion logic in hardware)
% Assuming 16-bit signed integer input
simulated_data = double(simulated_data) / 32768; % Example conversion, adjust based on your system

% Compute Power Spectral Density (PSD) using Welch's method
[psd_simulated, f] = pwelch(simulated_data, [], [], [], fs);

% Calculate the total power in the signal band
signal_band = [f_sin-100 f_sin+100]; % Define signal band
signal_power_simulated = bandpower(psd_simulated, f, signal_band, 'psd');

% Calculate total power and noise power
total_power_simulated = bandpower(psd_simulated, f, 'psd');
noise_power_simulated = total_power_simulated - signal_power_simulated;

% Calculate SNR
snr_simulated = 10*log10(signal_power_simulated / noise_power_simulated);

% Calculate ENOB
enob_simulated = (snr_simulated - 1.76) / 6.02;

% Display the results
fprintf('\nHardware Implementation Analysis:\n');
fprintf('Simulated Filter SNR: %.2f dB\n', snr_simulated);
fprintf('Simulated Filter ENOB: %.2f bits\n', enob_simulated);

% Comparison with MATLAB Implementation
% Assuming you have snr_matlab and enob_matlab from your MATLAB implementation
fprintf('\nComparison with MATLAB Implementation:\n');
fprintf('Difference in SNR (Hardware - MATLAB): %.2f dB\n', snr_simulated - snr_matlab);
fprintf('Difference in ENOB (Hardware - MATLAB): %.2f bits\n', enob_simulated - enob_matlab);