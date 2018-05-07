function segs = DA_segmenter(amp, fs, th, min_dur, min_stop)
% ElectroGui segmenter
nAmp = numel(amp);
minAmp = min(amp);
th = th-minAmp;
amp = amp-minAmp;

% Find threshold crossing points
overthresh = [0; amp; 0] >= th; % pad for calculation below
onsets = find(~overthresh(1:end-1) & overthresh(2:end))-1;
f = zeros(numel(onsets), 2);
f(:,1) = onsets;
f(:,2) = find(overthresh(1:end-1) & ~overthresh(2:end))-1;

% Eliminate VERY short syllables
f = f(f(:,2) - f(:,1) > min_dur / 2 * fs, :);

% Extend syllables to a lower threshold
mn = mean(amp(amp < th));
st = std(amp(amp < th));
thnew = min([th, mn + 2 * st]);
for c = 1:size(f, 1)
    newstart = f(c, 1);
    while newstart > 1 && amp(newstart - 1) >= thnew
        newstart = newstart - 1;
    end
    f(c, 1) = newstart;
    newstop = f(c, 2);
    while newstart < nAmp && amp(newstop + 1) >= thnew
        newstop = newstop + 1;
    end
    f(c,2) = newstop;
end

% Eliminate short syllables
f = f(f(:, 2) - f(:, 1) > min_dur * fs, :);

if isempty(f)
    segs = zeros(0,2);
else
    % Eliminate short intervals
    if size(f,1) > 1
        i = [find(f(2:end,1)-f(1:end-1,2) > min_stop*fs); length(f)];
        f = [f([1; i(1:end-1)+1],1) f(i,2)];
    end

    segs = f;
end
end