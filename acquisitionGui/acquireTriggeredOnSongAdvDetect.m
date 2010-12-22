function acquireTriggeredOnSongAdvDetect(exper)
%Start daq and monitor audio for songs.  Acquire songs and signals that
%occur during songs.  Save as files to the exper directory.

%exper: An experiment structured created using createExper.

%Initialize the daq toolbox
daqreset;

h = figure(1000);
%input channels
inChans = [];
if(exper.audioCh>-1)
    inChans = [exper.audioCh];
else
    error('No audio channel.  Cannot monitor for singing.');
end
inChans = [inChans, exper.sigCh];

%parameters
buffer= 90; %Seconds
updateFreq = 4; %Hz
[ai, ao, actInSampleRate, actOutSampleRate, actUpdateFreq] = daq_Init(inChans, exper.desiredInSampRate, [], 1, buffer, updateFreq);

daqSetup.actInSampleRate = actInSampleRate;
daqSetup.actOutSampleRate = actOutSampleRate;
daqSetup.buffer = buffer;
daqSetup.actUpdateFreq = actUpdateFreq;
save([exper.dir,'daqSetup',datestr(now,30),'.mat'], 'daqSetup');
    
%Start data acquisition
daq_Start;
disp('Filling buffer.');
pause(5);
disp('Starting audio monitoring.');

%These parameters are currently fixed, but in the future they could be
%included in the birdSongDesc variable.
preSamps = ceil(1*actInSampleRate); %Save data 1 seconds prior song start.
postSamps = ceil(1*actInSampleRate); %Save date 1 seconds after song end.

%Song Detection Parameters
%Copied From songDetector1.m
%Parameters for part 1.  Spectrogram Parameters
windowSize = fix(actInSampleRate/20);
windowOverlap = fix(windowSize*.5);

%Parameters for Part 2.  Frequency range in which songs typically has
%power, and power threshold.
minFreq = 1000; 
maxFreq = 7000;
minNdx = floor((windowSize/actInSampleRate)*minFreq + 1);
maxNdx = ceil((windowSize/actInSampleRate)*maxFreq + 1);
durationThreshold = .5;
ratioThreshold = 3;

%Parameters for part 3
songDuration = .5;
windowLength = round((actInSampleRate * songDuration) / (windowSize-windowOverlap)); %song average .9 seconds in length
windowAvg = repmat(1/windowLength,1,windowLength);

%Monitor channels for song like audio, and save as songs:
filenum = getLatestDatafileNumber(exper)
currnum = filenum; %Number of currently selected datafile.
plotnum = 0; %Number of currently displayed datafile.
if(length(exper.sigCh) > 0)
    currchan = exper.sigCh(1);
else
    currchan = exper.audioCh;
