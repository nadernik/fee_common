function [filteredSignal, label] = egf_HanningHighPass(signal, fs, Params)
% ElectroGui filter
% Code from Aaron Andalman
%
% fs used to be hardcoded at 44100Hz. If used with 40000Hz data this
% reduced the cutoff frequency by 1.1025x. For the default frequency of
% 750Hz and 40000Hz data, the actual cutoff would be at 680 Hz.
label = 'High-pass filtered';
%% Return default parameters if signal is 'params' string
if ischar(signal) && strcmp(signal, 'params')
    filteredSignal.Names = {'Cutoff frequency (Hz)', 'Order'};
    filteredSignal.Values = {'750', '80'};
    return
end
%% Extract parameters
cutoffFreq = str2double(Params.Values{1}); %Hz
filterOrder = str2double(Params.Values{2}); %80 sufficient for 44100Hz of lower
%% Configure and create filter
nyquistFreq = fs / 2;
filtWindow = hann(filterOrder + 1);
highPassFilt = fir1(filterOrder, cutoffFreq / nyquistFreq, 'high', filtWindow);
%% Filter data
filteredSignal = filtfilt(highPassFilt, 1, signal);