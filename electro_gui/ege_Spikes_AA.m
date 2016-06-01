function [events, labels] = ege_Spikes_AA(data, fs, thres, params)
% Author: Aaron Andalman, 2008.
% Detects spikes using a threshold crossing.  Defines the spike as the
% location of the peak (zenith) and trough (nadir).  Also, addition
% criteria to specified beyond just threshold.
% ElectroGui event detector
% Finds threshold crossings

labels = {'Zenith', 'Nadir'};
if ischar(data) && strcmp(data, 'params')
    events.Names = {'Peak search window (ms)', 'Addition Criteria (variables: zenith, nadir, duration(nadir-zenith secs), isiNadir, isiZenith)(ex. zenith < 1)'};
    events.Values = {'[-.5,.5]', 'abs(duration)>0 & height<Inf'};
    return
end
    
%Orient data properly
if(size(data, 2) > size(data, 1))
    data = data.';
end

%get peak search window in samples.
win = round((str2num(params.Values{1}) / 1000) * fs);
win = win(1):win(2);
if(isempty(win))
    win = 0;
end

%get threshold crossings.
if thres >= 0
    leading = find(data(1:(end - 1)) < thres & data(2:end) >= thres);
else
    leading = find(data(1:(end - 1)) > thres & data(2:end) <= thres);
end

%handle no threshold crossing case.
if(isempty(leading))
    events{1} = [];
    events{2} = [];
    return;
end

%throwout handles in which the threshold touches the edge

offsets = repmat(win, length(leading), 1);
indices = repmat(leading, 1, length(win));
indices = offsets + indices;
indices(indices < 1) = 1;
indices(indices > length(data)) = length(data);
[nadir, nadirNdx] = min(data(indices), [], 2);
[zenith, zenithNdx] = max(data(indices), [], 2);
nadirNdx = indices(:, 1) + nadirNdx - 1;
zenithNdx = indices(:, 1) + zenithNdx - 1;

% The following two lines are needed for the eval statement: do not remove
height = zenith - nadir; %#ok<NASGU>
duration = ((nadirNdx - zenithNdx) ./ fs); %#ok<NASGU>

isiNadir = [diff(nadirNdx) ./ fs; (length(data) - nadirNdx(end)) ./ fs];
isiZenith = [diff(zenithNdx) ./ fs; (length(data) - zenithNdx(end)) ./ fs];

%Process addition criteria.
if(~isempty(params.Values{2}))
    bKeep = eval(params.Values{2});
    nadirNdx = nadirNdx(bKeep);
    zenithNdx = zenithNdx(bKeep);
    isiNadir = isiNadir(bKeep);
    isiZenith = isiZenith(bKeep);
end

bUnique = (isiNadir > 0) & (isiZenith > 0);
nadirNdx = nadirNdx(bUnique);
zenithNdx = zenithNdx(bUnique);

events{1} = zenithNdx;
events{2} = nadirNdx;
end