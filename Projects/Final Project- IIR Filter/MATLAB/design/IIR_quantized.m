% Filter specifications
Fpass = 0.2;       % Passband edge
Fstop = 0.23;      % Stopband edge
Apass = 1;         % Passband ripple (dB)
Astop = 80;        % Stopband attenuation (dB)

% Calculate the necessary order and natural frequency
[N, Wn] = ellipord(Fpass, Fstop, Apass, Astop);

% Bit depth for quantization
num_bits = 16;

% Configuration of fixed-point math properties for saturation on overflow
Fm = fimath('OverflowAction','Saturate','RoundingMethod','Floor','ProductMode','SpecifyPrecision', ...
'ProductWordLength',num_bits,'ProductFractionLength',num_bits-1,'SumMode','SpecifyPrecision', ...
'SumWordLength',num_bits,'SumFractionLength',num_bits-1);

[b_unquantized, a_unquantized] = ellip(N, Apass, Astop, Wn, 'low');

% Analyze quantization effects
b_quantized = fi(b_unquantized, 1, num_bits, num_bits - 1, 'fimath', Fm); % 16-bit signed fixed-point representation of 'b'
a_quantized = fi(a_unquantized, 1, num_bits, num_bits - 1, 'fimath', Fm); % 16-bit signed fixed-point representation of 'a'

% Convert fixed-point coefficients back to double precision 
b_quantized_double = double(b_quantized);
a_quantized_double = double(a_quantized);

% Create a quantized filter object
Hdq = dfilt.df2t(b_quantized_double, a_quantized_double);

% Analyze the filter
h = fvtool(Hdq, 'Analysis', 'magnitude');
ax = get(h, 'CurrentAxes'); % Get the handle to the axes of the FVTool
set(ax, 'YLim', [-160 5]); % Set Y-axis limits to show more detail in the stopband
fvtool(Hdq, 'Analysis', 'phase');
drawnow;

% Open files for writing hex values for b and a coefficients separately
fileID_b = fopen('coeff_b.txt', 'w');
fileID_a = fopen('coeff_a.txt', 'w');

% Iterate over b coefficient
for i = 1:length(b_quantized)
    % Convert each coefficient to fixed-point representation
    fixedPointValue = fi(b_quantized(i), 1, num_bits, num_bits - 1);
    % Convert to hexadecimal string
    hexString = fixedPointValue.hex;
    % Write hex string to file
    fprintf(fileID_b, '%s\n', hexString);
end

% Iterate over a coefficient
for i = 1:length(a_quantized)
    % Convert each coefficient to fixed-point representation
    fixedPointValue = fi(a_quantized(i), 1, num_bits, num_bits - 1);
    % Convert to hexadecimal string
    hexString = fixedPointValue.hex;
    % Write hex string to file
    fprintf(fileID_a, '%s\n', hexString);
end

% Close the files
fclose(fileID_b);
fclose(fileID_a);

% Note: The list of coefficients will appear shorter because an IIR filter can achieve the 
% desired frequency response with fewer coefficients because of the feedback mechanism