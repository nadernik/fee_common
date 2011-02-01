function birdFileList = example_storeSongs(experName, numBirds, desiredInputSampleRate, birdSongStartDesc, birdSongEndDesc)
%Monitors audio on several channels and saves periods of time that contain
%songs to disk.  2 secs of audio are saved prior to the song start.  Once
%the song beings audio will continue to be saved used no song occurs for a
%continuous 1 sec of time.

%experName: Name of the experiment used to generate a folder in which data is stored
%numBirds: The number of birds to monitor.
%birdSongStartDesc: A cell array containing descriptions of each birds song.
%                   Potentially used to improve song detection accuracy.  Currently not implemented.
%birdSongEndDesc:   A cell array containing for criteria for the end of
%                   each birds song or song bout.

%Setup simple directory structure
experDir = [experName, datestr(clock,30)];
mkdir(experDir);
for(i = 1:numBirds)
    birdDir{i} = [experDir,'/','bird',num2str(i)];
    mkdir(birdDir{i});
end

%Initialize the daq toolbox
%Assume bird 1 audio on hardware channel 1, bird 2 audio on channel hardware 2... 
[ai, ao, actInSampleRate, actOutSampleRate, actUpdateFreq] = daq_Init([1:numBirds], desiredInputSampleRate, [], 1, 90, 4);

%Start data acquisition
daq_Start;
pause(2);

%Set counters and clear records.
count = ones(numBirds,1);

%Song Detection Parameters
%These parameters are currently fixed, but in the future they could be
%included in the birdSongDesc variable.
minFreq = 2000; %Frequency range in which song has power
maxFreq = 8000;
pwThres = .15; %Power threshold for song trigger
preSamps = ceil(2*actInSampleRate); %Save data 2 seconds prior song start
windowSize = fix(actInSampleRate/10); %spectragram window size.

%Convert frequency range to indices in fft.
minNdx = floor((windowSize/actInSampleRate)*minFreq + 1);
maxNdx = ceil((windowSize/actInSampleRate)*maxFreq + 1);

%Monitor channels for song like audio, and save as songs:
[data, time, sampNum] = daq_peekLast(ceil(actInSampleRate)); %grab last second of data
while(true)
    tic
    
    for(nBird = 1:numBirds)
        audio = data(:,nBird);
        
        %Take specgram and measure power in each time-slice
        [b,f,t] = specgram(audio, windowSize, actInSampleRate);
        power = mean(abs(b(minNdx:maxNdx,:)), 1);
               
        if(~daq_isRecording(nBird))
            %Since not currently recording this bird, check for song start.
            if( max(power) > pwThres )
                %If sufficient power to signify song, then be recording on
                %channel.
                [power, ndx] = max(power);
                songStartSampNum = sampNum + round(t(ndx) * length(audio));
                filename = [birdDir{nBird}, '/', datestr(clock,30),'_',num2str(count(nBird))];
                [bStatus, samp, filename] = daq_recordStart(songStartSampNum - preSamps, filename, nBird);
                if(~bStatus)
                    warning('Start recording failed on channel ',num2str(nBird));
                else
                    disp(['Started recording channel ',num2str(nBird)]); 
                    birdFileList{nBird}{count(nBird)} = filename;
                    count(nBird) = count(nBird) + 1;
                end
            end
        else
            %Since already recording this bird, check for song ending.
            if( max(power) <  pwThres )
                %If quiet for a whole second then consider song bout over.
                songEndSampNum = sampNum + length(audio) - 1;
                [bStatus, samp] = daq_recordStop(songEndSampNum, nBird);
                if(~bStatus)
                    warning('Song stop recording failed on channel ', num2str(nBird));
                else
                    disp(['Stopped recording channel ', num2str(nBird)]); 
                end
            end
        end
    end
    
    %Wait for new samples to be collected
    while(toc < .9)
        pause(.05);
    end        

    %grab new data with 100ms overlap
    [data, time, sampNum] = daq_peek(round(sampNum+length(time)-actInSampleRate/10)); 
end