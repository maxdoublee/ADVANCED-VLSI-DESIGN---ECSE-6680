% Load the FIR filter output data
data = load('output_signals_dynamic_range.txt');

% Constants
fs = 48000; % Sampling frequency in Hz
AMPLITUDE_STEPS = 10; % Matching the Verilog testbench
data_length = length(data) / AMPLITUDE_STEPS; % Number of data points per amplitude level

% Preallocate arrays for SNR and ENOB
snr_values = zeros(1, AMPLITUDE_STEPS);
enob_values = zeros(1, AMPLITUDE_STEPS);

% Process data for each amplitude level
for i = 1:AMPLITUDE_STEPS
    % Extract data for current amplitude level
    startIdx = (i-1) * data_length + 1;
    endIdx = i * data_length;
    amplitude_data = data(startIdx:endIdx);
    
    % Compute the Power Spectral Density (PSD)
    [Pxx, F] = pwelch(amplitude_data, [], [], [], fs);
    
    % Find the main signal peak in the PSD
    signal_freq = 1000; % Assuming this is your sine wave frequency
    [signal_peak, ~] = max(Pxx(F >= signal_freq - 10 & F <= signal_freq + 10));
    
    % Calculate total signal power and noise power
    total_power = bandpower(Pxx, F, 'psd');
    noise_power = total_power - signal_peak;
    
    % Calculate SNR
    snr_values(i) = 10 * log10(signal_peak / noise_power);
    
    % Calculate ENOB
    enob_values(i) = (snr_values(i) - 1.76) / 6.02;
end

% Display Results
for i = 1:AMPLITUDE_STEPS
    fprintf('Amplitude Level %d - SNR: %.2f dB, ENOB: %.2f bits\n', i, snr_values(i), enob_values(i));
end
