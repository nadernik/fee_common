% How does filtering actual pitch trajectories change them?

close all
clear all

filename = 'c:\stetner\data\pitchfluctuations\mes011_nodc.mat'; % file to load for real data
d = load(filename);
nfft    = d.nfft;
freqmag = sqrt(mean(d.freqpower, 2));
freq    = d.freq;


%% Make filter like before (fit)
% 
% % throw out low frequencies for fitting
% keep = freq >= 50;
% fitfreq = freq(keep);
% fitfreqmag = freqmag(keep);
% 
% % do the fitting
% coefguesses = [24 0.02 1 ];
% fiteq = fittype('a*exp(-b*x)+c',...
%      'dependent',{'y'},'independent',{'x'},...
%      'coefficients',{'a', 'b', 'c'});
% myfit = fit(fitfreq,fitfreqmag,fiteq,'Startpoint',coefguesses);
% f_filter = [myfit(freq); myfit(flipdim(freq, 1))];

%% Make filter like before

freqpower = sqrt(mean(d.freqpower, 2));
% freqpower = sqrt(d.freqpower(:,1));
f_filter = [freqpower; flipdim(freqpower, 1)];

% f_filter = ones(size(f_filter)); %%%DEBUG
%% Apply to actual pitch trajectories

for n = 1:size(d.pitches, 2)
    % filter this trial
    filtered = ifft(d.fftcoefs(:, n) .* f_filter);
    filtered = real(filtered(1:size(d.pitches, 1)));
    filtered = filtered ./ d.e(:, 1);
    clf
    plot(d.pitches(:, n))
    hold all
    plot(filtered)
    pause
end
    