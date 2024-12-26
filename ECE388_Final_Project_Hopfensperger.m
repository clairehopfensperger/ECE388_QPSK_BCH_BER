% Claire Hopfensperger
% ECE 388 Final Project

%{
    This program plots the BER of 8PSK with and
    without BCH(15, 11, 1) error correction.

    NOTE: Collaborated with Chris Lallo, Blake Rile,
    and Cody Radabaugh
%}

clear; close all;

%-------------------------------------
% Variables
%-------------------------------------

j = sqrt(-1);

Ts = 1E-3;      % Symbol duration
Ns = 4;         % Samples per symbol
Fc = 2E6;       % Carrier frequency

num_symbols = 1E6;

% message and data vars based on type of BCH error correction
msg_length = 15;
data_length = 11;

num_msg_bits = 3 * num_symbols;     % 3 bits/symbol bc 8PSK
num_data_bits = num_msg_bits - ((num_msg_bits / msg_length) * 4);

% Initialize arrays
symbols = zeros(1, num_symbols);
data_bits = randi([0, 1], 1, num_data_bits);

received_bits = zeros(1, num_msg_bits);
received_symbols = zeros(1, num_symbols);

% Set up EbN0
Eb_N0_dB = 2:0.5:13;
BER_coded = zeros(1, length(Eb_N0_dB));
BER_uncoded = zeros(1, length(Eb_N0_dB));

% Reshape the data bit array into a matrix of many rows of 11 bits
data_bits = reshape(data_bits, data_length, [])';

% Initialize matrix for message bits
BCH_message_bits = zeros(num_data_bits / data_length, msg_length);

% Encode each data bit matrix row of 11 data bits
for k = 1:(num_data_bits / data_length)
    BCH_message_bits(k, :) = [data_bits(k, :), bch_encoder(data_bits(k, :))];
end

