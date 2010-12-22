function playAudio(exper,numOrAudio)
%Find datafile num in the appropriate experiment folder.  Then open it.

if(length(numOrAudio) == 1)
    audio = loadAudio(exper,numOrAudio);
else
    audio = numOrAudio;
end

soundsc(audio,exper.desiredInSampRate);
    
