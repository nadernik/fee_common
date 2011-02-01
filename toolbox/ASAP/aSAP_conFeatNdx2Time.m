function timeSecs = aSAP_conFeatNdx2Time(featNdx, fs_param, winstep_param, window_param);
%fs_param is the sampling rate that SAP resamples the audio to before
%computing features and spectral derivatives.

%time: 0           1           2           3           4
%sig:  x  x  x  x  x  x  x  x  x  x  x  x  x  x  x  ...
%     \------|------/
%     window size = 5
%           \------|------/  
% winstep = 2     \------|------/
%feat:       x     x     x     x     x     x     x ...

if(~exist('window_param'))
    window_param = 409;
end
if(~exist('winstep_param'))
    winstep_param = 44;
end

timeSecs = (featNdx-1) * ((winstep_param)/fs_param) + ((window_param-1)/fs_param/2);

