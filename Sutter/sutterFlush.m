function sutterFlush(s)

n=get(s,'BytesAvailable');
if  n > 0
    temp=fread(s,n); 
end
