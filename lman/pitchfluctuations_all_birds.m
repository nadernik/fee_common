birdnames{1} = '1772';
expernames{1} = '2010-08-26';
targetsyllables{1} = 1;
timewindows{1} = [.115 .135];%[.115 .145];

birdnames{2} = 'mes011';
expernames{2} = '2011-03-03';
targetsyllables{2} = 2;
timewindows{2} = [.1 .12];

birdnames{3} = 'mes013';
expernames{3} = '2011-03-10';
targetsyllables{3} = 1;
timewindows{3} = [.03 .05];

birdnames{4} = 'blue298';
expernames{4} = '2010-12-12';
targetsyllables{4} = 1;
timewindows{4} = [.04 .06];%[.04 .09];

birdnames{5} = 'mes003';
expernames{5} = '2011-02-08';
targetsyllables{5} = 2;
timewindows{5} = [.085 .105];%[.085 .120];

birdnames{6} = 'black401';
expernames{6} = '2010-12-20';
targetsyllables{6} = 1;
timewindows{6} = [.08 .10]; %[.08 .160]; % pitch slopes downward

birdnames{7} = 'mes010';
expernames{7} = '2011-02-26';
targetsyllables{7} = 2;
timewindows{7} = [.095 .115];%[.095 .145];

birdnames{8} = 'mes020';
expernames{8} = '2011-04-09';
targetsyllables{8} = 2;
timewindows{8} = [.02 .04];%[.02 .05];

birdnames{9} = 'mes021';
expernames{9} = '2011-05-03';
targetsyllables{9} = 1;
timewindows{9} = [.02 .04];%[.02 .05];

for n = 1:length(birdnames)
    disp(birdnames{n})
    savefile = ['c:\stetner\data\pitchfluctuations\' birdnames{n} '_yesdc'];
    pitchfluctuations(birdnames{n}, expernames{n}, targetsyllables{n}, timewindows{n}, 'DC', true, 'Save', savefile)
    savefile = ['c:\stetner\data\pitchfluctuations\' birdnames{n} '_nodc'];
    pitchfluctuations(birdnames{n}, expernames{n}, targetsyllables{n}, timewindows{n}, 'DC', false, 'Save', savefile)
    %pause
    close all
end