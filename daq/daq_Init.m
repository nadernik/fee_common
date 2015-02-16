function [s, actInSampleRate, actOutSampleRate, actUpdateFreq] = daq_Init(inChannels, inSampleRate, outChannels, outSampleRate, bufferSecs, updateFreq, logFile, realtimeFcnHandle)
%This function initializes the continuous data acquisition buffers and
%configures the daq hardware appropriately.  After this function has
%completed, daq_Start must be called to begin acquisition.

%The continuous data acquisition buffer stores the last n seconds of data
%on all input channels.  Peek functions can be used to extract data from
%buffer into matlab variables for analysis.  Trigger functions can be used
%to save windows of data to disk.

%inChannels:  array of hardware input channel indicies that you wish to include in the
%data buffer.

%inSampleRate:  the number of samples per second you would like to collect
%on all input channels.  The DAQ hardware can not achieve arbitrary sampling rates.
%The closest available sampling rate will be returned in the variable actInSampleRate.
%The higher the rate the more demanding the computing needs.  High rates 
%can result in instability.  

%outChannels:  array of hardware output channel indicies that will needed
%for your application.

%ouSampleRate:  the number of samples per second you would like to collect
%on all output channels.  The DAQ hardware can not achieve arbitrary sampling rates.
%The closest available sampling rate will be returned in the variable actOutSampleRate.
%The higher the rate the more demanding the computing needs.  High rates 
%can result in instability. 

%bufferSecs:  the length of the input data buffer in Secs.  ex.  The value 60 would
%result in a one minute long buffer.

%updateFreq:  the number of times per second the buffer will be updated.
%An update involves moving data from the data acquisition hardware buffer into the
%software buffer maintained by this toolbox.  Increasing the frequency of
%updates allows for better quasi-realtime processing, but increases the computing
%demands of the toolbox.  Values that are too high will result in
%instability.  Values that are too low will result in overflow of the hardware buffers.
%NOTE: the update freq must result in a integer number of samples per
%update.  Therefore not all update frequencies are possible, the closest
%value greater then the specifed value is choses and returned as
%actUpdateFreq.

%realtimeFcnHandle (optional):  a function pointer, which if specified, is called 
%after each buffer update.  The signature of the function must 
%be [] = function(buffer, bufferTimeStamps, mostRecentSampNdx, samplesPerUpdate)
%This function specified for quasi-realtime analysis 
%or realtime data visualization.   Use of this function should be reserved for
%tasks that require temporal precision, because its use will result in heavy
%computing loads.  If the realtimeFcn is too computationally demanding, the
%toolbox will become unstable.  Note that parameters passed to the realtimeFcnHandle
%can be modified if need be (contact andalman@mit.edu)

%OUTPUT:
%ai = handle of the analog input object
%ao = handle of the analog output object
%actInSampleRate = the actual input sample rate achieved.
%actOutSampleRate = the actual output sample rate achieved.
%actUpdateFreq = the actual frequence with with buffer updates will occur.

%%GFL I'm not confident code for analog output, test before use.

%informational globals
%global GAI;
global GS;
global GINCHANS;
global GOUTCHANS;
global COUNT;
global NUMBUFFERUNITS;
global GLISTENERS;

%buffer related globals
global BUFFERUNITSIZE;
global GDAQDATA;
global GDAQTIME;
global BTRIGGER;
global NPEEK;

%logging related globals
global DAQLOGFILENAME;
global DAQLOGFID;


%COUNTER
COUNT = 0;

%LISTENERS
if isempty(GLISTENERS)
    GLISTENERS = {};
end

if((nargin < 7) || isequal(logFile,''))
    DAQLOGFILE = '';
    DAQLOGFID = -1;
else
    DAQLOGFILE = logFile;
    try
        DAQLOGFID = fopen(logFile, 'a');
        daq_log('Begin Logging');
        if(DAQLOGFID == -1)
            error;
        end
    catch
        DAQLOGFILE = '';
        DAQLOGFID = -1;
        warning('Start logging failed.');
    end
end

if(nargin < 8)
    realtimeFcnHandle = [];
    breal = false;
