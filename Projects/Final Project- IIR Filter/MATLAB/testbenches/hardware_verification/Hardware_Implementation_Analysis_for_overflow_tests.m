% MATLAB Script for Verifying Hardware Overflow Test Results

% Load the FIR filter's output data from the overflow test
filePath = 'C:\Users\mdest\OneDrive\Documents\VLSI\FIR Filter\Verilog\overflow_test_output.txt'; % Adjust path as necessary
overflowOutput = load(filePath);

% Convert to appropriate scale if necessary
% This step depends on the DAC/ADC resolution and the data format used in the testbench
% For a direct comparison, ensure the hardware output is in a comparable format to your MATLAB simulation
overflowOutput = double(overflowOutput);

% Analyze the output for overflow handling characteristics
maxValue = max(overflowOutput);
minValue = min(overflowOutput);
fprintf('Maximum output value: %f\n', maxValue);
fprintf('Minimum output value: %f\n', minValue);

% Visualize the output data to observe any saturation or clipping effects
figure;
plot(overflowOutput);
title('Overflow Test Output');
xlabel('Sample Number');
ylabel('Amplitude');
grid on;

% Optional: Compute statistics like peak-to-peak amplitude to further analyze the overflow handling
peakToPeakAmplitude = maxValue - minValue;
fprintf('Peak-to-Peak Amplitude: %f\n', peakToPeakAmplitude);

% Additional analysis can be performed here based on specific overflow handling mechanisms
% of interest, such as checking for expected saturation levels or other nonlinear effects.
