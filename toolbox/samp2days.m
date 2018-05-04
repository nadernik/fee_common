function days = samp2days(samples, Fs)
% SAMP2DAYS Converts number of samples in Hz to days

seconds = samples / Fs;
days = samples / Fs  / 60  / 60 / 24;
%                secs mins hours days