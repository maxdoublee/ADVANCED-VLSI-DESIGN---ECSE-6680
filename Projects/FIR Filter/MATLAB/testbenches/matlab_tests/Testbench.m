% Sampling frequency and sine wave frequency
fs = 48000;         % Sampling frequency in Hz, exceeds the minimum required to satisfy the Nyquist criterion for the frequencies of interest in this project
f_sin = 1000;       % Sine wave frequency in Hz
t = 0:1/fs:1-1/fs;  % Time vector

% ===================== Signal to Noise Ratio (SNR) and Estimated Number of Bits (ENOB) =====================
fprintf('\nSNR and ENOB Testing:\n');
% Generating a sine wave input signal
input_signal = sin(2*pi*f_sin*t);

% Generating noise by filtering random noise through the filter
noise_unquantized = filter(b, 1, randn(size(t)));
noise_quantized = filter(b_quantized_double, 1, randn(size(t)));

% Passing the sine wave and noise through both unquantized and quantized filters
output_signal_unquantized = filter(b, 1, input_signal + noise_unquantized);
output_signal_quantized = filter(b_quantized_double, 1, input_signal + noise_quantized);

% First compute the Power Spectral Density (PSD) of the output signals
[psd_unquantized, f] = pwelch(output_signal_unquantized, [], [], [], fs);
[psd_quantized, ~] = pwelch(output_signal_quantized, [], [], [], fs);

% Calculates the total power in the signal band for both filters
signal_power_unquantized = bandpower(psd_unquantized, f, [f_sin-100 f_sin+100], 'psd');
signal_power_quantized = bandpower(psd_quantized, f, [f_sin-100 f_sin+100], 'psd');

% Calculates the total power in the PSD, then subtract the signal band power to get noise power
total_power_unquantized = bandpower(psd_unquantized, f, 'psd');
total_power_quantized = bandpower(psd_quantized, f, 'psd');
noise_power_unquantized = total_power_unquantized - signal_power_unquantized;
noise_power_quantized = total_power_quantized - signal_power_quantized;

% Calculates SNR for both filters
snr_unquantized = 10*log10(signal_power_unquantized / noise_power_unquantized);
snr_quantized = 10*log10(signal_power_quantized / noise_power_quantized);

% Calculates ENOB for both filters
enob_unquantized = (snr_unquantized - 1.76) / 6.02;
enob_quantized = (snr_quantized - 1.76) / 6.02;

% Display the results
fprintf('Unquantized Filter SNR: %.2f dB\n', snr_unquantized);
fprintf('Quantized Filter SNR: %.2f dB\n', snr_quantized);
fprintf('Unquantized Filter ENOB: %.2f bits\n', enob_unquantized);
fprintf('Quantized Filter ENOB: %.2f bits\n', enob_quantized);

% ===================== Dynamic Range Testing =====================
fprintf('\nDynamic Range Testing:\n');
% Generate 10 linearly spaced amplitudes ranging from 0.01 to 1 
amplitudes = linspace(0.01, 1, 10); 

for amp = amplitudes
    input_signal_amp = amp * sin(2*pi*f_sin*t);
    output_signal_amp_unquantized = filter(b, 1, input_signal_amp + noise_unquantized);
    output_signal_amp_quantized = filter(b_quantized_double, 1, input_signal_amp + noise_quantized);
    
    % Measuring SNR against the original amplitude modulated signal
    snr_amp_unquantized = snr(output_signal_amp_unquantized - input_signal_amp, noise_unquantized);
    snr_amp_quantized = snr(output_signal_amp_quantized - input_signal_amp, noise_quantized);
    
    fprintf('Amplitude: %.2f - Unquantized SNR: %.2f dB, Quantized SNR: %.2f dB\n', amp, snr_amp_unquantized, snr_amp_quantized);
end

% ===================== Sweeping Signal Frequency =====================
fprintf('\nSweeping Signal Frequency:\n');
% Define the transition region boundaries in normalized frequency
Fpass = 0.2;  % Passband edge
Fstop = 0.23; % Stopband edge

% Calculates corresponding frequencies in Hz
Fpass_Hz = Fpass * (fs/2);
Fstop_Hz = Fstop * (fs/2);

% Define the frequency sweep range to cover the critical frequencies
frequencies = linspace(Fpass_Hz, Fstop_Hz, 10);

for freq = frequencies
    input_signal_sweep = sin(2*pi*freq*t);
    output_signal_unquantized = filter(b, 1, input_signal_sweep + noise_unquantized);
    output_signal_quantized = filter(b_quantized_double, 1, input_signal_sweep + noise_quantized);
    snr_unquantized = snr(output_signal_unquantized - input_signal_sweep, noise_unquantized);
    snr_quantized = snr(output_signal_quantized - input_signal_sweep, noise_quantized);
    fprintf('Frequency: %.2f Hz - Unquantized SNR: %.2f dB, Quantized SNR: %.2f dB\n', freq, snr_unquantized, snr_quantized);
