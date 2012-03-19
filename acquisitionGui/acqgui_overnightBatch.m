function acqgui_overnightBatch(expers)
% expers is a cell array of exper structures

for ii = 1:length(expers)
    birdname = expers{ii}.birdname;
    expername = expers{ii}.expername;
    switch birdname
        case 'mes035'
            annotate_exper(birdname, expername,'edgeSyllThreshold', -10, 'triggerSyllThreshold', -6)
            vcQuickCluster(birdname, expername, 'c:\stetner\data\mes035\polygons 2011-09-30.mat', []);
            fprintf(1, 'Annotated and clusterd exper %s for bird %s\n', expername, birdname)
        case '1856'
            annotate_exper(birdname, expername, 'triggerSyllThreshold', -4, 'edgeSyllThreshold', -9)
            vcQuickCluster(birdname, expername, 'c:\stetner\data\1856\polygons 2011-10-10.mat', []);
            fprintf(1, 'Annotated and clusterd exper %s for bird %s\n', expername, birdname)
        case '1555'
            annotate_exper(birdname, expername, 'edgeSyllThreshold', -11, 'triggerSyllThreshold', -8)
            vcQuickCluster(birdname, expername, 'c:\stetner\data\1555\polygons 2011-10-14.mat', []);
            fprintf(1, 'Annotated and clusterd exper %s for bird %s\n', expername, birdname)
        case '2558'
            annotate_exper(birdname, expername, 'edgeSyllThreshold', -11, 'triggerSyllThreshold', -8)
            fprintf(1, 'Annotated and clusterd exper %s for bird %s\n', expername, birdname)
        otherwise
            fprintf(1, 'Skipping exper %s for bird %s\n', expername, birdname)
    end
end