function T = dbase_song_csv(dbase, varargin)

    p = inputParser;
    p.addParameter('range', []);
    p.parse(varargin{:});
    range = p.Results.range;

    if isempty(range)
        sel_mask = dbase.Times ~= 0 & cellfun(@(x) ~isempty(x), dbase.SegmentTimes);
    else
        sel_mask = false(numel(dbase.Times), 1);
        sel_mask(range) = dbase.Times(range) ~= 0 & ...
                          cellfun(@(x) ~isempty(x), dbase.SegmentTimes(range));
    end
    idx_selected = find(sel_mask);
    nseg = cellfun(@sum, dbase.SegmentIsSelected(sel_mask));

    n_row = sum(nseg);

    T = table(...
                'Size', [n_row, 9], ...
                'variableTypes', {'string', 'string', 'string', 'string', ...
                                  'string', 'single', 'single', 'uint32', ...
                                  'uint32'}, ...
                'variableNames', {'path', 'file_name', 'file_time', 'loader', ...
                                  'segment_label', 'segment_threshold', ...
                                  'sampling_rate', 'sample_start', 'sample_stop'} ...
             );

    T.path = cellstr(repmat(dbase.PathName, [n_row, 1]));
    T.loader = cellstr(repmat(dbase.SoundLoader, [n_row, 1]));
    T.sampling_rate = repmat(dbase.Fs, [n_row, 1]);

    tbl_offset = 1;
    for rel_fileno = 1:numel(idx_selected)
        fileno = idx_selected(rel_fileno);
        tbl_e = tbl_offset + nseg(rel_fileno) - 1;
        selected_mask = logical(dbase.SegmentIsSelected{fileno});
        T.file_name(tbl_offset:tbl_e) = ...
        cellstr(repmat(dbase.SoundFiles(fileno).name, [nseg(rel_fileno), 1]));
        T.file_time(tbl_offset:tbl_e) = ...
        cellstr(repmat(datestr(dbase.Times(fileno)), [nseg(rel_fileno), 1]));
        raw_titles = dbase.SegmentTitles{fileno}(selected_mask).';
        munged_titles = cell(nseg(rel_fileno), 1);
        for tno = 1:nseg(rel_fileno)
            if isempty(raw_titles{tno})
                munged_titles{tno} = '';
            else
                munged_titles{tno} = raw_titles{tno}(1);
            end
        end
        T.segment_label(tbl_offset:tbl_e) = munged_titles;
        T.segment_threshold(tbl_offset:tbl_e) = dbase.SegmentThresholds(fileno);
        T.sample_start(tbl_offset:tbl_e) = dbase.SegmentTimes{fileno}(selected_mask, 1);
        T.sample_stop(tbl_offset:tbl_e) = dbase.SegmentTimes{fileno}(selected_mask, 2);
        tbl_offset = tbl_offset + nseg(rel_fileno);
    end

end