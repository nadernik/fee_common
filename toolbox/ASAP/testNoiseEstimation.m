function out = testNoiseEstimation(wavfilenames, path)

bDebug = false;

singingSumm.path = path;
sec2dn = (24*60*60);

for(nFile = 1:length(wavfilenames))
    [audio,fs] = wavread([path,filesep,wavfilenames{nFile}]);

    %demean the audio.
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
    filt3.order = 50; %sufficient for 44100Hz of lower
    filt3.win = hann(filt3.order+1);
    filt3.cutoff = 860; %Hz
    filt3.fs = fs;
    filt3.hpf = fir1(filt3.order, filt3.cutoff/(filt3.fs/2), 'high', filt3.win);
    audio = filter(filt3.hpf, 1, audio);

    %compute log power
    audioLogPow = log(audio.^2 + eps);

    %smooth the power, lpf:
    filt.order = 100; 
    filt.win = hann(filt.order+1);
    filt.cutoff = 50; %Hz
    filt.fs = fs;
    filt.lpf = fir1(filt.order, filt.cutoff/(filt.fs/2), 'low', filt.win);
    audioLogPow = filter(filt.lpf, 1, audioLogPow);


    %estimate the noise and sound levels by finding the lowest and highest peaks in the estimated probability
    %distribution:
    %[f,x] = ksdensity(audioLogPow); %estimate probability distribtuion.
    %figure(117); subplot(2,1,1);
    %plot(x,f);
    
    %Run EM algorithm on mixture of two gaussian model:
    
    %set initial conditions
    l = length(audio);
    len = 1/l;
    m = sort(audioLogPow);
    uNoise = mean(m(1:end/2));
    uSound = mean(m(end/2:end));
    sdNoise = .5;
    sdSound = 2;
  
    %compute estimated likeilyhood given these initial conditions...
    prob = zeros(2,l);
    prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2)))./sdNoise;
    prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2)))./sdSound;
    [estProb, class] = max(prob);
    logEstLike = sum(log(estProb)) * len;        
    logOldEstLike = -Inf;
    
    nSteps = 0;
    while(abs(logEstLike-logOldEstLike) > .005)
        logOldEstLike = logEstLike;
        
        nndx = find(class==1);
        sndx = find(class==2);
        
        %Maximize classification
        uNoise = mean(audioLogPow(nndx));
        sdNoise = std(audioLogPow(nndx));
        uSound = mean(audioLogPow(sndx));
        sdSound = std(audioLogPow(sndx));
        
        %Re-estimate...
        prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2)))./sdNoise;
        prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2)))./sdSound;
        [estProb, class] = max(prob);
        logEstLike = sum(log(estProb)) * len;       
    end
    
    %out.x{nFile} = x;
    %out.f{nFile} = f;
    out.uNoise(nFile) = uNoise;
    out.sdNoise(nFile) = sdNoise;
    out.uSound(nFile) = uSound;
    out.sdSound(nFile) = sdSound;
    out.numSound(nFile) = length(find(class==2));
    out.numNoise(nFile) = length(find(class==1));
    out.logEstLike(nFile) = logEstLike;
    
    %line([uNoise,uNoise],ylim,'Color','red');
    %line([uSound,uSound],ylim,'Color','green');
   
    %subplot(2,1,2);
    %plot(audio);
    %drawnow;
end

