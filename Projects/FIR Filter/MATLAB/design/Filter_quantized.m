% Desired stopband attenuation
desired_atten = 80;

% Initialize variables
atten = 0;
N = 99; % Start with 100 taps

% Define the normalized frequencies for the passband and stopband edges
Fpass = 0.2; % Normalized passband edge
Fstop = 0.23; % Normalized stopband edge

% Amplitude specifications in each band
A = [1 1 0 0]; % Corrected to match the frequency vector

F = [0 Fpass Fstop 1];

% Weight vector for each band to meet the specifications
W = [1 100]; % Adjust the weights as needed to meet the specification

% Bit depth for quantization
num_bits = 16;

% Configuration of fixed-point math properties for saturation on overflow
Fm = fimath('OverflowAction','Saturate','RoundingMethod','Floor','ProductMode','SpecifyPrecision', ...
'ProductWordLength',num_bits,'ProductFractionLength',num_bits-1,'SumMode','SpecifyPrecision', ...
'SumWordLength',num_bits,'SumFractionLength',num_bits-1);

% Loop to increase the number of taps until the stopband attenuation meets the requirement
while atten < desired_atten
    % Design the filter
    b_unquantized = firpm(N, F, A, W);

    % Apply quantization to the filter coefficients with fimath configuration
    b_quantized = fi(b_unquantized, 1, num_bits, num_bits - 1, 'fimath', Fm); % 1 for signed, num_bits total bits, num_bits - 1 fraction bits 

    % Convert quantized coefficients to double for frequency response analysis
    b_quantized_double = double(b_quantized);
    
    % Calculate stopband attenuation with quantized coefficients
    [H,f] = freqz(b_quantized_double,1,1024); % Compute the frequency response of the filter with quantized coefficients
    H_dB = 20*log10(abs(H)); % Convert to dB
    atten = -min(H_dB(f > Fstop)); % Find the minimum attenuation in the stopband
    
    % Check if attenuation requirement is met
    if atten < desired_atten
        N = N + 1; % Increase the number of taps
    end
end

% Once the loop completes, N should have a value that achieves the desired attenuation

% View the filter's frequency response
Hd = dfilt.dffir(b_quantized_double); % Create a filter object
fvtool(Hd, 'Analysis', 'freq'); % Launch fvtool with the frequency response analysis

% Customize the plot
hFVT = fvtool(b_quantized_double, 1); % Give the handle to FVTool
set(hFVT, 'DesignMask', 'on'); % Show a mask for design requirements
set(hFVT, 'Color', [1 1 1]); % Set the background color to white

% Set axis labels and plot title
xlabel(hFVT.CurrentAxes, 'Normalized Frequency (\times \pi rad/sample)');
ylabel(hFVT.CurrentAxes, 'Magnitude (dB)');
title(hFVT.CurrentAxes, 'Quantized Low-pass FIR Filter Frequency Response');

% Specify axis limits to zoom in on a certain part of the plot
set(hFVT.CurrentAxes, 'XLim', [0 0.5]); % Set x-axis limits
set(hFVT.CurrentAxes, 'YLim', [-100 5]); % Set y-axis limits to view up to -100 dB

% Grid for better visualization
grid(hFVT.CurrentAxes, 'on');

% Export the quantized coefficients to a text file for hardware implementation

% Open file for writing hex values
fileID = fopen('quantized_coefficients.txt', 'w');

% Iterate over each coefficient
for i = 1:length(b_quantized_double)
    % Convert each coefficient to fixed-point representation
    fixedPointValue = fi(b_quantized_double(i), 1, 16, 15); % 1 = signed, 16 = number of bits, 15 = fraction length
    
    % Convert to hexadecimal string
    hexString = fixedPointValue.hex;
    
    % Write hex string to file
    fprintf(fileID, '%s\n', hexString);
end

% Close the file
fclose(fileID);

% print(hFVT, 'FilterResponse.png', '-dpng'); % Export the plot as a PNG