function noise = testRulesTdt(vec, RP, suf)

tags.testMode = ['testMode' suf];
tags.testAudio = ['testAudio' suf];
tags.testIndex = ['testIndex' suf];
tags.testNoise = ['testNoise' suf];

RP.SoftTrg(2);
% set tdt to test mode so it will get input from buffer not from external
RP.SetTagVal(tags.testMode, 1);
% based on Continuous Play example from TDT's ActiveX User Guide.
noise = zeros(size(vec));
bufpts = 50000; % one half of SerialBuf length
[chunk, idx, eof] = helper_getChunk(vec,0,bufpts*2);
startIdx = 1;
RP.WriteTagV(tags.testAudio, 0, chunk'); %start by filling the whole buffer
% Start Playing
RP.SoftTrg(1)
% keyboard %%%DEBUG
curindex=RP.GetTagVal(tags.testIndex);
while true % will break from inside the loop when end of vec is reaced

    while(curindex < bufpts) % wait for first half to finish
        curindex=RP.GetTagVal(tags.testIndex);
    end

    % get results from first half and load new audio into first half while
    % second half is playing
    noise(startIdx:startIdx+bufpts-1) = RP.ReadTagV(tags.testNoise,0,bufpts);
    startIdx = startIdx+bufpts;
    if eof
        % no more data left to load. just wait for the last of it to be
        % tested and read out last part of results
        endpts = length(chunk);
        while curindex < bufpts+endpts
            curindex = RP.GetTagVal(tags.testIndex);
        end
        noise(startIdx:startIdx+endpts-1) = RP.ReadTagV(tags.testNoise,bufpts,endpts);
        break
    end
    [chunk, idx, eof] = helper_getChunk(vec,idx,bufpts);
    RP.WriteTagV(tags.testAudio, 0, chunk');

    % Checks to see if the data transfer rate is fast enough
    curindex=RP.GetTagVal(tags.testIndex);
    if(curindex < bufpts)
        disp('Transfer rate is too slow');
    end

    

    while(curindex > bufpts) % wait for second half to finish
        curindex=RP.GetTagVal(tags.testIndex);
    end

    % get results from second half and load new audio into second half while first half is playing
    noise(startIdx:startIdx+bufpts-1) = RP.ReadTagV(tags.testNoise,bufpts,bufpts);
    startIdx = startIdx+bufpts;
    if eof
        % no more data left to load. just wait for the last of it to be
        % tested and read out last part of results
%         keyboard %%%DEBUG
        endpts = length(chunk);
        while curindex < endpts
            curindex = RP.GetTagVal(tags.testIndex);
        end
        noise(startIdx:startIdx+endpts-1) = RP.ReadTagV(tags.testNoise,0,endpts);
        break
    end
    [chunk, idx, eof] = helper_getChunk(vec,idx,bufpts);
    RP.WriteTagV(tags.testAudio, bufpts, chunk');

    % Checks to see if the data transfer rate is fast enough
    curindex=RP.GetTagVal(tags.testIndex);
    if(curindex > bufpts)
        disp('Transfer rate is too slow');
    end
end
RP.SetTagVal(tags.testMode, 0); %back to normal mode
% keyboard  %%%DEBUG


function [chunk, idx, eof] =  helper_getChunk(vec, lastidx, len)
eof = false;
idx = lastidx + len;
if idx > length(vec)
    eof = true;
    idx = length(vec);
end
chunk = vec(lastidx+1:idx);
keyboard %%%DEBUG
