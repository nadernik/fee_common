% count the number of bouts

for nbird = 1:length(dbase_file_names)
    dbase_file_names{nbird}
    load(dbase_file_names{nbird}, 'dbase')
    dbase = Select_syllable_within_bout(dbase,0.5, 2, file_nums{nbird});
    
    % find all files that contain a bout
    total_bouts = cellfun(@(x) size(x,1), dbase.BoutTimes, 'UniformOutput', true)
end
    
