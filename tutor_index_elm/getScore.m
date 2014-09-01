function [cutscore, cutscoreDs, cutscoreDl]=getScore(song1,song2,distDs,mdistDs, distDl, vecT1,vecT2,syll1,syll2,vecf)
%input: normalized songs, distributions of Ds Dl, silent episodes of songs,


vecT2=round(vecT2);
vecT1=round(vecT1);

[Ds,Dl]=calcDsDl2(song1, song2,vecf,vecT1,vecT2,mdistDs(2),mdistDs(3),1);%small and long distances

vecDl=reshape(Dl,1,size(Dl,1)*size(Dl,2));
vecDs=reshape(Ds,1,size(Ds,1)*size(Ds,2));

vecPDs=interp1(distDs{1}(:,1),distDs{1}(:,2),vecDs,'linear');
vecPDl=interp1(distDl{1}(:,1),distDl{1}(:,2),vecDl,'linear');

vecscore=zeros(size(vecPDl));
vecscoreDs=zeros(size(vecPDl));
vecscoreDl=zeros(size(vecPDl));

[a]=find(vecPDl<=0.05); vecscore(a)=1-vecPDs(a);
[a]=find(vecPDl<=0.05); vecscoreDl(a)=1-vecPDl(a);
[a]=find(vecPDs<=0.05); vecscoreDs(a)=1-vecPDs(a);

vecscoreDs=1-vecPDs;
vecscoreDl=1-vecPDl;

scoreDl=reshape(vecscoreDl,size(Dl,1),size(Dl,2));
scoreDs=reshape(vecscoreDs,size(Ds,1),size(Ds,2));
score=reshape(vecscore,size(Ds,1),size(Ds,2));
score=smoothts(score,'b',5);
scoreDs=smoothts(scoreDs,'b',5);
scoreDl=smoothts(scoreDl,'b',5);

score(vecT2,:)=-0.1;
scoreDs(vecT2,:)=-0.1;
scoreDl(vecT2,:)=-0.1;

cutscore=score(21:end-20,21:end-20);
cutscoreDs=scoreDs(21:end-20,21:end-20);
cutscoreDl=scoreDl(21:end-20,21:end-20);

clear score* vec* Ds Dl



