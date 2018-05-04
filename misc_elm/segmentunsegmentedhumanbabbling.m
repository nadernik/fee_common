%% 4229 12 mos
[~,fs] = wavread('C:\Users\emackev\Documents\BABBLING\BABBLINGNEW\4229\4229-12mo-16-32-m.wav',1);

tstart = fs*(60*41);
tstop = fs*(60*42+25); 
[audio,fs] = wavread('C:\Users\emackev\Documents\BABBLING\BABBLINGNEW\4229\4229-12mo-16-32-m.wav',[tstart tstop]);
N = length(audio);
for i = 1: 10
    A = audio(ceil(N*(i-1)/10+1):ceil(N*i/10)); 
    wavwrite(A,fs,['sample12mo41minSection', num2str(i)]); 
end
wavwrite(audio,fs,'sample12mo41min'); 

%% 4220 12 mos
[~,fs] = wavread('C:\Users\emackev\Documents\BABBLING\BABBLINGNEW\4220\4220-12mo-16-32-m.wav',1);
pathname = 'C:\Users\emackev\Documents\BABBLING\BABBLINGNEW\4220\samples12mo'
%~26
tstart = fs*(60*26+14);
tstop = fs*(60*26+20); 
[audio,fs] = wavread('C:\Users\emackev\Documents\BABBLING\BABBLINGNEW\4220\4220-12mo-16-32-m.wav',[tstart tstop]);
wavwrite(audio,fs,fullfile(pathname,'sample12mo26min')); 
%~50
tstart = fs*(60*50+02);
tstop = fs*(60*50+30); 
[audio,fs] = wavread('C:\Users\emackev\Documents\BABBLING\BABBLINGNEW\4220\4220-12mo-16-32-m.wav',[tstart tstop]);
wavwrite(audio,fs,fullfile(pathname,'sample12mo50min')); 
%~51
tstart = fs*(60*51);
tstop = fs*(60*51+10); 
[audio,fs] = wavread('C:\Users\emackev\Documents\BABBLING\BABBLINGNEW\4220\4220-12mo-16-32-m.wav',[tstart tstop]);
wavwrite(audio,fs,fullfile(pathname,'sample12mo51min'));
%~28
tstart = fs*(60*28+44);
tstop = fs*(60*29); 
[audio,fs] = wavread('C:\Users\emackev\Documents\BABBLING\BABBLINGNEW\4220\4220-12mo-16-32-m.wav',[tstart tstop]);
wavwrite(audio,fs,fullfile(pathname,'sample12mo28min')); 
%~28
tstart = fs*(60*28+24);
tstop = fs*(60*28+28); 
[audio,fs] = wavread('C:\Users\emackev\Documents\BABBLING\BABBLINGNEW\4220\4220-12mo-16-32-m.wav',[tstart tstop]);
wavwrite(audio,fs,fullfile(pathname,'sample12mo28min1')); 



