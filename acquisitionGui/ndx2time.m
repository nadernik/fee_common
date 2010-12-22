function t = ndx2time(ndx, sampRate);

%Here is how the time / ndx things works:
%Ndx 1 represents time 0.  Index 2 represents time 1/sampRate. etc...

%If marker = 10.  Then you want Ndx 10 to represent time 0, so you subtract
%(marker-1) from the index before calling ndx2time.

t = (ndx - 1)./sampRate;