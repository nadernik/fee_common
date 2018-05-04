function vcdb = vc_feat_std(vcdb, feat, varargin)
P.Name = ['std_' feat];
P.Range = [0 100];
P.RangeUnits = {'percent', 'seconds', 'samples'};
% for backwards compatability
P.percent_range = [];
P.time_range = [];
P.samples_range = [];
% end backwards compatability code
P = parseargs(P, varargin{:});

rangeGiven = any(strcmp(varargin, 'Range'));

% for backwards compatability
if ~isempty(P.percent_range)
    P.Range = P.percent_range;
    P.RangeUnits = 'percent';
    rangeGiven = true;
elseif ~isempty(P.time_range)
    P.Range = P.time_range;
    P.RangeUnits = 'seconds';
    rangeGiven = true;
elseif ~isempty(P.samples_range)
    P.Range = P.samples_range;
    P.RangeUnits = 'samples';
    rangeGiven = true;
end
% end backwards compatability code

if ~any(strcmp(varargin, 'Name')) && rangeGiven
    P.Name = sprintf('%s_%g_%g', P.Name, P.Range(1), P.Range(2));
end

n = size(vcdb.d.sf, 2) + 1;
vf = getvf(vcdb, feat);

% If we are using time to extract snippets, we need a time vector. Try to
% use a vector feature called 'pitchTime'. If that doesn't work, try to
% make time vector based on duration. If that doesn't work, give an error.
if strcmp(P.RangeUnits, 'seconds')
    t = getvf(vcdb, 'pitchTime');
    if isempty(t) || length(t{1}) ~= length(vf{1})
        dur = getsf(vcdb, 'duration');
        len = cellfun(@length, vf);
        if isempty(dur)
            error('Cannot make time vector.')
        end
        t = arrayfun(@linspace, zeros(size(dur)), dur, len, 'UniformOutput', false);
    end
else
    t = repmat({[]}, size(vf));
end

% Calculate the feature, the root-mean-square value over a range
for syll = 1:length(vcdb.d.v)
    try
        x = snippet(vf{syll}, P.Range, ...
            't', t{syll}, ...
            'units', P.RangeUnits);
        if isempty(x)
            vcdb.d.sf(syll, n) = nan;
        else
            vcdb.d.sf(syll, n) = std(x);
        end
    catch
        warning('MATLAB:vectorClust:vc_feat_std', 'Could not calculate feature %s for syllable number %g because %s', P.Name, syll, lasterr)
        vcdb.d.sf(syll,n) = nan;
    end
end

vcdb.f.sfname{n} = P.Name;
vcdb.f.sffcn{n} = mfilename;
vcdb.f.sfparam{n} = {feat, varargin{:}};
