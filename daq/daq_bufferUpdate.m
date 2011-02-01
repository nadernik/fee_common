function daq_bufferUpdate(obj, event, bufferUnitSamps, bufferLength, breal, realtimeFcnHandle)
%!!This function is called internally!!!
%!!It should never be called explicitly!!!

%This internal function moves data from the hardware buffer to the
%software buffer maintained by this toolbox.  It also fulfills trigger and
%peek requests.  Finally, if a realtimeFcn is specified is calls it.

%%% NEVER access these global variables explicitly!

global GINCHANS

%Buffering variables
global NUMBUFFERUNITS;
global GDAQDATA;
global GDAQTIME;

%Triggering variables 
global BTRIGGER;
global TRIGGERFILENAME;
global TRIGGERSTART;
global TRIGGEREND;
global TRIGGERFID;

%Peek variables
global NPEEK
global PEEKDATASTORE; 
global PEEKTIMESTORE;

FILEFORMATID = -4;

daq_log(['numBufferUnits: ', num2str(NUMBUFFERUNITS)]);

%get data and add to buffer
hwinfo = daqhwinfo(obj);
nativeDataType = hwinfo.NativeDataType;
[data,time,abstime] = getdata(obj, bufferUnitSamps, 'native');
buffLocation = mod(NUMBUFFERUNITS, bufferLength);
startNdx = buffLocation*bufferUnitSamps + 1;
endNdx = buffLocation*bufferUnitSamps + bufferUnitSamps;
GDAQDATA(startNdx:endNdx,:) = data;
GDAQTIME(startNdx:endNdx) = time;
NUMBUFFERUNITS = NUMBUFFERUNITS + 1;