else
    breal = true;
end

%% Initialized DAQ session
hasIn = ~isempty(inChannels);
hasOut = ~isempty(outChannels);
hasChan = hasIn || hasOut;
if hasChan
    d = daq.getDevices();
    assert(numel(d) > 0, 'No DAQ found');
    niIdx = 0;
    for dNo = 1:numel(d)
        if strcmp(d(dNo).Vendor.ID, 'ni')
            niIdx = dNo;
        end
    end
    assert(niIdx > 0, 'No working NI daq found');
    dID = d(niIdx).ID;
    s = daq.createSession('ni');
    GS = s;
    if hasIn
        if hasOut
            assert(outSampleRate == inSampleRate, 'conflicting sample rates');
        end
        rate = inSampleRate;
    else
        rate = outSampleRate;
    end
    %assert(rate <= s.RateLimit, 'Hardware cannot support that sampling rate');
    s.Rate = rate;% up to 200000
    actRate = s.Rate;
    s.IsContinuous = true; %DAQ will continuously acquire data!
end
%Open a session: the available contructors (Device Ids) are revealed by daqhwinfo('nidaq')
%% Attach input channels
if hasIn
    actInSampleRate = actRate;
    GINCHANS = inChannels;
    aiCh = addAnalogInputChannel(s, dID, inChannels,'Voltage');
    for chNo = 1:numel(aiCh)
        aiCh(chNo).TerminalConfig = 'Differential'; %SingleEnded, NonReferencedSingleEnded, Differential, PseudoDifferential
        aiCh(chNo).Range = [-10.0, 10.0]; %Force range if necessary
    end
else
    GINCHANS = [];
    ai = [];
    actInSampleRate = 0;
    actUpdateFreq = 0;
end

%% Attach output channels
if hasOut
    GOUTCHANS = outChannels;
    aoCh = addAnalogOutputChannel(s, dID, outChannels,'Voltage');
else
    GOUTCHANS = [];
    ao = [];
    actOutSampleRate = 0;
end

%% Set up sampling rate and buffering:
if hasIn
    %SampleRate
    %Set bufferUnitSize to integer value such that actUpdateFreq >= updateFreq
    bufferUnitSize = floor(actInSampleRate / updateFreq);
    actUpdateFreq = actInSampleRate / bufferUnitSize;
    BUFFERUNITSIZE = bufferUnitSize;
    
    %Set up buffer
    bufferLength = ceil(actUpdateFreq * bufferSecs);    %Length of buffer in terms of number update units
    NUMBUFFERUNITS = 0; %Running total number of buffer units recorded.
    GDAQDATA = zeros(bufferUnitSize*bufferLength,numel(inChannels));
    GDAQTIME = zeros(bufferUnitSize*bufferLength,1); 
    BTRIGGER = zeros(numel(inChannels), 1);
    NPEEK = 0;
    
    %Set buffer update fcn
    lhi = addlistener(s, 'DataAvailable', @(src, event) daq_bufferUpdate(src, event, bufferUnitSize, bufferLength, breal, realtimeFcnHandle));
    GLISTENERS = [GLISTENERS, {lhi}];
    s.NotifyWhenDataAvailableExceeds = BUFFERUNITSIZE; %Trigger DataAvailable event when this many samples acquired
end

%Trivial output configuration
if hasOut
    actOutSampleRate = actRate;
    defaultValue = 0;
    outDur = s.DurationInSeconds;
    nOut = numel(outChannels);
    outData = defaultValue*ones(round(actOutSampleRate*outDur), 1);
    outData = repmat(outData, [1, nOut]);
    queueOutputData(s, outData);
    lho = addlistener(s, 'DataRequired', @(src, event) queueOutputData(src, outData));
    GLISTENERS = [GLISTENERS, {lho}];
end
lhe = addlistener(s, 'ErrorOccurred', @daq_errcleanup);
GLISTENERS = [GLISTENERS, {lhe}];
daq_log(['Done Initing: BufferUnitSize: ', num2str(BUFFERUNITSIZE)]);
end

function daq_errcleanup(src, event)
daq_Quit();
end

