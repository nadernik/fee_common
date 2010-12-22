function gui_songTriggerTimerFcn(obj, event, exper, fs, recordingHandle, inChans, preBuffSamps, postBuffSamps, currScoreHandle songDuration, durationThreshold, ratioThreshold, minFreq, maxFreq)

nextPeek = getTimer UserData;

%100ms overlap with previous data collected, so as to make sure song isn't
%missed
[data, time, sampNum] = daq_peek(round(nextPeek-fs/10)); 
set timer user data nextPeek = sampNum+length(time);
audio = data(:,1);
        
%Take specgram and measure power in each time-slice
[bDetect, tElapsed, score] = songDetector5(audio, fs, songDuration, durationThreshold, ratioThreshold, minFreq, maxFreq, bDebug);
set current score to score, or plot last 100 scores    

if(~daq_isRecording(exper.audioCh))
    %Since not currently recording this bird, check for song start.
    if( bDetect)
        %If sufficient power to signify song, then begin recording
        songStartSampNum = sampNum;
        set timer user data startSampNum = ...
        [filenamePrefix, filenum] = getNewDatafilePrefix(exper);
        [bStatus, startSamp, filenames] = daq_recordStart(songStartSampNum - preSamps, [exper.dir, filenamePrefix], inChans);
        if(~bStatus)
            warning('Start recording failed' );
        else
            disp(['Started recording.', num2str(filenum)]); 
        end
        set timer user data stopSamp = sampNum + length(time) - 1;
    end
else
    %Since already recording this bird, check for silence and file
    %getting too long.
    if( (bDetect) & (sampNum - songStartSampNum < 500000))
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
                if(((timeV(4) == 24) | (timeV(4) == 0)) & (timeV(5) > 3))
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
                elseif(char == '7')
                    currchan = 7;                       
                elseif(char == 'y')
                    if(~bPaused)
                        bPaused = true;
                        disp('paused.');
                        oldThres = pwThres;
                        pwThres = 300000;
                    else
                        bPaused = false;
                        disp('restarted.');
                        pwThres = oldThres;
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
                        disp('Recording for 60 seconds');
                        pause(60);
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
                         subplot(2,1,1);
                         if(length(audio)>0)
                            displayAudioSpecgram(audio, exper.desiredInSampRate);
                         end
                         title(['AUDIO: ', exper.birdname, exper.expername, ' ',num2str(currnum), ' ', timeCreated]);
                         timeAxis = [0:length(audio)-1]/exper.desiredInSampRate;
                         subplot(2,1,2);              
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
            
        end
    end        
end