% this script extract the features out of the binary file and also compute harmonic pitch estimates.

% usage:    bindata=fopen('c:\sound_file.dat'); % open data file   

%                bin_features; % retrive the data into the workspace

i=1;

while(~feof(bindata))

            tmp =fread(bindata,1,'int16=>int'); if(length(tmp))LogPower(i)=double(tmp)/10; end;

            tmp= fread(bindata,1,'int16=>int'); if(length(tmp)) AM(i)=double(tmp)/100; end;

            tmp= fread(bindata,1,'int8=>int');  if(length(tmp)) MeanFreq(i)=43.0*(double(tmp)+120); end; 

            tmp= fread(bindata,1,'int8=>int');  if(length(tmp)) Pitch(i)=43.0*(double(tmp)+120); end;

            tmp= fread(bindata,1,'int16=>int'); if(length(tmp)) Entropy(i) =double(tmp)/100; end;

            tmp= fread(bindata,1,'int16=>int'); if(length(tmp)) FM(i)=double(tmp)/10; end;

            tmp= fread(bindata,1,'int16=>int'); if(length(tmp)) Pgood(i)=double(tmp)/10; end; 

            % calculate harmonic and pure tone pitch estimates:

            % the pitch is harmonic by default, but if the following

            % conditions apply, we preffer the mean frequency (previously

            if( length(tmp) & ((Pgood(i)<100 & Entropy(i)<-2) | Pitch(i)>1800) ) Pitch(i)=MeanFreq(i);end;

            i=i+1;

        end;

fclose(bindata);