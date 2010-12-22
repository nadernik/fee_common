function ndx = time2ndx(t, sampRate);

ndx = round((t.*sampRate) + 1);