% birdnames{1} = '1772';
% expernames{1} = '2010-08-26';
% targetsyllables{1} = 1;
% timewindows{1} = [.105 .145];

birdnames{1} = 'black401';
expernames{1} = '2010-12-20';
targetsyllables{1} = 1;
timewindows{1} = [.080 .120];

% birdnames{2} = 'mes003';
% expernames{2} = '2011-02-08';
% targetsyllables{2} = 2;
% timewindows{2} = [.080 .120];

birdnames{2} = 'mes011';
expernames{2} = '2011-03-03';
targetsyllables{2} = 2;
timewindows{2} = [.090 .130];

birdnames{3} = 'blue298';
expernames{3} = '2010-12-12';
targetsyllables{3} = 1;
timewindows{3} = [.04 .08];

% birdnames{3} = 'mes010';
% expernames{3} = '2011-02-26';
% targetsyllables{3} = 2;
% timewindows{3} = [.100 .140];

for n = 1:length(birdnames)
    disp(birdnames{n})
    savefile = ['c:\stetner\data\pitchfluctuations\40ms_stacks_for_figure\' birdnames{n} '_yesdc'];
    pitchfluctuations(birdnames{n}, expernames{n}, targetsyllables{n}, timewindows{n}, 'DC', true, 'Save', savefile)
    %savefile = ['c:\stetner\data\pitchfluctuations\40ms_stacks_for_figure\' birdnames{n} '_nodc'];
    %pitchfluctuations(birdnames{n}, expernames{n}, targetsyllables{n}, timewindows{n}, 'DC', false, 'Save', savefile)
    %pause
    close all
end