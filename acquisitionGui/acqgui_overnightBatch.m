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
        case 'mes025'
            annotate_exper('mes025', expername, 'triggerSyllThreshold', -5, 'edgeSyllThreshold', -10)
            fprintf(1, 'Annotated exper %s for bird %s\n', expername, birdname)            
        case 'empty'

            fprintf(1, 'Annotated exper %s for bird %s\n', expername, birdname)
        case 'mes021'
            annotate_exper('mes021', expername, 'edgeSyllThreshold', -9.5, 'triggerSyllThreshold', -7)
            fprintf(1, 'Annotated exper %s for bird %s\n', expername, birdname)
        otherwise
            fprintf(1, 'Skipping exper %s for bird %s\n', expername, birdname)
    end
end