function [pitch, pitchGoodness, harmonicPower, time, entropy] = estimatePitch(audio, fs, varargin)
%each window around the triggers is a row of the windows matrix.
%counts returns (for each column in windows) the number of elements which
%do not contain padding, be the padding be zeroes or nan.
persistent e;

%Default Parameters
%TODO add triggering on particular syllable catagory...
P.winSize = 180; % previously 1024
P.winStep = 40;
P.NFFT = 2^10; %yields 1 Hz precision with 40000 Hz sampling rate.
P.cepsNFFT = 2^10; % previously 2^10
P.minPitchFreq = 400;
P.maxPitchFreq = 3000; % 2000
P.totalPowerRange = [300,min(10000,fs/2)];
P.minEntropyFreq = 400;
P.maxEntropyFreq = 8600;
P.cepsUpperLimit = 8000;%6000;
P.PeakDetect = true;
P.outlierRemoval = [];%100;
P.debug = false;
P = parseargs(P,varargin{:});

if(size(e,1) ~= P.winSize)
    [e] = dpss(P.winSize,1);
end

try
    %demean audio  
    audio = audio - mean(audio);
    
    %take spectrogram
    [s,f,time,p] = spectrogram(audio, e(:,1), P.winSize - P.winStep, P.NFFT, fs);

    ffs = fs/P.NFFT; %sampling rate in frequency space.
    ndxmin = round((P.cepsNFFT * ffs / P.minPitchFreq) + 1);
    ndxmax = round((P.cepsNFFT * ffs / P.maxPitchFreq) + 1);
    
    % take log
    logp = log10(p+eps);
       

    %Window the power spectrum before taking the cepstrum
    if(~isempty(P.cepsUpperLimit))
        maxfreqndx = max(find(f<P.cepsUpperLimit));
        logp = logp - repmat(mean(logp(1:maxfreqndx,:),1),size(logp,1),1); %demean
        win = zeros(size(f));
        win(1:sum(f<P.cepsUpperLimit)) = hann(sum(f<P.cepsUpperLimit));
        pWin = repmat(win,1,size(p,2)).*logp;
    else
        logp = logp - repmat(mean(p,1),size(p,1),1); %demean
        pWin = logp;
    end
    
    cepstrum = fft(pWin, P.cepsNFFT);  % takes fft of spectrum at each time.  fft on matrix takes fft of each column.
    %Freq = P.cepsNFFT .* ffs ./ ((1:size(cepstrum,1)-1)+eps); 
    PartialCepstrum = abs(cepstrum(ndxmax:ndxmin, :)); % extract part of cepstrum
    PartialNdx = ndxmax:ndxmin;
    PartialFreq = P.cepsNFFT.*ffs./(PartialNdx-1); % frequency scale for the partial cepstrum
    
    % peak detect
    if P.PeakDetect
        A = diff(PartialCepstrum,1,1); % diff for each time slice
        B = [zeros(1,size(A,2));A(1:end-1,:)]; % finding where the first-order derivative is zero
        C = (B > 0) & (A <=0);
        for t=1:size(PartialCepstrum,2)
            Peak = find(C(:,t));
            [y,i] = max(PartialCepstrum(Peak,t));
            Idx = Peak(i);
            X = Idx-1:Idx+1;
            Y = PartialCepstrum(X,t);
            if ~isempty(X)
                Fit = polyfit(X',Y,2);
                peakNdx(t) = -(Fit(2)/(2*Fit(1))); % peak of the quadratic function
            else
                [peak,peakNdx] = max(PartialCepstrum(:,t)); 
            end
%             if P.debug
%                 figure(51)
%                 clf
%                 hold on
%                 plot(PartialCepstrum(:,t))
%                 ylim([0 30])
%                 h=line([peakNdx(t),peakNdx(t)],ylim);
%                 set(h,'color','r');
%                 hold off
%                 title(['t = ',num2str(time(t))])
%                 
%                 pause(0.1)
%             end            
        end
    else
        [peak,peakNdx] = max(PartialCepstrum); % check for error
    end
    
    peakNdx = peakNdx + (ndxmax-1);
    pitch = P.cepsNFFT .* ffs ./ (peakNdx-1);    
    
    %get total power
    widthHz = f(2) - f(1);
    powerNdx = round(P.totalPowerRange/widthHz) + 1;
    totalPower = widthHz*sum(abs(p(powerNdx(1):powerNdx(2),:)));
    
    %get harmonic power
    power = abs(p);
    power = power(:); 
    harmonicPower = zeros(floor(P.totalPowerRange(2)/P.minPitchFreq),length(pitch));
    for(harmonic = 1:floor(P.totalPowerRange(2)/P.minPitchFreq))
        %determine the ndx of the harmonic in the specgram:
        freqNdx = round((harmonic.*pitch)/widthHz) + 1;
        %do some index magic:
        freqNdx(freqNdx > length(f)-1) = length(f) - 1; %If the harmonic frequency is above the nyquist, set it to the below the nyquist for now, because it will be set to 0 a few lines down.
        ndx = freqNdx + length(f)*[0:length(freqNdx)-1];
        ndx = repmat(ndx, 3, 1) + repmat([-1,0,1]', 1, length(ndx));
        ndx = ndx(:);
        harmonicPower(harmonic, :)  = widthHz*sum(reshape(power(ndx),3,[]));
        harmonicPower(harmonic, freqNdx>powerNdx(2)) = 0; %If the harmonic frequency is above the maximum, set it to 0.
    end   
    pitchGoodness = sum(harmonicPower) ./ totalPower;
    
    %compute entropy
    entrNdx = find(f>P.minEntropyFreq & f<P.maxEntropyFreq);
    sumlog = sum(log(abs(p(entrNdx,:)) + eps));
    logsum = sum(abs(p(entrNdx,:))); 
    logsum(logsum==0) = length(entrNdx); 
    logsum = log(logsum/length(entrNdx));
    entropy = (sumlog/length(entrNdx)) - logsum;
    entropy(logsum==0) = 0;
    
    if ~isempty(P.outlierRemoval)
        pitchNew = pitch;
        y = diff(pitch);
        y = [y,0];
        Idx = find(abs(y) >= P.outlierRemoval);
        pitchNew(Idx+1) = NaN;
        
%         figure(51)
%         ax(1) = subplot(311);
%         hold on
%         plot(pitch,'b','linewidth',2);
%         plot(pitchNew,'r','linewidth',3);
%         ax(2) = subplot(312);
%         plot(pitchNew,'r','linewidth',2);
%         ax(3) = subplot(313);
%         hold on
%         stem(y);
%         h = stem(Idx,y(Idx));
%         set(h,'color','r')
%         %ylim([-300 300])       
%         linkaxes(ax,'x')
        
        pitch = pitchNew;
    end
    
    if P.debug
        figure(50)
        clf
        hold on
        displaySpecgramQuick(audio,fs)
        plot(time,pitch,'r','linewidth',3)
        hold off
    end
    
catch
    pitch = [];
    pitchGoodness = [];
    harmonicPower = [];
    time = [];
    entropy = [];
end
