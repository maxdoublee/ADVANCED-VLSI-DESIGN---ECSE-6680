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

% Loop to increase the number of taps until the stopband attenuation meets the requirement
while atten < desired_atten
    % Design the filter
    b = firpm(N, F, A, W);
    
    % Calculate stopband attenuation
    [H,f] = freqz(b,1,1024); % Compute the frequency response of the filter
    H_dB = 20*log10(abs(H)); % Convert to dB
    atten = -min(H_dB(f > Fstop)); % Find the minimum attenuation in the stopband
    
    % Check if attenuation requirement is met
    if atten < desired_atten
        N = N + 1; % Increase the number of taps
    end
end

% Once the loop completes, N should have a value that achieves the desired attenuation

% Design the filter
b = firpm(N, F, A, W);

% View the filter's frequency response
Hd = dfilt.dffir(b); % Create a filter object
fvtool(Hd, 'Analysis', 'freq'); % Launch fvtool with the frequency response analysis

% Customize the plot
hFVT = fvtool(b, 1); % Give the handle to FVTool
set(hFVT, 'DesignMask', 'on'); % Show a mask for design requirements
set(hFVT, 'Color', [1 1 1]); % Set the background color to white

% Set axis labels and plot title
xlabel(hFVT.CurrentAxes, 'Normalized Frequency (\times \pi rad/sample)');
ylabel(hFVT.CurrentAxes, 'Magnitude (dB)');
title(hFVT.CurrentAxes, 'Un-quantized Low-pass FIR Filter Frequency Response');

% Specify axis limits to zoom in on a certain part of the plot
set(hFVT.CurrentAxes, 'XLim', [0 0.5]); % Set x-axis limits
set(hFVT.CurrentAxes, 'YLim', [-100 5]); % Set y-axis limits to view up to -100 dB

% Grid for better visualization
grid(hFVT.CurrentAxes, 'on');

% print(hFVT, 'FilterResponse.png', '-dpng'); % Export the plot as a PNG