function N = singingwithdrugs3(birdname, expernames)
hours = 0:1:7;
N = zeros(length(hours),5); % conc can be 0 1 2 3 4
days = zeros(1,5);
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
        continue
    elseif strcmp(elements{1}.Drug.Name, 'PBS')
        c = 1;
    elseif strcmp(elements{1}.Drug.Name, 'CNQX + APV')
        c = ceil(elements{1}.Drug.Concentration*1e3);
    else
        warning('Unknown drug name for exper %s bird %s', birdname, expername)
        continue
    end
    edges = hours/24 + elements{1}.Drug.TimeIn;
    days(c) = days(c) + 1;
    N(:,c) = (days(c)-1)./days(c).*N(:,c) + 1./days(c).*histc(t,edges)';
end