function bStatus = daq_appendProperty(filename, nameStr, valueStr)
%Append a name value pair to the end of the file.  

%Can only be called on file of file format -4 or newer.

%nameStr: the name of the property to be appended to the datafile
%valueStr: the value of the property to be appended to the datafile

%Init names and values to empty
names = {};
values = {};

%Open the file
fid = fopen(filename,'r');
%Read first element in the file which is the file format
trigFileFormat = fread(fid, 1, 'float64');
fclose(fid);

if(trigFileFormat <= -4)
    fid = fopen(filename,'a');
    fwrite(fid, [length(nameStr)], 'float64');
    fprintf(fid, '%s', nameStr);
    fwrite(fid, [length(valueStr)], 'float64');
    fprintf(fid, '%s', valueStr);
    fclose(fid);
    bStatus = true;
else
    bStatus = false;
    warning('Name value pair could not be appended to the specified data file.  The file version is too old.');
end