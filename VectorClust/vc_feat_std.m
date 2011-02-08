function vcdb = vc_feat_std(vcdb, vf_name, varargin)
P.sfname = '';
P.time_range = [];
P.percent_range = [];
P.samples_range = [];
P = parseargs(P, varargin{:});

if isempty(P.sfname)
    sfname = ['std_' vf_name]; % may add to this later base on range
    use_default_sfname = true;
else
    sfname = P.sfname;
    use_default_sfname = false;
end

sf_idx = length(vcdb.f.sfname) + 1;
vf_idx = find(strcmp(vf_name, vcdb.f.vfname));


if ~isempty(P.time_range)
    % if we are given a specific range to take the mean over, calculate
    % which sample numbers correspond to this time range.
    samples = round((P.time_range + 1/vcdb.g.fs) .* vcdb.g.fs);
    for syll = 1:length(vcdb.d.v) 
        % for each syllable, calculate mean over the time range
        try
            vcdb.d.sf(syll, sf_idx) = std(vcdb.d.vf{vf_idx}{syll}(samples(1):samples(2)));
        catch
            vcdb.d.sf(syll, sf_idx) = [];
        end
    end
    if use_default_sfname
        % if user did not supply a name for this feature, add the time
        % range to our default name so it becomes like "mean_pitch_10_20".
        sfname = sprintf('%s_%g_%g', sfname, P.time_range(1), P.time_range(2));
    end
elseif ~isempty(P.percent_range)
    for syll = 1:length(vcdb.d.v)
        L = length(vcdb.d.vf{vf_idx}{syll});
        ndxStart = ceil((L - 1) * P.percent_range(1) / 100) + 1;
        ndxEnd = floor((L - 1) * P.percent_range(2) / 100) + 1;
        vcdb.d.sf(syll, sf_idx) = std(vcdb.d.vf{vf_idx}{syll}(ndxStart:ndxEnd));
    end
    if use_default_sfname
        % if user did not supply a name for this feature, add the time
        % range to our default name so it becomes like "mean_pitch_10_20".
        sfname = sprintf('%s_%g_%g', sfname, P.percent_range(1), P.percent_range(2));
    end
elseif ~isempty(P.samples_range)
    for syll = 1:length(vcdb.d.v) % for each syllable
        vcdb.d.sf(syll, sf_idx) = std(vcdb.d.vf{vf_idx}{syll}(P.samples_range(1):P.samples_range(2)));
    end
    if use_default_sfname
        sfname = sprintf('%s_%g_%g', sfname, P.samples_range(1), P.samples_range(2));
    end
else
    % if we weren't given any ranges, just take the mean of the whole
    % vector
    vcdb.d.sf(:,sf_idx) = cellfun(@std, vcdb.d.vf{vf_idx});
end

vcdb.f.sfname{sf_idx} = sfname;
vcdb.f.sffcn{sf_idx} = mfilename;
vcdb.f.sfparam{sf_idx} = {vf_name, varargin{:}};