end

% ===================== Transient Response =====================
% Impulse input
impulse_input = zeros(size(t)); impulse_input(1) = 1;

% Apply filters to impulse input 
impulse_response_unquantized = filter(b, 1, impulse_input);
impulse_response_quantized = filter(b_quantized_double, 1, impulse_input);

% Plot impulse responses
figure;
subplot(3,1,2);
stem(t, impulse_response_unquantized, 'LineWidth', 0.1, 'Marker', 'none');
title('Impulse Response (Unquantized)');
xlabel('Time');
ylabel('Amplitude');
xlim([0 0.01]);

subplot(3,1,3);
stem(t, impulse_response_quantized, 'LineWidth', 0.1, 'Marker', 'none');
title('Impulse Response (Quantized)');
xlabel('Time');
ylabel('Amplitude');
xlim([0 0.01]);

% ===================== Total Harmonic Distortion (THD) =====================
% Use generated sine wave input for the test signal for the THD calculation
output_signal_unquantized = filter(b, 1, input_signal);
output_signal_quantized = filter(b_quantized_double, 1, input_signal);

thd_unquantized = thd(output_signal_unquantized, fs);
thd_quantized = thd(output_signal_quantized, fs);
fprintf('\nHarmonic Distortion Analysis (THD):\n');
fprintf('Unquantized Filter THD: %.2f dB\n', thd_unquantized);
fprintf('Quantized Filter THD: %.2f dB\n', thd_quantized);

% ===================== Intermodulation Distortion (IMD) =====================
% Define the two frequencies for the IMD test signal
% Frequencies 1000 Hz and 1200 Hz chosen for IMD testing due to their close proximity, ideal for evaluating the filter's handling of closely spaced signals 
f1 = 1000; % Frequency 1 for IMD signal
f2 = 1200; % Frequency 2 for IMD signal

% Generate the IMD test signal
input_signal_imd = sin(2*pi*f1*t) + sin(2*pi*f2*t);

% Filtering and analyzing the IMD test signal
output_signal_imd_unquantized = filter(b, 1, input_signal_imd);
output_signal_imd_quantized = filter(b_quantized_double, 1, input_signal_imd);

% Spectrum analysis to observe IMD products
[psd_imd_unquantized, f_imd] = pwelch(output_signal_imd_unquantized, [], [], [], fs);
[psd_imd_quantized, ~] = pwelch(output_signal_imd_quantized, [], [], [], fs);

% Plotting the PSD for visual IMD analysis
figure;
subplot(2,1,1);
plot(f_imd, 10*log10(psd_imd_unquantized));
title('IMD Spectrum (Unquantized)');
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');

subplot(2,1,2);
plot(f_imd, 10*log10(psd_imd_quantized));
title('IMD Spectrum (Quantized)');
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');

% ===================== Overflow Testing =====================
fprintf('\nOverflow Testing:\n');
% Overflow testing with amplitude set to 32767 the maximum for 16-bit signed representation to evaluate the filter's handling of potential overflow conditions
overflow_test_amplitude = 32767; 
overflow_input_signal = overflow_test_amplitude * sin(2*pi*f_sin*t);

% Apply filters to the high amplitude input signal
output_signal_overflow_unquantized = filter(b, 1, overflow_input_signal);
output_signal_overflow_quantized = filter(b_quantized_double, 1, overflow_input_signal);

% Analyze the output to see if overflow handling (saturation) was effective
% Simple way to check is to look for the maximum and minimum values in the output signal
max_output_unquantized = max(output_signal_overflow_unquantized);
max_output_quantized = max(output_signal_overflow_quantized);
minValue_unquantized = min(output_signal_overflow_unquantized);
minValue_quantized = min(output_signal_overflow_quantized);

fprintf('Maximum Output Amplitude (Unquantized): %.2f\n', max_output_unquantized);
fprintf('Maximum Output Amplitude (Quantized): %.2f\n', max_output_quantized);
fprintf('Minimum Output Amplitude (Unquantized): %.2f\n', minValue_unquantized);
fprintf('Minimum Output Amplitude (Quantized): %.2f\n', minValue_quantized);

figure;
plot(output_signal_overflow_quantized);
title('Overflow Test Output');
xlabel('Sample Number');
ylabel('Amplitude');
grid on;

peakToPeakAmplitude = max_output_quantized - minValue_quantized;
fprintf('Peak-to-Peak Amplitude: %f\n', peakToPeakAmplitude);
