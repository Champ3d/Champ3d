
clear
clc
Fs = 1000;
t = 0:(1/Fs):1/50+1/Fs;
L = length(t);
S = cos(4*pi*50.*t) + cos(6*pi*50.*t + pi/2);
Y = fft(S);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs/L*(0:(L/2));

figure
stem(f,P1,"LineWidth",3) 
title("Single-Sided Amplitude Spectrum of S(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")