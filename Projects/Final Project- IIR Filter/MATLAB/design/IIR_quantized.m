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

[b, a] = ellip(N, Apass, Astop, Wn, 'low');

% Analyze quantization effects
bq = fi(b, 1, num_bits); % 16-bit signed fixed-point representation of 'b'
aq = fi(a, 1, num_bits); % 16-bit signed fixed-point representation of 'a'

% Create a quantized filter object
Hdq = dfilt.df2t(bq, aq);

% Analyze the filter
fvtool(Hdq, 'Analysis', 'magnitude'); % Frequency response
fvtool(Hdq, 'Analysis', 'phase'); % Frequency response

% Open file for writing hex values
fileID = fopen('quantized_coefficients.txt', 'w');

% Iterate over each 'b' coefficient
for i = 1:length(b)
    % Convert each coefficient to fixed-point representation
    fixedPointValue = fi(b(i), 1, num_bits, num_bits - 1); % Using num_bits - 1 for fraction length
    
    % Convert to hexadecimal string
    hexString = fixedPointValue.hex;
    
    % Write hex string to file
    fprintf(fileID, '%s\n', hexString);
end

% Iterate over each 'a' coefficient
for i = 1:length(a)
    % Convert each coefficient to fixed-point representation
    fixedPointValue = fi(a(i), 1, num_bits, num_bits - 1); % Using num_bits - 1 for fraction length
    
    % Convert to hexadecimal string
    hexString = fixedPointValue.hex;
    
    % Write hex string to file
    fprintf(fileID, '%s\n', hexString);
end

% Close the file
fclose(fileID);

% Note: The list of coefficients will appear shorter because an IIR filter can achieve the 
% desired frequency response with fewer coefficients because of the feedback mechanism