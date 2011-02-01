%overnight script for 2/13/2006
for(birdIdCell = {'aa115', 'aa116'});
    birdId = birdIdCell{1};
    try load([birdId,'-fileSumm.mat']); catch, fileSumm = []; end
    try load([birdId,'-sylls.mat']); catch sylls = []; end
    try load([birdId,'-bouts.mat']); catch bouts = []; end
    for(sapDateNum = [370:390])
        dateDir = num2str(sapDateNum);
        [newFileSumm,newSylls,newBouts] = getRawBoutAndSyllSummaryForPeriod(birdId, dateDir, 1, 23.5);
        bouts = aSAP_augmentBouts(bouts, newBouts);
        sylls = aSAP_augmentSylls(sylls, newSylls);
        fileSumm = aSAP_augmentFileSumm(fileSumm, newFileSumm);
        save([birdId,'-fileSumm.mat'], 'fileSumm');
        save([birdId,'-sylls.mat'], 'sylls');
        save([birdId,'-bouts.mat'], 'bouts');
    end
end

generateBoutSummForXBirds;

    
