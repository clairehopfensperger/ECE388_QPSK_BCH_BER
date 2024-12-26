# ECE388_QPSK_BCH_BER
ECE 388: Smartphone Technologies final project - Plot the BER of 8PSK with and without BCH(15, 11, 1) error correction. 

Collaborated with Chris Lallo, Blake Rile, and Cody Radabaugh.

<br>

## 8PSK
8PSK is a modulation scheme that encodes three bits per symbol.

<br>

<p align = "center">
  <img src = "https://github.com/clairehopfensperger/ECE388_QPSK_BCH_BER/blob/main/Images/8PSK_Gray_Coding.png" width = 400>
  <br>
  8PSK Constellation with Gray Coding
  <br>
</p>

<br>

## BCH(15, 11, 1) Error Correction
BCH is a powerful cyclic block code that, in this project, can correct up to one bit error per 15-bit message.

BCH(15, 11, 1) Parameters:
- n = 15 message bits
- k = 11 data bits
- n - k = 4 check bits
- Generator Polynomial: x^4 + x + 1

<br> 

<p align = "center">
  <img src = "https://github.com/clairehopfensperger/ECE388_QPSK_BCH_BER/blob/main/Images/BCH_15_11_1_Error_Correction.png" width = 600>
  <br>
  BCH(15, 11, 1) Encoder
  <br>
</p>

<br>

## Project Results
As seen in the graph below, for different Signal-to-Noise Ratio (SNR) values, the Bit Error Rate (BER) was better/lower when using BCH coding versus not using any coding.

<br>

<p align = "center">
  <img src = "https://github.com/clairehopfensperger/ECE388_QPSK_BCH_BER/blob/main/Images/ECE388_Final_Project_Results.png" width = 500>
  <br>
  SNR vs. BER plot of BCH coded and uncoded 8PSK
  <br>
</p>

<br>