%trigger: storing data to disk
for(nChan = 1:length(BTRIGGER))
    if(BTRIGGER(nChan)) %there is a trigger
        if((TRIGGERSTART(nChan)==-1) | (NUMBUFFERUNITS * bufferUnitSamps >= TRIGGERSTART(nChan))) %it has started
            
            trigStartNdx = startNdx;
            %If this is first bufferUpdate since trigger started, then open the
            %file and prepare to write to it.
            if ((TRIGGERSTART(nChan)~=-1) & (NUMBUFFERUNITS * bufferUnitSamps >= TRIGGERSTART(nChan)))
                if(TRIGGERSTART(nChan) < max(NUMBUFFERUNITS*bufferUnitSamps-bufferUnitSamps*bufferLength+1,1))
                    warning('Trigger start outside buffer range.  Truncating start.');
                    TRIGGERSTART(nChan) = (NUMBUFFERUNITS*bufferUnitSamps) - min(NUMBUFFERUNITS*bufferUnitSamps, bufferUnitSamps*bufferLength) + 1;
                end
                if(exist(TRIGGERFILENAME{nChan}, 'file'))
                    warning('File already exists, data being appended to end of file.')
                end
                trigStartNdx = endNdx - (NUMBUFFERUNITS * bufferUnitSamps - TRIGGERSTART(nChan));
                
                TRIGGERFID(nChan) = fopen(TRIGGERFILENAME{nChan}, 'ab'); %'a': append, 'b': binary.
                %First thing in the file is the trigger file format id.
                fwrite(TRIGGERFID(nChan), FILEFORMATID, 'float64');
                %Next write the time of daq start as a datevec 
                fwrite(TRIGGERFID(nChan), abstime, 'float64');
                %Next write the current time as a datevec
                fwrite(TRIGGERFID(nChan), datevec(now), 'float64');
                %Next thing in the file is the number of channels.  %With
                %current version there is always one channel per file.
                fwrite(TRIGGERFID(nChan), 1, 'float64');
                %Next write the channel hardware numbers.
                fwrite(TRIGGERFID(nChan), GINCHANS(nChan), 'float64');
                %Next write the native scale and offset for each hardware
                %channel. %With current version there is always one channel per file.
                fwrite(TRIGGERFID(nChan), get(obj.Channel(nChan),'NativeScaling'), 'float64');
                fwrite(TRIGGERFID(nChan), get(obj.Channel(nChan),'NativeOffset'), 'float64');
                %Next write the native data type followed by file format id.
                fwrite(TRIGGERFID(nChan), double(nativeDataType), 'float64');
                fwrite(TRIGGERFID(nChan), FILEFORMATID, 'float64');
                
                %Next write the number of the first sample.
                fwrite(TRIGGERFID(nChan), TRIGGERSTART(nChan), 'float64');
                %Next write time of the first sample in the file (in seconds) since daq start
                ndx = mod(trigStartNdx-1,length(GDAQTIME)) + 1;
                fwrite(TRIGGERFID(nChan), GDAQTIME(ndx), 'float64');
                
                TRIGGERSTART(nChan) = -1; %Signal that trigger has begun.
            end
	            
            trigEndNdx = endNdx;
            if((TRIGGEREND(nChan)~=-2) & (NUMBUFFERUNITS * bufferUnitSamps >= TRIGGEREND(nChan)))    
                %The end of the trigger is within the buffer, therefore complete the
                %file, and close it.
                triggerEndCopy = TRIGGEREND(nChan);
                TRIGGEREND(nChan) = -1;
                trigEndNdx = endNdx - (NUMBUFFERUNITS * bufferUnitSamps - triggerEndCopy);
                ndx = mod([trigStartNdx-1:trigEndNdx-1],length(GDAQTIME)) + 1;
                fwrite(TRIGGERFID(nChan), [GDAQDATA(ndx,nChan)]', nativeDataType);
                %Write the trigger file format id THREE times to
                %mark the end of the window of samples.
                fwrite(TRIGGERFID(nChan), FILEFORMATID, nativeDataType);
                fwrite(TRIGGERFID(nChan), FILEFORMATID, nativeDataType);
                fwrite(TRIGGERFID(nChan), FILEFORMATID, nativeDataType);
                %Write the number and time of the last sample in the file
                %for error checking.
                fwrite(TRIGGERFID(nChan), triggerEndCopy, 'float64');
                ndx = mod([trigEndNdx-1],length(GDAQTIME)) + 1;
                fwrite(TRIGGERFID(nChan), GDAQTIME(ndx), 'float64');
                %Close the file.
                fclose(TRIGGERFID(nChan));
                BTRIGGER(nChan) = false;    
            elseif(trigStartNdx == startNdx)
                %Save the entire latest update to the datafile.
                fwrite(TRIGGERFID(nChan), [data(:,nChan)]', nativeDataType);
            else
                %The latest update to the buffer includes unnessary data, so
                %save on the desired part.  This should only happen on the
                %first update during the trigger.
                ndx = mod([trigStartNdx-1:trigEndNdx-1],length(GDAQTIME)) + 1;
                fwrite(TRIGGERFID(nChan), [GDAQDATA(ndx,nChan)]', nativeDataType);
            end  
        end
	end
end

%peek: make recent samples available for processing
if(NPEEK)
    if (NUMBUFFERUNITS * bufferUnitSamps < NPEEK)
        NPEEK = 0;
        warning('Cannot peek into future');
        PEEKDATASTORE = [];
        PEEKTIMESTORE = [];
    elseif ((NUMBUFFERUNITS * bufferUnitSamps - NPEEK) > (bufferUnitSamps * bufferLength))
        NPEEK = 0;
        warning('Peek start is no longer in the buffer.'); 
        PEEKDATASTORE = [];
        PEEKTIMESTORE = [];
    else
        numSamples = NUMBUFFERUNITS * bufferUnitSamps - NPEEK + 1;
        ndx = mod([endNdx-numSamples:endNdx-1],length(GDAQTIME)) + 1;
        PEEKDATASTORE = GDAQDATA(ndx,:);
        PEEKTIMESTORE = GDAQTIME(ndx);
        NPEEK = 0;
    end
end

if(breal)
    %real code
    feval(realtimeFcnHandle, GDAQDATA, GDAQTIME, endNdx, bufferUnitSamps);
end

daq_log('done');