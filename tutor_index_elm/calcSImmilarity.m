function [Tscores,Sequence, Imitation]=calcSImmilarity(birdname,FeatureFile,tutorname,filenameSave)

birdname
%output:
%Tscores = similarity score
%sequence score
Mypath=mfilename('fullpath');Mypath=Mypath(1:end-length('calcSImmilarity'));
load(fullfile(Mypath, 'featureParam.mat'))%load the new statistics mF madF distDs distDl

cd([birdname '/bouts']);
load(FeatureFile);
vecf=[2 3 5  7];%the selected features
inx=0;
for i=1:length(Feature)
    if size(Feature{i},1)>=500
        inx=inx+1;
        SonFeature{inx}=Feature{i};
        Son_syll{inx}=syll{i};
        L=size(Feature{i},1); if silent_times{i}(end,1)>L*3  silent_times{i}=silent_times{i}./44.100; Tsegs{i}=Tsegs{i}./44.100; end
        Son_silent_times{inx}=silent_times{i};
        Son_Tseg{inx}=Tsegs{i};
    end
end
load([tutorname '/bouts/features.mat']); TutorFeature=cell(1,length(Feature));Tutor_syll=cell(1,length(Feature));Tutor_silent_times=cell(1,length(Feature));Tutor_Tseg=cell(1,length(Feature));
inx=0; for i=1:length(Feature)
    if size(Feature{i},1)>=30
        inx=inx+1  ;
        TutorFeature{inx}=Feature{i};
        Tutor_syll{inx}=syll{i};
        L=size(Feature{i},1); if silent_times{i}(end,1)>L*3  silent_times{i}=silent_times{i}./44.100; Tsegs{i}=Tsegs{i}./44.100; end
        Tutor_silent_times{inx}=silent_times{i};
        Tutor_Tseg{inx}=Tsegs{i};
    end
end
clear Feature
index=0;Tutorindex=0;FTutormatrix=[];
%% ============================
% Compute similarity to the tutor
Nbouts=min(100,size(SonFeature,2));
Sonlistbouts=randsample(size(SonFeature,2),Nbouts);
%=========compute similarity matrices of bird with itself and to the tutor===========
indm=0;Tindm=0;innerNsylls=0;
Tscores=[];composite=[];

for c = 1:Nbouts
    syllS=Son_syll{Sonlistbouts(c)};%the sound file
    mat1=SonFeature{Sonlistbouts(c)};  mat1=mat1./repmat(madF,length(mat1),1) ;%normalization of features
    [vecT1,Son_segs]=combine_segs(Son_silent_times{Sonlistbouts(c)},Son_Tseg{Sonlistbouts(c)},size(mat1,1),35);
    Tutorlistbouts=randsample(length(TutorFeature),min(length(TutorFeature),3));
    for d=1:length(Tutorlistbouts)  %similarity to tutor
        syllT=Tutor_syll{Tutorlistbouts(d)};%tutor's motif
        mat2=TutorFeature{Tutorlistbouts(d)};
        mat2=mat2./repmat(madF,length(mat2),1);
        [vecT2,Tuter_segs]=combine_segs(Tutor_silent_times{Tutorlistbouts(d)},Tutor_Tseg{Tutorlistbouts(d)},size(mat2,1),1);
        [scoremat,scoreDs,scoreDl]=getScore(mat1,mat2,distDs, mdistDs,distDl,vecT1,vecT2,syllS,syllT,vecf);%score matrix
        vecT2=intersect(vecT2,26:(size(mat2,1)-25));        Nreal=size(scoremat,1)-length(vecT2);
        mat=scoremat(:,1:min(size(scoremat,2),2*size(scoremat,1)+100));
        matDs=scoreDs(:,1:min(size(scoreDs,2),2*size(scoreDs,1)+100));
        Tindm=Tindm+1;
        [Tscores(Tindm),Sequence(Tindm)]=computeFinScore(mat,Nreal);
    end
end
Imitation=Tscores.*Sequence;
cd(birdname );
if nargin<4
    save 'similarity_Motif.mat'  Tscores  Sequence Imitation
else eval(['save ' filenameSave  '  Tscores*  Sequence Imitation'])
end


    
%% --------------------------------------

function  [vecT2,Tsegs_new]=combine_segs(Tsilent,Tseg,L,Threshold)
%L=length of sound
vecT2=[];
for i=1:size(Tsilent,1)
    if  (Tsilent(i,2))-(Tsilent(i,1))>Threshold %if silent is larger than threshold
    vecT2=[vecT2  (max(1,floor(Tsilent(i,1)))):(round(Tsilent(i,2)))];
    end
end
if L-Tseg(end,2)>50 vecT2=unique([vecT2 (Tseg(end,2)):L]); end%unique - in case the end was allready in the vec
found=0;k=1;
while ~found
    Tsegs_new=Tseg(k,:);
    if Tsegs_new(2)-Tsegs_new(1)>2 found=1;
    else k=k+1;
    end
end

for i=(k+1):size(Tseg,1)
    if  (Tseg(i,1))-(Tseg(i-1,2))<Threshold 
        Tsegs_new(end,2)=Tseg(i,2);
    else Tsegs_new=[Tsegs_new; Tseg(i,:)];
    end
end
  'hold';      
        



        
