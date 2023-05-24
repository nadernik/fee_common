function [S,Time,F] = spectrogramELM(song,fs,specDT, makePlot, fpass, BandwidthProduct, winsize,Time)

if nargin < 7; winsize = .02; end
if nargin < 6; BandwidthProduct = 150; end
if nargin < 5; fpass = [500 8000]; end
if nargin < 4; makePlot = 0; end
if nargin < 3; specDT = .005; end


if round(specDT*fs*1e5) ~= round(specDT*fs*1e5) % 1e5 to deal with machine precision errors (eg round(40.0000)~=40);
    error('Must choose winstep with integer number of bins')
end

winstep =specDT;
if nargin < 8
    Time = (winstep:winstep:(length(song)/fs))-winstep;
end

% parameters for chronux spectrogram
params.Fs = fs;
params.fpass = fpass;
T = winsize;
W = BandwidthProduct; % frequency bandwidth product
K = 1; %number of tapers
params.tapers = [T*W K];
movingwin = [winsize winstep];

% zeropad song by 1 windowsize so we can keep the spectrogram the right length
zpSong = [zeros(round(winsize*fs),1); song(:); zeros(round(winsize*fs),1)];

% calculate spectrogram using chronux function
[Szp,tzp,F]=mtspecgramc(zpSong,movingwin,params);

% recover part of spectrogram corresponding to original signal
tind_start = find(abs(tzp-winsize)<=winstep/2);
tind = tind_start + Time/winstep;
if winstep<1
    tind = round(tind/10/winstep)*10*winstep; % to get rid of rounding from weird machine-precision errors
end
if nargin <8
    S = Szp(tind,:)';
else
    S = Szp';
end


% plotting stuff
if makePlot
    % to make black background, set everything below threshold to threshold, then cmap(1,:) = zeros(1,3); % background = black
    %     cmap(1,:) = zeros(1,3);
        cmap = flipud(brewermap(138,'Spectral'));
