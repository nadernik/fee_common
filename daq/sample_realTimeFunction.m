 function sample_realTimeFunction(buffer, bufferTimeStamp, mostRecentSampNdx, samplesPerUpdate)
 %Simple demo of real-time function usage.
 
 %buffer: array containing buffered data
 %bufferTimeStamp: array containing time each buffer sample was taken
 %mostRecentSampNdx: index of most recent sample within the circular buffer
 %samplePerUpdate: the number of data points that are added to the buffer
 %with each updata.
 
 %Set the current figure to real-time plot
 h = figure(1000);
 set(h,'DoubleBuffer','on');
 
 %Deal with buffer wraparound by converting desired samples into buffer
 %indices.
 ndx = mod([mostRecentSampNdx-samplesPerUpdate*10:mostRecentSampNdx-1],length(bufferTimeStamp)) + 1;
 
 %plot it.
 plot(buffer(ndx))