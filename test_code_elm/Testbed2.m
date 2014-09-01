% this file was just used to compare different spectrogram functions --
% displaySpecgramQuick is the one to use.  
close all; clear all; clc;
[bells,fs] = wavread('OferSongs/bells.wav');
[S,F,T,P] = spectrogram(bells, 512, 500, 1024, fs);
idx = find(F<8000);
h = surf(T,F(idx),10*log10(abs(S(idx,:))));
axis tight; 
view(0,90);
set(h, 'edgecolor', 'none')
set(gca, 'units', 'normalized')
colormap('gray')
figure; displayAudioSpecgram(bells,fs)
colormap('gray')
figure; displaySpecgramQuick(bells,fs)
colormap('gray')
%figure; spectrogram(bells, 512, 50, 1024, fs);