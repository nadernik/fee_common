function [ai, ao, actInSampleRate, actOutSampleRate, actUpdateFreq] = daq_Init(inChannels, inSampleRate, outChannels, outSampleRate, bufferSecs, updateFreq, logFile, realtimeFcnHandle)
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

%informational globals
global GAI;
global GAO;
global GINCHANS;
global GOUTCHANS;
global COUNT;
global NUMBUFFERUNITS;

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

%Open a session: the available contructors (Device Ids) are revealed by daqhwinfo('nidaq')
if(length(inChannels) > 0)
    GINCHANS = inChannels;
    try
        ai = analoginput('nidaq', 1);
    catch
        try
            ai = analoginput('nidaq', 'Dev1');
        catch
            ai = analoginput('nidaq', 'Dev2');
        end
    end
    GAI = ai;
    %Trigger Type (setting Manual prevents BLUE*SCREEN*!!!!)
    set(ai,'TriggerType','Manual');
    set(ai,'ManualTriggerHwOn','Trigger')
    %Signal Mode
    set(ai, 'InputType', 'Differential'); %Referenced and NonReferenced are also options.
    %Transfer Data Setup
    ai.BufferingMode = 'Auto';
    set(ai,'TransferMode','SingleDMA'); %'SingleDMA' , 'Interrupts'  
else
    GINCHANS = [];
    ai = [];
    actInSampleRate = 0;
    actUpdateFreq = 0;
end


if(length(outChannels) > 0)
    GOUTCHANS = outChannels;
    try
        ao = analogoutput('nidaq', 1);
    catch
        ao = analogoutput('nidaq', 'Dev1');
    end
    GAO = ao;
    set(ao,'TriggerType','Manual');
    ao.OutOfDataMode = 'DefaultValue'; %When no more output, return each channle to its default value.
    %Transfer Data Setup
    ao.BufferingMode = 'Auto';
    set(ao,'TransferMode','SingleDMA');
else
    GOUTCHANS = [];
    ao = [];
    actOutSampleRate = 0;
end


%Create channels:
if(length(inChannels) > 0)
    ichan = addchannel(ai,inChannels)
    for(ndx = 1:length(inChannels) )
        set(ichan(ndx), 'SensorRange' ,[-10,10]);%Potential range of the input.
        set(ichan(ndx), 'InputRange' ,[-10,10]);%Expected range across which we digitize. Discrete Set of possible values ([-10,10], [-5,5], [-.5,.5], [-.05,.05])
        set(ichan(ndx), 'UnitsRange'  ,[-10,10]); %Scaling of input into desired units.
    end
end
if(length(outChannels) > 0)
    ochan(ndx) = addchannel(ao,outChannels);
    for(ndx = 1:length(outChannels) )
        ochan(ndx).DefaultChannelValue = 0; %The voltage value at which the output channel sits by default.
    end        
end

%Set up sampling rate and buffering:
if(length(inChannels) > 0)
    %SampleRate
    set(ai,'SamplesPerTrigger',inf)   %Value / SampleRate equals seconds of recording
    set(ai,'SampleRate',inSampleRate) % up to 200000
    actInSampleRate = get(ai,'SampleRate');
    
%No longer used:  Code to generate bufferUnitSize that is even divisor of actInSampRate    
%     %Find actualUpdateFreq based on actual sample rate (choosen to be as
%     %small as possible without going under desired rate.
%     possUnitSize = divisors(actInSampleRate) %divisor sof the actual Sample Rate are possible sizes for buffer updates
%     if(length(possUnitSize) == 1)
%         daqreset;
%         error(['The resulting actual sample rate, ', num2str(actInSampleRate), ', only has one divisor.  Please choose a different sample rate.']);
%     end
%     possUnitSize = possUnitSize(find(possUnitSize <= (actInSampleRate/updateFreq))); %find divisors less than or equal to the desired
%     if(length(possUnitSize) == 0)
%         daqreset;
%         error(['The resulting actual sample rate, ', num2str(actInSampleRate), ', is not compatible with your update freq.  Please choose a different sample rate, or lower your update freq.']);
%     end
%     bufferUnitSize = max(possUnitSize); %size of buffer update unit

    %Set bufferUnitSize to integer value such that actUpdateFreq >= updateFreq
    bufferUnitSize = floor(actInSampleRate / updateFreq);
    actUpdateFreq = actInSampleRate / bufferUnitSize;
    BUFFERUNITSIZE = bufferUnitSize;
    
    %Set up buffer
    bufferLength = ceil(actUpdateFreq * bufferSecs);    %Length of buffer in terms of number update units
    NUMBUFFERUNITS = 0; %Running total number of buffer units recorded.
    GDAQDATA = zeros(bufferUnitSize*bufferLength,length(inChannels));
    GDAQTIME = zeros(bufferUnitSize*bufferLength,1); 
    BTRIGGER = zeros(length(inChannels), 1);
    NPEEK = 0;
    
    %Set buffer update fcn
    set(ai,'SamplesAcquiredFcn',{'daq_bufferUpdate', bufferUnitSize, bufferLength, breal, realtimeFcnHandle})
    set(ai,'SamplesAcquiredFcnCount',bufferUnitSize)
    set(ai,'StopFcn',@daqcallback);
end

%Trivial output configuration
if(length(outChannels) > 0)
    set(ao,'SampleRate',outSampleRate)
    actOutSampleRate = get(ao,'SampleRate');
    set(ao,'StopFcn',@daqcallback);
end

daq_log(['Done Initing: BufferUnitSize: ', num2str(BUFFERUNITSIZE)]);

