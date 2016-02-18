[a,fs] = audioread('Z:\emackev\Tutors\GoodMotifRhythm\Cage31White126.wav');

a = a-mean(a); 
L = length(a); 
if mod(L,2) == 1; % need even
    a = [a; 0]; 
    wasodd = 1;
else
    wasodd = 0; 
end
y = fft(a); 
% determine location of frequency bins
df = fs/L; % frequency resolution; 
f = df*([0:(L/2-1) ((L/2-1):-1:0)]);% frequencies calculated
y(f<500) = 0; 
snd = real(ifft(y)); 
if wasodd
    snd = snd(1:end-1); 
end
figure(1); plot(f,y)
sound(a,fs); 
pause(length(a)/fs); 
sound(snd,fs)
displaySpecgramQuick(a,fs)
audiowrite('Z:\emackev\Tutors\GoodMotifRhythm\Cage31White126_filtered.wav',...
    snd/max(abs(snd)),fs)