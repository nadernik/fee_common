function acqgui_overnightBatch(expers)
% expers is a cell array of exper structures

for ii = 1:length(expers)
    birdname = expers{ii}.birdname;
    expername = expers{ii}.expername;
    annotate_exper(birdname, expername,'edgeSyllThreshold', -9, 'triggerSyllThreshold', -7)
end