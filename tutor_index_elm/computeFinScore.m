function [fin_score,  fin_sequence_score]=computeFinScore(score,Mreal);

%function does NOT look for sections of similarity, but for the highest match (diagonal) per tutor's syllable
% input:
%score: the score matrix after thresholding
%scorefull has the scoreDs for all the matrix without threshold
%Mreal: size of tutor's song after removal of silent gaps

[M,N]=size(score);
scorefull=score;
complete=0;kk=0;finGroups.inx=[]; finGroups.p=[]; firstRun=1;finGroups.nextScore=[];

vec=score(:,1);
inx=find(vec>=0); vec(inx)=1;
inx=find(vec<0); vec(inx)=0;
vec=diff([0;  vec ;  0]);
vecT2(:,1)=find(vec==1);
vecT2(:,2)=find(vec==-1)-1;
vecT2=vecT2(find(vecT2(:,2)-vecT2(:,1)>5),:);
Sylls=1:(size(vecT2,1));
Nsylls=0;NAll=length(Sylls);
TotLength=[];
while ~isempty(Sylls)
    partialScore_syll=-1*ones(1,length(Sylls));
    for s=Sylls
        tmpMat=zeros(M,N);
        tmpMat(ceil(vecT2(s,1)+1):floor(vecT2(s,2)),:)=score(ceil(vecT2(s,1)+1):floor(vecT2(s,2)),:);%syllabl s, the rest is zero
        if s<size(vecT2,1) nextBorder=[ceil(vecT2(s+1,1)+1) vecT2(s+1,2)]; else nextBorder=[]; end
        if s==1 preBorder=[]; else preBorder=[ceil(vecT2(s-1,1)+1) vecT2(s-1,2)]; end
        [partialScore_syll(s)  d1 d2 Next_box  Pre_box fin_bordersSon ]=getBestDiag([ceil(vecT2(s,1)+1) vecT2(s,2); 1 size(tmpMat,2)],nextBorder,preBorder, tmpMat); %score along all the diagonal
        diagonal{s}=[d1' d2'];
        if length(d1)==1 
            NextBox{s}=[Next_box(1,:);1 size(tmpMat,2)];
        else         NextBox{s}=Next_box; end
        PreBox{s}=Pre_box;
        if Next_box(1,1)>=0  Seq(s,1)=GetNextDiagonal(NextBox{s},scorefull); else Seq(s,1)=-1; end
        if Pre_box(1,1)>=0   Seq(s,2)=GetNextDiagonal(PreBox{s},scorefull); else  Seq(s,2)=-1; end
        borders{s}=[vecT2(s,1)  vecT2(s,2) fin_bordersSon(1) fin_bordersSon(2)];
    end
    Nsylls=Nsylls+1;
    [tmp_score(Nsylls), inx]=max(partialScore_syll);
    tmp_score(Nsylls)=tmp_score(Nsylls)./Mreal;
    %sequence_score(Nsylls)=max(Seq(inx,:));
    sequence_score(Nsylls)=Seq(inx,1);
    if tmp_score(Nsylls)==0 break; end
    Sylls=setdiff(Sylls,inx);
    score(vecT2(inx,1):vecT2(inx,2),:)=-0.1;
    score(:,borders{inx}(3):borders{inx}(4))=-0.1;
    clear Seq partialScore_syll
end
fin_score=sum(tmp_score);
inx=find(sequence_score>=0);
if isempty(inx)
    fin_sequence_score=0.01;
else
    fin_sequence_score=mean(sequence_score(inx));
end






function score=GetNextDiagonal(borders,scorefull)
matrix=scorefull(borders(1,1):borders(1,2),borders(2,1):borders(2,2));
[M,N]=size(matrix);
k=0;
for i=(-M+1):(N-1)      k=k+1;    d(k,:)=[sum(diag(matrix,i)) i];end
[partialScore_seg,index]=max(d(:,1));
score=partialScore_seg./(borders(1,2)-borders(1,1));
