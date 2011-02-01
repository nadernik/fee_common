function [simM, accuM, seqM, soundfile1, soundfile2, similarity, accuracy, seqsim] = aSAP_loadExcelSimilarities

s = uiimport;


soundfile1 = s.textdata(5:end,2);
soundfile2 = s.textdata(5:end,3);

%start1 = data(5:end,1);
%start2 = data(5:end,2);
similarity = s.data(1:end,3);
accuracy = s.data(1:end,4);
seqsim = s.data(1:end,5);

[maxcluster1, maxsyllnum1] = extractClusterAndSyllnum(soundfile1{end});
[maxcluster2, maxsyllnum2] = extractClusterAndSyllnum(soundfile2{end});
simM = zeros(maxcluster1*maxsyllnum1,maxcluster2*maxsyllnum2);
accuM = zeros(maxcluster1*maxsyllnum1,maxcluster2*maxsyllnum2);
seqM = zeros(maxcluster1*maxsyllnum1,maxcluster2*maxsyllnum2);
for(nSim = 1:length(soundfile1))
    [clust1, num1] = extractClusterAndSyllnum(soundfile1{nSim});
    [clust2, num2] = extractClusterAndSyllnum(soundfile2{nSim}); 
    simM((clust1-1)*maxsyllnum1+num1,(clust2-1)*maxsyllnum2+num2) = similarity(nSim);
    accuM((clust1-1)*maxsyllnum1+num1,(clust2-1)*maxsyllnum2+num2)= accuracy(nSim);
    seqM((clust1-1)*maxsyllnum1+num1,(clust2-1)*maxsyllnum2+num2)= seqsim(nSim);
end

function [clust, num] = extractClusterAndSyllnum(filename)
undx = strfind(filename,'-');
clust = str2num(filename(1:undx(1)-1));
num = str2num(filename(undx(1)+1:undx(2)-1)) - 1000;