end
plotchan = currchan;
[data, time, sampNum] = daq_peekLast(ceil(actInSampleRate)); %grab last second of data
nextPeek = sampNum+length(time);
bPaused = false;
bDisplay = false;
while(true)
    tic
    audio = data(:,1);
        
    %Take specgram and measure power in each time-slice
    [b,f,t] = specgram(audio, windowSize, actInSampleRate, windowSize, windowOverlap);

    powerSong = mean(abs(b(minNdx:maxNdx,:)), 1);
    powerNonSong = mean(abs(b([1:minNdx-1,maxNdx+1:end],:)), 1) + eps;
    songRatio = powerSong./powerNonSong;
    thresCross = (songRatio>ratioThreshold);
    songDet = conv(thresCross,windowAvg);
    score = max(songDet);
    
    if(~daq_isRecording(exper.audioCh))
        %Since not currently recording this bird, check for song start.
        if( score > durationThreshold )
            %If sufficient power to signify song, then begin recording
            songStartSampNum = sampNum;
            [filenamePrefix, filenum] = getNewDatafilePrefix(exper);
            [bStatus, startSamp, filenames] = daq_recordStart(songStartSampNum - preSamps, [exper.dir, filenamePrefix], inChans);
            if(~bStatus)
                warning('Start recording failed' );
            else
                disp(['Started recording.', num2str(filenum)]); 
            end
            stopSamp = sampNum + length(time) - 1;
        end
    else
        %Since already recording this bird, check for silence and file
        %getting too long.
        if( (score > durationThreshold) & (sampNum - songStartSampNum < 500000))
            stopSamp = sampNum + length(time) - 1;
        end
        if( sampNum + length(audio) - 1 - stopSamp > postSamps )
            songEndSampNum = sampNum + length(audio) - 1;
            [bStatus, endSamp] = daq_recordStop(songEndSampNum, inChans);
            if(~bStatus)
                warning('Song stop recording failed.');
            else
                disp('Stopped recording.'); 
            end
            currnum = filenum;
        end
    end
    
    %Wait for new samples to be collected
    while(toc < .9)
        if(~daq_isRecording(exper.audioCh))
            t_start = toc;
           
            h = figure(1000);
            if(toc < .9)
                
                %Check if it is nighttime.  If so shut down, and set timer
                %to start back up.
                timeV = datevec(now);
                if(((timeV(4) == 24) | (timeV(4) == 0)) & (timeV(5) == 3))
                    disp('Stopping for night.  Restart timer set.');
                    daqreset;
                    timerAcqRestart = timer('TimerFcn', {'CBacquireTriggeredOnSongAdvDetect', exper});
                    startat(timerAcqRestart,now+(8/24)); %Restart 8 hours later.
                    return;
                end
                %Check for user input and handle appropriately.
                char = get(h, 'CurrentCharacter');
                set(h,'CurrentCharacter','~');
                if(char == 'p')
                    playAudio(exper, currnum);
                elseif(char == ',')
                    currnum = currnum -1;
                    if(currnum < 1 )
                        currnum = 1;
                    end
                elseif(char == '.')
                    currnum = currnum + 1;
                    if(currnum > filenum)
                        currnum = filenum;
                    end
                elseif(char == '0')
                    currchan = 0;                    
                elseif(char == '1')
                    currchan = 1;
                elseif(char == '2')
                    currchan = 2;
                elseif(char == '3')
                    currchan = 3;
                elseif(char == '5')
                    currchan = 5;
                elseif(char == '7')
                    currchan = 7;                       
                elseif(char == 'y')
                    if(~bPaused)
                        bPaused = true;
                        disp('paused.');
                        oldThres = durationThreshold;
                        durationThreshold = 2;
                    else
                        bPaused = false;
                        disp('restarted.');
                        durationThreshold = oldThres;
                        nextPeek = daq_getCurrSampNum;
                    end
                elseif(char == 'r' | char == 't')
                    recSampNum = daq_getCurrSampNum;
                    [filenamePrefix, filenum] = getNewDatafilePrefix(exper);
                    [bStatus, startSamp, filenames] = daq_recordStart(recSampNum, [exper.dir, filenamePrefix], inChans);
                    if(~bStatus)
                        warning('Forced Start recording failed' );
                    else
                        disp(['Forced Started recording.', num2str(filenum)]); 
                    end
                    if(char == 't')
                        disp('Recording for 30 seconds');
                        pause(30);
                    elseif(char == 'r')
                        pause(.01);
                        char = '';
                        while(true)
                            pause(.05);
                            char = get(h, 'CurrentCharacter');
                            set(h,'CurrentCharacter','~');
                            if(char == 'r')
                                break;
                            end
                        end
                    end
                    recSampNum = daq_getCurrSampNum;
                    [bStatus, endSamp] = daq_recordStop(recSampNum, inChans);
                    if(~bStatus)
                        warning('Song stop recording failed.');
                    else
                        disp('Forced Stopped recording.'); 
                    end
                    currnum = filenum;
                    nextPeek = recSampNum;     
                elseif(char == 'd')
                    bDisplay = ~bDisplay
                elseif(char == 'q')
                    daqreset;
                    return;
                end
                pause(.05);
            end                        
            
            if(toc < .9)
                h = figure(1000);
                if( currnum~=0 & (plotnum ~= currnum | plotchan~= currchan))
                    
                    if(bDisplay)
                         audio = loadAudio(exper,currnum);   
                         [sig, sigTimes, HWChannels, startSamp, timeCreated] = loadData(exper,currnum,currchan);
                         s1 = subplot(2,1,1);
                         timeAxis = [0:length(audio)-1]/exper.desiredInSampRate;
                         if(length(audio)>0)
                             %plot(timeAxis,audio);
                             displayAudioSpecgram(audio, exper.desiredInSampRate, 0, 8000, [-27,15]);
                         end
                         title(['AUDIO: ', exper.birdname, exper.expername, ' ',num2str(currnum), ' ', timeCreated]);                         
                         s2 = subplot(2,1,2);  
                         linkaxes([s1,s2],'x');
                         if(length(sig)>0)
                             plot(timeAxis, sig);
                             axis tight;
                         else
                             warning('Length 0 recorded');
                             currnum
                         end
                         title(['SIGNAL: ', exper.birdname, exper.expername, ' ',num2str(currnum), ' ', timeCreated]);
                         plotnum = currnum;
                         plotchan = currchan;
                        
                         if((toc) - t_start > .9)
                            disp(['warning: display code running too slowly:', num2str((toc) - t_start)]);    
                         end    
                     end
                     
                end
            end
        else
            %We're recording currently, so only check for urgent user
            %commands, like pause:
            char = get(h, 'CurrentCharacter');
            set(h,'CurrentCharacter','~');
            if(char == 'y')
                if(~bPaused)
                    bPaused = true;
                    disp('paused.');
                    oldThres = durationThreshold;
                    durationThreshold = 2;
                end
            end
        end
    end        

    %grab new data with 100ms overlap
    [data, time, sampNum] = daq_peek(round(nextPeek-actInSampleRate/10)); 
    nextPeek = sampNum+length(time);
end