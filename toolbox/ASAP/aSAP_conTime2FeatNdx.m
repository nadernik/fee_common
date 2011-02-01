function featNdx = aSAP_conTime2FeatNdx(timeSecs, fs_param, winstep_param, window_param);
%fs_param is the sampling rate that SAP resamples the audio to before
%computing features and spectral derivatives.

%Note: that the features vector is of length:
%(length(audio) - mod(length(audio),win_step)) / window;
%Therefore some valid times in the audio file will have features indices
%that our out of bounds.

%For audio file of length x.  deriv will return a file of length
%floor((x-window_param)/winstep_param) + 1.  

if(~exist('window_param'))
    window_param = 409;
end
if(~exist('winstep_param'))
    winstep_param = 44;
end

shift = (window_param-1) / fs_param;
featNdx = round((timeSecs - shift/2) / (winstep_param/fs_param)) + 1;

