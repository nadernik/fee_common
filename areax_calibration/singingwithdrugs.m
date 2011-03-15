function [conc, N] = singingwithdrugs(birdname, expernames, minhour, maxhour)
conc = nan(size(expernames));
N = nan(size(expernames));
for ii = 1:length(expernames)
    expername = expernames{ii};
    t = [];
    for part = 1:1000
        filename = annofilename(birdname, expername, 'part', part);
        if exist(filename, 'file')
            load(filename)
        else
            break
        end
        exper = elements{1}.exper;
        temp = cellfun(@extractTimeFromFilename, repmat({exper}, size(keys)), keys);
        t = [t, temp];
    end

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
    
    % count files in time range
    % convert to hour of day
    t = arrayfun(@hour, t);
    N(ii) = sum(t >= minhour & t <= maxhour);
end