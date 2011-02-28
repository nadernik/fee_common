function add_drugs_to_annotation(birdname, expername, ...
    drugname, drugconc, datenum_in, datenum_out)
%ADD_DRUGS_TO_ANNOTATION Summary of this function goes here
%   Detailed explanation goes here
for part = 1:1000
    annofile = get_annotation_filename(birdname, expername, 'part', part);
    miscfile = get_annotation_filename(birdname, expername, 'part', part, 'type', 'misc');
    if ~exist(annofile, 'file')
        break
    end
    
    load(annofile)
    for ii = 1:length(elements)
        fileStartTime = extractTimeFromFilename(elements{ii}.exper, keys{ii});
        if fileStartTime > datenum_in && fileStartTime < datenum_out
           elements{ii}.drugname = drugname;
           elements{ii}.drugconc = drugconc;
        end
    end
    save(annofile, 'keys', 'elements')
    
    load(miscfile)
    for ii = 1:length(misc.segs)
        if      misc.segs(ii).absStart > datenum_in && ...
                misc.segs(ii).absStart < datenum_out
            misc.segs(ii).drugname = drugname;
            misc.segs(ii).drugconc = drugconc;
        end
    end
    save(miscfile, 'misc')
end
    
    
    