% Reshape message bits matrix into one row
BCH_message_bits = reshape(BCH_message_bits', 1, []);

%-------------------------------------
% Transmitter
%-------------------------------------

% Make symbols
for k = 1:num_symbols
    bit_trio = BCH_message_bits(3 * k - 2:3 * k);
    
    if isequal(bit_trio, [0 0 0])
        symbols(k) = cos(deg2rad(22.5)) + j*sin(deg2rad(22.5));
    elseif isequal(bit_trio, [0 0 1]) 
        symbols(k) = cos(deg2rad(67.5)) + j*sin(deg2rad(67.5));
    elseif isequal(bit_trio, [0 1 1]) 
        symbols(k) = cos(deg2rad(112.5)) + j*sin(deg2rad(112.5));
    elseif isequal(bit_trio, [0 1 0]) 
        symbols(k) = cos(deg2rad(157.5)) + j*sin(deg2rad(157.5));
    elseif isequal(bit_trio, [1 0 0]) 
        symbols(k) = cos(deg2rad(-22.5)) + j * sin(deg2rad(-22.5));
    elseif isequal(bit_trio, [1 0 1]) 
        symbols(k) = cos(deg2rad(-67.5)) + j * sin(deg2rad(-67.5));
    elseif isequal(bit_trio, [1 1 1]) 
        symbols(k) = cos(deg2rad(-112.5)) + j * sin(deg2rad(-112.5));
    elseif isequal(bit_trio, [1 1 0]) 
        symbols(k) = cos(deg2rad(-157.5)) + j * sin(deg2rad(-157.5));
    end

end

% Reshape a(t)
aoft = repmat(symbols, Ns, 1); % 4 samples per symbol
aoft = reshape(aoft, 1, Ns * num_symbols); % Row array

%-------------------------------------
% Receiver
%-------------------------------------

% Generate LUT and print to console
lut = gen_LUT()

for i = 1:length(Eb_N0_dB)
    
    % Add Eb/N0 varying noise
    aoft_noisy = awgn(aoft, Eb_N0_dB(i) + (10 * log10(3)) - (10 * log10(Ns)), 'measured');  % Added noise
        % NOTE: Need to add '10 * log10(3)' because 8PSK SNR = 3 * Eb/N0
   
    % Receiver code
    for k = 1:num_symbols
        sum_bits_I = 0;
        sum_bits_Q = 0;
        
        % Integrate real and imaginary parts separately to find the
        % received constellation point
        for k1 = 1:Ns
            sum_bits_I = sum_bits_I + real(aoft_noisy((k - 1) * Ns + k1));
            sum_bits_Q = sum_bits_Q + imag(aoft_noisy((k - 1) * Ns + k1));
        end
        
        % Calculate angle of constellation point
        angle_rad = atan2(sum_bits_Q, sum_bits_I);
        
        % Map the received constellation point back to received bits
        if angle_rad >= deg2rad(0) && angle_rad < deg2rad(45)
            received_symbols(k) = cos(deg2rad(22.5)) + j * sin(deg2rad(22.5));
            received_bits(3 * k - 2:3 * k) = [0 0 0];
        elseif angle_rad >= deg2rad(45) && angle_rad < deg2rad(90)
            received_symbols(k) = cos(deg2rad(67.5)) + j * sin(deg2rad(67.5));
            received_bits(3 * k - 2:3 * k) = [0 0 1];
        elseif angle_rad >= deg2rad(90) && angle_rad < deg2rad(135)
            received_symbols(k) = cos(deg2rad(112.5)) + j * sin(deg2rad(112.5));
            received_bits(3 * k - 2:3 * k) = [0 1 1];
        elseif angle_rad >= deg2rad(135) && angle_rad < deg2rad(180)
            received_symbols(k) = cos(deg2rad(157.5)) + j * sin(deg2rad(157.5));
            received_bits(3 * k - 2:3 * k) = [0 1 0];
        elseif angle_rad >= deg2rad(-180) && angle_rad < deg2rad(-135)
            received_symbols(k) = cos(deg2rad(-157.5)) + j * sin(deg2rad(-157.5));
            received_bits(3 * k - 2:3 * k) = [1 1 0];
        elseif angle_rad >= deg2rad(-135) && angle_rad < deg2rad(-90)
            received_symbols(k) = cos(deg2rad(-112.5)) + j * sin(deg2rad(-112.5));
            received_bits(3 * k - 2:3 * k) = [1 1 1];
        elseif angle_rad >= deg2rad(-90) && angle_rad < deg2rad(-45)
            received_symbols(k) = cos(deg2rad(-67.5)) + 1i * sin(deg2rad(-67.5));
            received_bits(3 * k - 2:3 * k) = [1 0 1];
        elseif angle_rad >= deg2rad(-45) && angle_rad < deg2rad(0)
            received_symbols(k) = cos(deg2rad(-22.5)) + j * sin(deg2rad(-22.5));
            received_bits(3 * k - 2:3 * k) = [1 0 0];
        end
    end

    % Initialize variables
    total_bit_errors_coded = 0;
    total_bit_errors_uncoded = 0;
    
    % Iterate through received bits, complete error correction, calculate
    % BER w/ and w/o BCH error correction
    for k = 1:msg_length:num_msg_bits
        uncoded_data = received_bits(k:k + (data_length - 1));
        uncoded_message = received_bits(k:k + (msg_length - 1));
        
        % Use BCH en/decoding to determine location of error
        syndrome = bch_encoder(uncoded_message);
        error_message = use_LUT(syndrome, lut);
        
        % Correct error
        %corrected_message = xor(error_message, uncoded_message);
        corrected_data = xor(error_message, uncoded_data);

        % Calculate errors count
        bit_errors_coded = sum(data_bits((k - 1) / msg_length + 1, :) ~= corrected_data);
        total_bit_errors_coded = total_bit_errors_coded + bit_errors_coded;

        bit_errors_uncoded = sum(data_bits((k - 1) / msg_length + 1, :) ~= uncoded_data);
        total_bit_errors_uncoded = total_bit_errors_uncoded + bit_errors_uncoded;
    end
    
    % Add to coded BER
    if total_bit_errors_coded == 0
        BER_coded(i) = 1E-6;
    else
        BER_coded(i) = total_bit_errors_coded / num_data_bits;
    end
    
    % Add to uncoded BER
    if total_bit_errors_uncoded == 0
        BER_uncoded(i) = 1E-6;
    else
        BER_uncoded(i) = total_bit_errors_uncoded / num_data_bits;
    end

end

% Plot the BER/SER curves
figure;
semilogy(Eb_N0_dB, BER_coded, 'b-o', 'LineWidth', 1.5);
hold on;
semilogy(Eb_N0_dB, BER_uncoded, 'r-o', 'LineWidth', 1.5);
legend("BER with Coding", "BER w/o Coding");
xlabel('Eb/N0 (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs Eb/N0 for 8PSK');
grid on;

%---------------------------------------------------------
% Function to Compute BCH(15, 11, 1) syndrome
function bch_encode = bch_encoder(data)
    % Generator polynomial: X^4 + X + 1
    % Message length,    n: 15
    % Data length,       k: 11
    
    reg = zeros(1, 4);

    for i = 1:length(data)
        %
        XOR1 = data(i) ~= reg(4);
        
        %out = message(i) | XOR1;

        reg(4) = reg(3);
        reg(3) = reg(2);
        
        XOR2 = XOR1 ~= reg(1);
        
        reg(2) = XOR2;
        reg(1) = XOR1;
    end
    bch_encode = flip(reg);  % Numbered regs LSB to MSB instead of reverse
end

%---------------------------------------------------------
% Function to generate LUT for BCH(15, 11, 1) syndromes and error messages
function lut = gen_LUT()
    data = [0 0 0 0 0 0 0 0 0 0 0];
    bch_code = bch_encoder(data);
    code_message = [data, bch_code];
    
    lut = zeros(12, 15);  % 12 rows (0-11 errors) of 15 columns (4-syndrome, 11-pattern)
    
    for i = 1:11
        temp_code_msg = code_message;
        temp_code_msg(i) = 1;   % Simulate error in i-th position
        syndrome = bch_encoder(temp_code_msg);
        
        lut(i + 1, 1:4) = syndrome;
        lut(i + 1, 5:15) = temp_code_msg(1:11);
    end
end 

%---------------------------------------------------------
% Function to get errorcode from LUT using syndrome
function errorcode = use_LUT(syndrome, lut)
    errorcode = zeros(1, 11);
    
    % Iterate through LUT and check first 4 columns for matching syndrome
    for i = 1:12    % 12 rows in LUT
        if lut(i, 1:4) == syndrome
            errorcode = lut(i, 5:15);
            break;
        end
    end
end
