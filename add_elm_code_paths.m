% This script 

verbosity = 1;
% 0 = silent
% 1 = announce beginning and end of script
% 2 = announce each subdir
% 3 = announce each subdir, recursively!

if verbosity > 0
    fprintf('Adding elm''s code to paths...')
end
if verbosity > 1
    fprintf('\n')
end

ffn = mfilename('fullpath');
[code_dir, junk1, junk2] = fileparts(ffn);
    
subdirs = {'acquisitionGui', 'annotation', 'caf', 'CAFGUI', 'daq', ...
    'electro_gui', 'subsong', 'toolbox', 'VectorClust',...
    'misc_elm', 'phase_vocoder_elm', 'play_songs_elm', 'song_analysis_elm',...
    'test_code_elm', 'tutor_index_elm'};

for ii = 1:length(subdirs)
    paths_to_add = genpath(fullfile(code_dir, subdirs{ii}));
    switch verbosity
        case 1
            fprintf('.')
        case 2
            fprintf('Adding %s\n', subdirs{ii})
        case 3
            fprintf('Adding %s\n', paths_to_add)
    end
    addpath(paths_to_add)
end

if verbosity > 0
    fprintf(' Done! \n')
end

clear all