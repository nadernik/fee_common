function viewExper(exper)
h = figure(2920);
ud.exper = exper;
ud.filenum = 1;
ud.currChan = 1;
ud.sp(1) = subplot(2, 1, 1);
ud.sp(2) = subplot(2, 1, 2);
set(h,'UserData', ud);
set(h,'KeyPressFcn',@cb_viewExperKeyPress);

viewExper_updateAudio(h)

function viewExper_updateAudio(h)
ud = get(h,'UserData');
try,
    subplot(2, 1, 1);
    [ud.audio, timeCreated] = loadAudio(ud.exper,ud.filenum);
    ud.data = loadData(ud.exper, ud.filenum, ud.currChan);
    ud.time = [0:length(ud.audio)-1] / ud.exper.desiredInSampRate;
    %wavplay(ud.audio,ud.exper.desiredInSampRate, 'async');
    axes(ud.sp(1));
    displaySpecgramQuick(ud.audio, ud.exper.desiredInSampRate, [0,8000]);    
    set(ud.sp(1),'Units', 'normalized');
    axis tight;
    title([ud.exper.birdname, ' ', ud.exper.expername, ' file:', num2str(ud.filenum), ' time: ',timeCreated]);
    axes(ud.sp(2));
    plot(ud.time, ud.data);    
    set(ud.sp(1),'Units', 'normalized');
    axis tight;
    title([ud.exper.birdname, ' ', ud.exper.expername, ' file:', num2str(ud.filenum), ' time: ',timeCreated]);
    linkaxes(ud.sp,'x')
catch,
    ud.audio = [];
    cla(ud.sp(1));
    cla(ud.sp(2));
end
set(h,'UserData', ud);

function cb_viewExperKeyPress(h, evnt)
ud = get(h,'UserData')

press = evnt.Character;
if(press == '.')
    ud.filenum = ud.filenum + 1;
    set(h,'UserData', ud);
    viewExper_updateAudio(h)
elseif(press == ',')
    ud.filenum = ud.filenum -1;
    set(h,'UserData', ud);
    viewExper_updateAudio(h)    
elseif(press == 'j')
    b = inputdlg('Enter a file number:');
    ud.filenum = str2num(b{1});
    set(h,'UserData', ud);
    viewExper_updateAudio(h)        
elseif(press == 'p')
    wavplay(ud.audio,ud.exper.desiredInSampRate, 'async');
elseif(press == '1' | press == '2' | press == '3')
    ud.currChan = str2num(press);
    set(h,'UserData', ud);
    viewExper_updateAudio(h)    
end


