filename = fullfile('\\feebox6\shared\emackev\AcqGui\ISOLATES\3646\OnePerDay', '47dph_3646_d000493_20130414T125948chan4.dat');

[sndOrig fsOrig dt label props] = ...
        eval(['egl_' 'AA_daq'...
        '([''' filename '''],1)']);
    
figure; [S,Time,F] = spectrogramELM(sndOrig,fsOrig, .002,1);
    
imagesc(log(S))