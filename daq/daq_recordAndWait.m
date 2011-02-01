function [bStatus, startSamp, endSamp, filenames] = daq_recordAndWait(startSamp, endSamp, filename, channels)
%Record specifies a window of samples to be saved to a file.  The
%window can span from the beginning of the buffer to any point in the
%future, with the restriction that distant points in the future will result
%in enormous files.  Currently all data is saved as double precision
%floats.  

%Use daq_getCurrSampNum to get the number of the most recent sample added
%to the buffer.

%Note that each channel can only be recorded to one file at a time.  This restriction
%may be lifted in the future.

%This function specifies a range of samples to record, and waits for 
%recording to complete.

%startSamp:  the sample number of the beginning of the window to be
%   saved to disk
%endSamp: the sample number of the end of the window to be to be saved to
%   disk.
%filename:  the filename to which the window of data should be saved.  The
%   string should not include the file type.
%channels:  array of HW channel numbers, specifing which channels should 
%   be saved to disk.

%bStatus:  Array of booleans, same length as channels.  Returns true if recording 
%   started successfully on the channel specified by the same index in the
%   channels array.  Note, this will be true even if startSamp precedes
%   the buffered window.
%startSamp:  Returned copy of the input startSamp value.  
%endSamp:  Returned copy of the input endSamp value.

%Warning:  specifing a startSamp that precedes the buffer will result in a
%warning message, but a file will none-the-less be saved.  The first sample
%in the file will be the earliest sample in the buffer.  Therefore, the 
%most accurate record of the startSamp number is the one written at the
%beginning of the data file itself, not the one returned by this function!

%Warning:  Specifing an existing file name will cause data to be appended
%to the existing file.  This can result in unreadable files or
%discontinuous files, unless used carefully.


[bStatus, ss, es, filenames]  = daq_trigger(startSamp, endSamp, filename, channels);
if(bStatus)
    daq_waitForRecording(channels);
end

