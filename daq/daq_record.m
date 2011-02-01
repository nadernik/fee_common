function [bStatus, startSamp, endSamp, filenames] = daq_record(startSamp, endSamp, filename, channels)
%daq_record specifies a window of samples to be saved to file.  Each channel is
%saved to a seperate file.  The window of samples can span from the beginning of the 
%buffer to any point in the future, with the restriction that distant 
%points in the future will result in enormous files.  Currently 
%all data are saved as double precision floating point numbers.  

%Use daq_getCurrSampNum to get the number of the most recent sample added
%to the buffer.

%Note that each channel can only be recorded to one file at a time.  This restriction
%may be lifted in the future.

%Note, This function specifies a range of samples to record, but does not wait for 
%recording to complete. Thus other code can run, while recording is taking place.
%To determine when recording is complete use daq_isRecording,
%daq_waitForRecComplete or daq_recordAndWait.

%startSamp:  the sample number of the beginning of the window to be
%   saved to disk
%endSamp: the sample number of the end of the window to be to be saved to
%   disk.
%filename:  the filename to which the data should be saved.  The
%   string should not include the file type (i.e. .dat).  Each channel will 
%   be saved to separate file.  The channel number will be appended to the 
%   filename.
%channels:  array of HW channel numbers, specifing which channels should 
%   be saved to disk.

%bStatus:  Array of booleans, same length as channels.  Returns true if recording 
%   started successfully on the channel specified by the same index in the
%   channels array.  Note, this will be true even if startSamp precedes
%   the buffered window.
%startSamp:  Returned copy of the input startSamp value.  
%endSamp:  Returned copy of the input endSamp value.
%filenames: array of filenames to which the data will be saved.

%Warning:  specifing a startSamp that precedes the buffer will result in a
%warning message, but a file will none-the-less be saved.  The first sample
%in the file will be the earliest sample in the buffer.  Therefore, the 
%most accurate record of the startSamp number is the one written at the
%beginning of the data file itself, not the one returned by this function!

%Warning:  Specifing an existing file name will cause data to be appended
%to the existing file.  This can result in unreadable files or
%discontinuous files, unless used carefully.

global GINCHANS
global BTRIGGER;
global TRIGGERFILENAME;
global TRIGGERSTART;
global TRIGGEREND;

%convert hardware channel numbers into matlab channel indices.
%[junk, matchannels] = intersect(GINCHANS, channels); %intersect function does not preserve order
matchannels = [];
for(i = 1:length(channels))
    matchannels(i) = find(GINCHANS == channels(i));
end

bStatus = zeros(length(matchannels), 1);
filenames = {};

%Attempt to only start recording if all specified channels are not busy.
if(~BTRIGGER(matchannels))
    
    %Start each channel.  It is possible that one channel will become busy
    %in process.  If this occuring recording will begin on some of the
    %channels but not all of them.
    for(i = 1:length(matchannels))
		if(~BTRIGGER(matchannels(i)))
            TRIGGERSTART(matchannels(i)) = startSamp;
            TRIGGEREND(matchannels(i)) = endSamp;
            filenames{i} = [filename, 'chan', num2str(channels(i)), '.dat'];
            TRIGGERFILENAME{matchannels(i)} = [filename, 'chan', num2str(channels(i)), '.dat'];
            BTRIGGER(matchannels(i)) = true;
            bStatus(i) = true;
		else
            bStatus(i) = false;
		end
	end
    
end
    
