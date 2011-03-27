function acqgui_overnightBatch(expers)
% expers is a cell array of exper structures

for ii = 1:length(expers)
    birdname = expers{ii}.birdname;
    expername = expers{ii}.expername;
    switch birdname
        case '2098'
            annotate_exper('2098', expername, ...
                'edgeSyllThreshold', -8, ...
                'triggerSyllThreshold', -6, ...
                'fMinIntervalDuration',0.03)
            fprintf(1, 'Annotated exper %s for bird %s\n', expername, birdname)
        case 'mes020'
            annotate_exper('mes020', expername, 'edgeSyllThreshold', -10,'triggerSyllThreshold', -8)
            fprintf(1, 'Annotated exper %s for bird %s\n', expername, birdname)
        case 'mes011'
            annotate_exper('mes011', expername, 'edgeSyllThreshold', -9, 'triggerSyllThreshold', -7, 'fMinIntervalDuration', 0.02)
            fprintf(1, 'Annotated exper %s for bird %s\n', expername, birdname)            
        case 'mes013'
            annotate_exper('mes013', expername, ...
                'edgeSyllThreshold', -9.5, ...
                'triggerSyllThreshold', -8)
            fprintf(1, 'Annotated exper %s for bird %s\n', expername, birdname)
        case '2145'
            annotate_exper('2145', expername, 'edgeSyllThreshold',-10,'triggerSyllThreshold',-8)
            fprintf(1, 'Annotated exper %s for bird %s\n', expername, birdname)
        otherwise
            fprintf(1, 'Skipping exper %s for bird %s\n', expername, birdname)
    end
end