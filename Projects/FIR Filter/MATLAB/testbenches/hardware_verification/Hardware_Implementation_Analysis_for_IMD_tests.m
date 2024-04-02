% MATLAB Script to Analyze IMD Hardware Test Output and Compare with MATLAB Implementation

% Define sampling frequency
fs = 48000; % Hz

% Load hardware test output for IMD analysis
hardwareDataPath = 'imd_test_output_data.txt';
hardwareOutput = load(hardwareDataPath);

% Normalize hardware output if necessary
% Assuming the output is already scaled -1 to 1 for simplicity
% If not, adjust this section to match your system's output range
% Example: hardwareOutput = (hardwareOutput / 32768); % For 16-bit data

% Perform Spectrum Analysis on Hardware Output
[psdHardware, freqHardware] = pwelch(hardwareOutput, [], [], [], fs);

% Plotting the IMD Spectrum from Hardware Output
figure;
subplot(2,1,1);
plot(freqHardware, 10*log10(psdHardware));
title('IMD Spectrum (Hardware Output)');
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');

% For direct comparison, load or re-compute the IMD Spectrum from MATLAB Filter Implementation
% Here, it's assumed you have psd_imd_unquantized and psd_imd_quantized from your MATLAB test
% This might involve running your MATLAB filter code again or loading previously saved results
% Example loading previously saved results (replace with your actual data variables)
% load('yourMatlabIMDResults.mat'); % Contains psd_imd_unquantized, psd_imd_quantized, f_imd

% Plotting the IMD Spectrum from MATLAB Filter (Unquantized for example)
% subplot(2,1,2);
% plot(f_imd, 10*log10(psd_imd_unquantized));
% title('IMD Spectrum (MATLAB Filter - Unquantized)');
% xlabel('Frequency (Hz)');
% ylabel('Power/Frequency (dB/Hz)');

% Note: Adjust the above section to use actual MATLAB filter test results for comparison
% You might also plot quantized results or compare hardware results with both quantized and unquantized
% MATLAB results, depending on your specific analysis goals.

% Additional Analysis:
% You can extend this script to calculate and report specific IMD product levels
% by identifying peaks in the spectra and comparing their levels as shown in your original MATLAB test.
