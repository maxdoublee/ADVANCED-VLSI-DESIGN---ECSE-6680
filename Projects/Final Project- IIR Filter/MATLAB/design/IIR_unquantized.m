% Filter specifications
Fpass = 0.2;       % Passband edge
Fstop = 0.23;      % Stopband edge
Apass = 1;         % Passband ripple (dB)
Astop = 80;        % Stopband attenuation (dB)
Fs = 1;            % Normalized frequency (since MATLAB uses normalized frequency for digital filters)

% Calculate the necessary order and natural frequency
[N, Wn] = ellipord(Fpass, Fstop, Apass, Astop);

% Design the elliptic IIR filter
% Compared to the FIR, the IIR filter design calculates the filter order required to      
% compute the stopband attenuation directly, so it doesn't require an iterative approach
[b, a] = ellip(N, Apass, Astop, Wn, 'low');

% Create a filter object
Hd = dfilt.df2t(b, a);

% Analyze the filter
h = fvtool(Hd, 'Analysis', 'magnitude'); % Frequency response
ax = get(h, 'CurrentAxes'); % Get the handle to the axes of the FVTool
set(ax, 'YLim', [-160 5]); % Set Y-axis limits to show more detail in the stopband

fvtool(Hd, 'Analysis', 'phase'); % Frequency response
drawnow;