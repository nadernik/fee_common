function learningwithdrugs(birdname, expernames, clusters, varargin)
P.N = 100;
P.MinPitchGoodness = 0;
P.Range = [0 100];
P.RangeUnits = {'percent' 'seconds' 'samples'};
P = parseargs(P, varargin{:});

conc = nan(size(expernames));
zlearned = nan(size(expernames));

for ii = 1:length(expernames)
    
    % >0 is concentration of drug in mM
    % 0 means pbs injected around same time as drugs would be
    % -1 means not handled, has water (or maybe pbs) in probe
    if ~isfield(elements{1}, 'Drug')
        conc(ii) = -1;
    elseif strcmp(elements{1}.Drug.Name, 'PBS')
        conc(ii) = 0;
    elseif strcmp(elements{1}.Drug.Name, 'CNQX + APV')
        conc(ii) = elements{1}.Drug.Concentration * 1e3; % convert M to mM
    else
        warning('Unknown drug name for exper %s bird %s', birdname, expername)
        conc(ii) = NaN;
    end
    
    % calculate pitch and pitchGoodness over target range
    mask = false(size(vcdb.d.v));
    for jj = 1:length(clusters)
        mask = mask | vcdb.d.cn == clusters(jj);
    end
    mask = mask & getsf(vcdb, 'pgtarg') >= P.MinPitchGoodness;
    maskfirst = mask & (cumsum(mask) < P.N); 
    masklast = mask & ((sum(mask) - cumsum(mask)) < P.N);
    
    meanpitch1 = mean(getsf(vcdb, 'pitchtarg', maskfirst));
    stdpitch1 = std(getsf(vcdb, 'pitchtarg', maskfirst));
    meanpitch2 = mean(getsf(vcdb, 'pitchtarg', masklast));
    stdpitch2 = std(getsf(vcdb, 'pitchtarg', masklast));
    zlearned(ii) = (meanpitch2 - meanpitch1) / stdpitch1;
    
end