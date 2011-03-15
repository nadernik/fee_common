function vcdb = vc_feat_rms(vcdb, feat, varargin)
P.range = [0 100];
P.rangeunits = {'percent', 'seconds', 'samples'};
P.name = ['rms_' feat];
P = parseargs(P, varargin{:});

% If user did not specify a name but did specify a range, add the range to
% the name of the feature.
if ~any(strcmp(varargin, 'name')) && any(strcmp(varargin, 'range'))
    P.name = sprintf('%s_%g_%g', P.name, P.range(1), P.range(2));
end

n = size(vcdb.d.sf, 2) + 1;
vf = getVFbyName(vcdb, feat);

% If we are using time to extract snippets, we need a time vector. Try to
% use a vector feature called 'pitchTime'. If that doesn't work, try to
% make time vector based on duration. If that doesn't work, give an error.
if strcmp(P.rangeunits, 'seconds')
    t = getVFbyName(vcdb, 'pitchTime');
    if isempty(t) || length(t{1}) ~= length(vf{1})
        dur = getSFbyName(vcdb, 'duration');
        
        if isempty(dur)
            error('Cannot make time vector.')
        end
        
    end
else
    t = repmat({[]}, size(vf));
end

% Calculate the feature, the root-mean-square value over a range
for syll = 1:length(vcdb.d.v)
    vcdb.d.sf(syll, n) = mean(abs(snippet(vf{syll}, P.range, ...
        't', t{syll}, ...
        'units', P.rangeunits)));
end

vcdb.f.sfname{n} = P.name;
vcdb.f.sffcn{n} = mfilename;
vcdb.f.sfparam{n} = {feat, varargin{:}};