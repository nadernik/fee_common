function dbase_file_2_song_csv(analysis_filename, csv_filename, varargin)
    S = load(analysis_filename, 'dbase');
    T = dbase_song_csv(S.dbase, varargin{:});
    writetable(T, csv_filename);
end
