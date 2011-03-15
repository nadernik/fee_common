function annodrugs(birdname, expername, Drug)

if ~isfield(Drug, 'Name')
    warning('Drug struct is missing field Name')
end
if ~isfield(Drug, 'Concentration')
    warning('Drug struct is missing field Concentration')
end
if ~isfield(Drug, 'TimeIn')
    warning('Drug struct is missing field TimeIn')
end
if ~isfield(Drug, 'TimeOut')
    warning('Drug struct is missing field TimeOut')
end

for part = 1:1000
    annofile = annofilename(birdname, expername, 'part', part);
    miscfile = annofilename(birdname, expername, 'part', part, 'type', 'misc');
    if ~exist(annofile, 'file')
        break
    end
    
    load(annofile)
    for ii = 1:length(elements)
        elements{ii}.Drug = Drug;
    end
    save(annofile, 'keys', 'elements')
    
    load(miscfile)
    for ii = 1:length(misc.segs)
        if      misc.segs(ii).absStart > Drug.TimeIn && ...
                misc.segs(ii).absStart < Drug.TimeOut
            misc.segs(ii).hasDrug = true;
        else
            misc.segs(ii).hasDrug = false;
        end
        misc.segs(ii).Drug = Drug;
    end
    save(miscfile, 'misc')
    debugdisp(['part ' int2str(part) ' done'])
end    