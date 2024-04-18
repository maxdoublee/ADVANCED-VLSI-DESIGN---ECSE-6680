% Filter specifications
Fpass = 0.2;       % Passband edge
Fstop = 0.23;      % Stopband edge
Apass = 1;         % Passband ripple (dB)
Astop = 80;        % Stopband attenuation (dB)
Fs = 1;            % Normalized frequency (since MATLAB uses normalized frequency for digital filters)

% Calculate the necessary order and natural frequency
[N, Wn] = ellipord(Fpass, Fstop, Apass, Astop);

% Bit depth for quantization
num_bits = 16;

% Configuration of fixed-point math properties for saturation on overflow
Fm = fimath('OverflowAction','Saturate','RoundingMethod','Floor','ProductMode','SpecifyPrecision', ...
'ProductWordLength',num_bits,'ProductFractionLength',num_bits-1,'SumMode','SpecifyPrecision', ...
'SumWordLength',num_bits,'SumFractionLength',num_bits-1);

[b, a] = ellip(N, Apass, Astop, Wn, 'low');

% Analyze quantization effects
bq = fi(b, 1, num_bits, 'fimath', Fm); % 16-bit signed fixed-point representation of 'b'
aq = fi(a, 1, num_bits, 'fimath', Fm); % 16-bit signed fixed-point representation of 'a'

% Convert quantized coefficients to double for frequency response analysis
bq_double = double(bq);
aq_double = double(aq);

% Create a quantized filter object
Hdq = dfilt.df2t(bq_double, aq_double);

% Analyze the filter
fvtool(Hdq, 'Analysis', 'magnitude'); % Frequency response
fvtool(Hdq, 'Analysis', 'phase'); % Frequency response