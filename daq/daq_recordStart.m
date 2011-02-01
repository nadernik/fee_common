function [bStatus, startSamp, filenames] = daq_recordStart(startSamp, filename, channels)
%daq_recordStart begins saving a set of channels to a file starting from
%sample number startSamp (presuming that startSamp has not already exited
%the buffer).  daq_recordStop must be called to bring recording to an end.
%Each channel will be saved to a separate file.

%Use daq_getCurrSampNum to get the number of the most recent sample added
%to the buffer.

%Note that each channel can only be recorded to one file at a time.  This restriction
%may be lifted in the future.

%startSamp:  the sample number from which to being saving to disk
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

%Warning:  specifing a startSamp that precedes the buffer will result in a
%warning message, but a file will none-the-less be saved.  The first sample
%in the file will be the earliest sample in the buffer.  Therefore, the 
%most accurate record of the startSamp number is the one written at the
%beginning of the data file itself, not the one returned by this function!

%Warning:  Specifing an existing file name will cause data to be appended
%to the existing file.  This can result in unreadable files or
%discontinuous files.

OPEN_ENDED = -2;
[bStatus,ss,se,filenames] = daq_record(startSamp, OPEN_ENDED, filename, channels);

