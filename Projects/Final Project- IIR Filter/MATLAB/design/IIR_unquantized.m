% Filter specifications
Fpass = 0.2;       % Passband edge
Fstop = 0.23;      % Stopband edge
Apass = 1;         % Passband ripple (dB)
Astop = 80;        % Stopband attenuation (dB)
Fs = 1;            % Normalized frequency (since MATLAB uses normalized frequency for digital filters)

% Calculate the necessary order and natural frequency
[N, Wn] = ellipord(Fpass, Fstop, Apass, Astop);

% Design the elliptic IIR filter
[b, a] = ellip(N, Apass, Astop, Wn, 'low');

% Create a filter object
Hd = dfilt.df2t(b, a);

% Analyze the filter
fvtool(Hd, 'Analysis', 'freq'); % Frequency response
fvtool(Hd, 'Analysis', 'phase'); % Phase response