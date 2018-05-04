function displaySpectralDerivative(specDeriv, sampAdv, startTime, maxfreq, colorRange, inchPerSec, inchPerkHz)

if(~exist('inchPerSec'))
    inchPerSec = 3;
end

if(~exist('inchPerkHz'))
    inchPerSec = .2;
end

if(~exist('startTime'))
    startTime = 0;
end
stepTime = sampAdv/44100;
endTime = startTime + stepTime*(size(specDeriv,2)-1);
freq = [0:44100/1024:22050-1];
  
h = gcf;
set(h, 'doublebuffer','on');

%To plot the specgram we take the log of the power at each time and each
%frequency and display it as color
ndx = find(freq<maxfreq);
if(~exist('colorRange'))
    imagesc(startTime:stepTime:endTime,freq(ndx),specDeriv(ndx,:)); 
else
    imagesc(startTime:stepTime:endTime,freq(ndx),specDeriv(ndx,:), colorRange); 
end
colormap(gray);
axis xy;
xlabel('time (s)');
ylabel('freq (Hz)');


width = min((endTime-startTime)*inchPerSec, 9);

hf = gcf;
ha = gca;       
set(ha,'Units','inches');
set(ha,'Position',[.75,.5,width, (maxfreq/1000)*inchPerkHz]);
set(hf,'PaperPosition',[.25,2.5,width+1,(maxfreq/1000)*inchPerkHz + 1]);
set(hf,'Units','inches');
set(hf,'Position',[.25,2.5,width+1,(maxfreq/1000)*inchPerkHz + 1]);

if(((endTime-startTime)*inchPerSec) > 9)
    zoom xon;
    zoom(((endTime-startTime)*inchPerSec)/9);
    zoom off;
end
pan xon;
    
    
    

