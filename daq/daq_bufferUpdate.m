function daq_bufferUpdate(~, event, bufferUnitSize, numUnitsInBuff, breal, realtimeFcnHandle)
%!!This function is called internally!!!
%!!It should never be called explicitly!!!

%This internal function moves data from the hardware buffer to the
%software buffer maintained by this toolbox.  It also fulfills trigger and
%peek requests.  Finally, if a realtimeFcn is specified is calls it.

%%% NEVER access these global variables explicitly!
randId = randi(1000);
fprintf('Entered daq_bufferUpdate for update %d\n', randId);
allTic = tic();
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

setupTic = tic();
FILEFORMATID = -4;
daq_log(['numBufferUnits: ', num2str(NUMBUFFERUNITS)]);
nBuff = numUnitsInBuff * bufferUnitSize;
%get data and add to buffer
data = event.Data;
time = event.TimeStamps;
abstime = datevec(event.TriggerTime);
%Not collecting native data -- this is just to maintain file compatibility
nativeDataType = class(event.Data);
buffLocation = mod(NUMBUFFERUNITS, numUnitsInBuff); %Circular buffer
startNdx = buffLocation * bufferUnitSize + 1;
endNdx = buffLocation * bufferUnitSize + bufferUnitSize;
GDAQDATA(startNdx:endNdx, :) = data;
GDAQTIME(startNdx:endNdx) = time;
NUMBUFFERUNITS = NUMBUFFERUNITS + 1;
setupTime = toc(setupTic);
%trigger: storing data to disk
trigTic = tic();
for chanNo = 1:numel(BTRIGGER)
    if BTRIGGER(chanNo) %there is a trigger
        if (TRIGGERSTART(chanNo)==-1) || (NUMBUFFERUNITS * bufferUnitSize >= TRIGGERSTART(chanNo)) %it has started (storing data to disk has started?)
            trigStartNdx = startNdx;
            %If this is first bufferUpdate since trigger started, then open the
            %file and prepare to write to it.
            if (TRIGGERSTART(chanNo)~= -1) && (NUMBUFFERUNITS * bufferUnitSize >= TRIGGERSTART(chanNo))
                if(TRIGGERSTART(chanNo) < max(NUMBUFFERUNITS * bufferUnitSize - bufferUnitSize * numUnitsInBuff + 1, 1))
                    warning('Trigger start outside buffer range.  Truncating start.');
                    TRIGGERSTART(chanNo) = (NUMBUFFERUNITS * bufferUnitSize) - min(NUMBUFFERUNITS * bufferUnitSize, nBuff) + 1;
                end
                if(exist(TRIGGERFILENAME{chanNo}, 'file'))
                    warning('File already exists, data being appended to end of file.')
                end
                trigStartNdx = endNdx - (NUMBUFFERUNITS * bufferUnitSize - TRIGGERSTART(chanNo));
                
                TRIGGERFID(chanNo) = fopen(TRIGGERFILENAME{chanNo}, 'ab'); %'a': append, 'b': binary.
                %First thing in the file is the trigger file format id.
                fwrite(TRIGGERFID(chanNo), FILEFORMATID, 'float64');
                %Next write the time of daq start as a datevec
                fwrite(TRIGGERFID(chanNo), abstime, 'float64');
                %Next write the current time as a datevec
                fwrite(TRIGGERFID(chanNo), datevec(now), 'float64');
                %Next thing in the file is the number of channels.  %With
                %current version there is always one channel per file.
                fwrite(TRIGGERFID(chanNo), 1, 'float64');
                %Next write the channel hardware numbers.
                fwrite(TRIGGERFID(chanNo), GINCHANS(chanNo), 'float64');
                %Next write the native scale and offset for each hardware
                %channel. %With current version there is always one channel per file.
                %No longer collecting data in native format replacing
                %"NativeScaling" with 1 and "NativeOffset" with 0
                fwrite(TRIGGERFID(chanNo), 1.0, 'float64');%NativeScaling
                fwrite(TRIGGERFID(chanNo), 0.0, 'float64');%NativeOffset
                %Next write the native data type followed by file format id.
                fwrite(TRIGGERFID(chanNo), double(nativeDataType), 'float64');
                fwrite(TRIGGERFID(chanNo), FILEFORMATID, 'float64');
                
                %Next write the number of the first sample.
                fwrite(TRIGGERFID(chanNo), TRIGGERSTART(chanNo), 'float64');
                %Next write time of the first sample in the file (in seconds) since daq start
                ndx = mod(trigStartNdx-1,nBuff) + 1;
                fwrite(TRIGGERFID(chanNo), GDAQTIME(ndx), 'float64');
                
                TRIGGERSTART(chanNo) = -1; %Signal that trigger has begun.
            end
            
            trigEndNdx = endNdx;
            if((TRIGGEREND(chanNo) ~= -2) && (NUMBUFFERUNITS * bufferUnitSize >= TRIGGEREND(chanNo)))
                %The end of the trigger is within the buffer, therefore complete the
                %file, and close it.
                triggerEndCopy = TRIGGEREND(chanNo);
                TRIGGEREND(chanNo) = -1;
                trigEndNdx = endNdx - (NUMBUFFERUNITS * bufferUnitSize - triggerEndCopy);
                ndx = mod((trigStartNdx - 1):(trigEndNdx - 1), nBuff) + 1;
                fwrite(TRIGGERFID(chanNo), GDAQDATA(ndx,chanNo)', nativeDataType);
                %Write the trigger file format id THREE times to
                %mark the end of the window of samples.
                fwrite(TRIGGERFID(chanNo), FILEFORMATID, nativeDataType);
                fwrite(TRIGGERFID(chanNo), FILEFORMATID, nativeDataType);
                fwrite(TRIGGERFID(chanNo), FILEFORMATID, nativeDataType);
                %Write the number and time of the last sample in the file
                %for error checking.
                fwrite(TRIGGERFID(chanNo), triggerEndCopy, 'float64');
                ndx = mod(trigEndNdx - 1, nBuff) + 1;
                fwrite(TRIGGERFID(chanNo), GDAQTIME(ndx), 'float64');
                %Close the file.
                fclose(TRIGGERFID(chanNo));
                BTRIGGER(chanNo) = false;
            elseif(trigStartNdx == startNdx)
                %Save the entire latest update to the datafile.
                fwrite(TRIGGERFID(chanNo), data(:, chanNo)', nativeDataType);
            else
                %The latest update to the buffer includes unnessary data, so
                %save on the desired part.  This should only happen on the
                %first update during the trigger.
                ndx = mod((trigStartNdx - 1):(trigEndNdx - 1), nBuff) + 1;
                fwrite(TRIGGERFID(chanNo), GDAQDATA(ndx, chanNo)', nativeDataType);
            end
        end
    end
end
trigTime = toc(trigTic);
%% peek: make recent samples available for processing
peekTic = tic();
if NPEEK ~= 0 % Peak will be non-zero after call to daq_peek
    if NUMBUFFERUNITS * bufferUnitSize < NPEEK %Not enough data to peek
        NPEEK = 0;
        warning('Cannot peek into future');
        PEEKDATASTORE = [];
        PEEKTIMESTORE = [];
    elseif (NUMBUFFERUNITS * bufferUnitSize - NPEEK) > (nBuff)
        NPEEK = 0;
        warning('Peek start is no longer in the buffer.');
        PEEKDATASTORE = [];
        PEEKTIMESTORE = [];
    else
        numSamples = NUMBUFFERUNITS * bufferUnitSize - NPEEK + 1;
        ndx = mod((endNdx - numSamples):(endNdx - 1), nBuff) + 1;
        PEEKDATASTORE = GDAQDATA(ndx,:);
        PEEKTIMESTORE = GDAQTIME(ndx);
        NPEEK = 0;
    end
end
peekTime = toc(peekTic);

if breal
    %real code
    feval(realtimeFcnHandle, GDAQDATA, GDAQTIME, endNdx, bufferUnitSize);
end

daq_log('done')
allTime = toc(allTic);
fprintf('update %d times\tTOTAL:%f\tsetup:%f\ttrig:%f\tpeek:%f\n', randId, allTime, setupTime, trigTime, peekTime);
fprintf('Exited daq_bufferUpdate for update %d\n', randId);