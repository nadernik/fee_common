%test match score

%% load cell
cell = loadCell(33, 'c:\Matlab\Aaron\Code\Electrophysiology\Cells\');

%% compute a few scores:
param = Parameters;
ndxOffset = 105;
numMotif = 3;
scoreM = [];
for(nMotif1 = 1+ndxOffset:numMotif+ndxOffset)
    motif1 = cell.motifData{nMotif1};
    audio1 = motif1.audio;
    nMotif1
    for(nSyll1 = 0:2)
        syll1aud = audio1(motif1.warpMarks(nSyll1*2 + 1):motif1.warpMarks(nSyll1*2 + 2));
        syll1feats = aSAP_generateASAPFeatures(syll1aud, 44100, param);
        for(nMotif2 = 1+ndxOffset:numMotif+ndxOffset)
            motif2 = cell.motifData{nMotif2};
            audio2 = motif2.audio;
            nMotif2
            for(nSyll2 = 0:2)
                syll2aud = audio2(motif2.warpMarks(nSyll2*2 + 1):motif2.warpMarks(nSyll2*2 + 2));
                syll2feats = aSAP_generateASAPFeatures(syll2aud, 44100, param);
                scoreM(numMotif*nSyll1+(nMotif1-ndxOffset),numMotif*nSyll2+(nMotif2-ndxOffset)) = aSAP_computeMatchScore2(syll1feats, syll2feats, .008, false, syll1aud, syll2aud, false);
                
            end
        end
    end
end

%%displayScores
figure; imagesc(scoreM); colorbar;
    