%         cmap(64:74,:) = []; % remove all that ugly yellow
%     cmap = jet(128);
    %     cmap = 1/256*flipud([158,1,66;213,62,79;244,109,67;253,174,97;254,224,139;255,255,191;230,245,152;171,221,164;102,194,165;50,136,189;94,79,162;1 1 1]);%cbrewer spectral, modified
    %     cmap = flipud(gray);
    %     cmap = parula(256);
    
    cmap = [         0         0         0
    0.0227    0.0306    0.1357
    0.0455    0.0612    0.2714
    0.0682    0.0918    0.4071
    0.0910    0.1224    0.5427
    0.1137    0.1529    0.6784
    0.1130    0.1618    0.6845
    0.1122    0.1707    0.6906
    0.1115    0.1796    0.6966
    0.1108    0.1885    0.7027
    0.1100    0.1973    0.7088
    0.1093    0.2062    0.7148
    0.1085    0.2151    0.7209
    0.1078    0.2240    0.7270
    0.1071    0.2329    0.7330
    0.1063    0.2417    0.7391
    0.1056    0.2506    0.7452
    0.1048    0.2595    0.7512
    0.1041    0.2684    0.7573
    0.1034    0.2772    0.7634
    0.1026    0.2861    0.7694
    0.1019    0.2950    0.7755
    0.1011    0.3039    0.7816
    0.1004    0.3128    0.7876
    0.0997    0.3216    0.7937
    0.0989    0.3305    0.7998
    0.0982    0.3394    0.8058
    0.0974    0.3483    0.8119
    0.0967    0.3572    0.8180
    0.0960    0.3660    0.8240
    0.0952    0.3749    0.8301
    0.0945    0.3838    0.8362
    0.0937    0.3927    0.8422
    0.0930    0.4016    0.8483
    0.0923    0.4104    0.8544
    0.0915    0.4193    0.8605
    0.0908    0.4282    0.8665
    0.0900    0.4371    0.8726
    0.0893    0.4459    0.8787
    0.0886    0.4548    0.8847
    0.0878    0.4637    0.8908
    0.0871    0.4726    0.8969
    0.0863    0.4815    0.9029
    0.0856    0.4903    0.9090
    0.0849    0.4992    0.9151
    0.0841    0.5081    0.9211
    0.0834    0.5170    0.9272
    0.0826    0.5259    0.9333
    0.0819    0.5347    0.9393
    0.0812    0.5436    0.9454
    0.0804    0.5525    0.9515
    0.0797    0.5614    0.9575
    0.0789    0.5703    0.9636
    0.0782    0.5791    0.9697
    0.0775    0.5880    0.9757
    0.0767    0.5969    0.9818
    0.0760    0.6058    0.9879
    0.0752    0.6147    0.9939
    0.0745    0.6235    1.0000
    0.0701    0.6457    1.0000
    0.0657    0.6678    1.0000
    0.0614    0.6900    1.0000
    0.0570    0.7121    1.0000
    0.0526    0.7343    1.0000
    0.0482    0.7564    1.0000
    0.0438    0.7785    1.0000
    0.0394    0.8007    1.0000
    0.0351    0.8228    1.0000
    0.0307    0.8450    1.0000
    0.0263    0.8671    1.0000
    0.0219    0.8893    1.0000
    0.0175    0.9114    1.0000
    0.0131    0.9336    1.0000
    0.0088    0.9557    1.0000
    0.0044    0.9779    1.0000
         0    1.0000    1.0000
    0.0556    1.0000    0.9444
    0.1111    1.0000    0.8889
    0.1667    1.0000    0.8333
    0.2222    1.0000    0.7778
    0.2778    1.0000    0.7222
    0.3333    1.0000    0.6667
    0.3889    1.0000    0.6111
    0.4444    1.0000    0.5556
    0.5000    1.0000    0.5000
    0.5556    1.0000    0.4444
    0.6111    1.0000    0.3889
    0.6667    1.0000    0.3333
    0.7222    1.0000    0.2778
    0.7778    1.0000    0.2222
    0.8333    1.0000    0.1667
    0.8889    1.0000    0.1111
    0.9444    1.0000    0.0556
    1.0000    1.0000         0
    1.0000    0.9524         0
    1.0000    0.9048         0
    1.0000    0.8571         0
    1.0000    0.8095         0
    1.0000    0.7619         0
    1.0000    0.7143         0
    1.0000    0.6667         0
    1.0000    0.6190         0
    1.0000    0.5714         0
    1.0000    0.5238         0
    1.0000    0.4762         0
    1.0000    0.4286         0
    1.0000    0.3810         0
    1.0000    0.3333         0
    1.0000    0.2857         0
    1.0000    0.2381         0
    1.0000    0.1905         0
    1.0000    0.1429         0
    1.0000    0.0952         0
    1.0000    0.0476         0
    1.0000         0         0
    0.9814         0         0
    0.9627         0         0
    0.9441         0         0
    0.9255         0         0
    0.9068         0         0
    0.8882         0         0
    0.8696         0         0
    0.8509         0         0
    0.8323         0         0
    0.8137         0         0
    0.7950         0         0
    0.7764         0         0
    0.7578         0         0
    0.7391         0         0
    0.7205         0         0
    0.7019         0         0
    0.6832         0         0
    0.6646         0         0
    0.6460         0         0
    0.6273         0         0
    0.6087         0         0
    0.5901         0         0
    0.5714         0         0];
    offset = 2;
    cmap(1:offset,:) = repmat([0 0 0],offset,1); % set baseline black
    colormap(cmap);
    Plot = 10*log10(S+eps);
    p_thresh = 75; % thresholding the spectrogram
    Plot(Plot(:)<prctile(Plot(:),p_thresh)) = prctile(Plot(:),p_thresh);
    imagesc(Time,F/1000,Plot); axis tight;
    set(gca, 'ydir', 'normal')
    %      surf(Time, F/1000, Plot,'edgecolor','none'); axis tight; view(0,90);
    ylabel('Frequency (kHz)'); xlabel('Time (s)')
    shg
end