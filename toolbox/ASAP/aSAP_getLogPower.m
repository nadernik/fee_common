function [sigLogPow, filteredAudio] = aSAP_getLogPower(sig, fs)

persistent prstFilt3;
persistent prstFilt1;

%historic code used variable name audio instead of sig.
flip = size(sig,2)>size(sig,1);
if(flip)
    sig = sig';
end

audio = sig;

audio = audio - mean(audio);

%include only very relevant power:
%below 8600Hz
%filt2.order = 50; %sufficient for 44100Hz of lower
%filt2.win = hann(filt2.order+1);
%filt2.cutoff = 8600; %Hz
%filt2.fs = fs;
%filt2.lpf = fir1(filt2.order, filt2.cutoff/(filt2.fs/2), 'low', filt2.win);
%audio = filtfilt(filt2.lpf, 1, audio);

%above 860Hz
if(isempty(prstFilt3) || (prstFilt3.fs ~= fs))
    prstFilt3.order = 50; %sufficient for 44100Hz of lower
    prstFilt3.win = hann(prstFilt3.order+1);
    prstFilt3.cutoff = 860; %Hz
    prstFilt3.fs = fs;
    prstFilt3.hpf = fir1(prstFilt3.order, prstFilt3.cutoff/(prstFilt3.fs/2), 'high', prstFilt3.win);
end
%audio = filtfilt(prstFilt3.hpf, 1, audio);
audio = fftfilt(prstFilt3.hpf, audio);
audio = [audio(floor(length(prstFilt3.hpf)/2):end); zeros(floor(length(prstFilt3.hpf)/2)-1,1)];


%compute power
audioPow= audio.^2; 

%smooth the power, lpf:
if(isempty(prstFilt1) || (prstFilt1.fs ~= fs))
    prstFilt1.order = 100; 
    prstFilt1.win = hann(prstFilt1.order+1);
    prstFilt1.cutoff = 50; %Hz
    prstFilt1.fs = fs;
    prstFilt1.lpf = fir1(prstFilt1.order, prstFilt1.cutoff/(prstFilt1.fs/2), 'low', prstFilt1.win);
end
%audioPow = filtfilt(prstFilt1.lpf, 1, audioPow);
audioPow = fftfilt(prstFilt1.lpf, audioPow);
audioPow = [audioPow(floor(length(prstFilt1.lpf)/2):end); zeros(floor(length(prstFilt1.lpf)/2)-1,1)];

%compute log Pow
audioLogPow = log(audioPow + eps);

filteredAudio = audio;
sigLogPow = audioLogPow;

if(flip)
    sigLogPow = sigLogPow';
end
