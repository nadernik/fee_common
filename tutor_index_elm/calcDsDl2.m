function [Ds, Dl]=calcDsDl2(song1, song2,vecf, vecT1,vecT2,mDs_SoundSilent,mDs_SilentSilent,Gamma)
%input: normalized features for each song 
%Gamma - the weight of silent gaps
%short-scale differences
Ds=zeros(length(song2(:,1)),length(song1(:,1)));
GammaMat=ones(length(song2(:,1)),length(song1(:,1)));
for f=vecf
    mat1=repmat(song1(:,f)',length(song2(:,f)),1);
    mat2=repmat(song2(:,f),1,length(song1(:,f)));
    Ds=Ds+(mat2-mat1).^2;
end
Ds=sqrt(Ds./length(vecf));

isSound1=setdiff(1:size(Ds,2),vecT1);
isSound2=setdiff(1:size(Ds,1),vecT2);
sound_soundDs=Ds(isSound2,isSound1);

sound_silentDs=Ds(vecT2,isSound1);
silent_soundDs=Ds(isSound2,vecT1);
silent_silentDs=Ds(vecT2,vecT1);
vecsound_soundDs=reshape(sound_soundDs,1,size(sound_soundDs,1)*size(sound_soundDs,2));
vecsound_silentDs=reshape(sound_silentDs,1,size(sound_silentDs,1)*size(sound_silentDs,2));
vecsilent_soundDs=reshape(silent_soundDs,1,size(silent_soundDs,1)*size(silent_soundDs,2));
vecsilent_silentDs=reshape(silent_silentDs,1,size(silent_silentDs,1)*size(silent_silentDs,2));
% Ds(vecT2(10:end-10),vecT1(10:end-10))=mDs_SilentSilent;%mDs_low;%mean([vecsilent_silentDs]);
% Ds(isSound2(10:end-10),vecT1(10:end-10))=mDs_SoundSilent;%mDs_SoundSilent;%mean([vecsilent_soundDs vecsound_silentDs]);
% Ds(vecT2(10:end-10),isSound1(10:end-10))=mDs_SoundSilent;%mDs_high;%mean([vecsilent_silentDs vecsound_silentDs]);
%====return this==========
GammaMat(vecT2(10:end-10),vecT1(10:end-10))=Gamma;%mDs_low;%mean([vecsilent_silentDs]);
GammaMat(isSound2(10:end-10),vecT1(10:end-10))=Gamma;%mDs_SoundSilent;%mean([vecsilent_soundDs vecsound_silentDs]);
GammaMat(vecT2(10:end-10),isSound1(10:end-10))=Gamma;
%======================

%long-scale differences
Dss=Ds.^2.*GammaMat;
finmat=zeros(size(Dss,1)+39,size(Dss,2)+39);
finmatGamma=ones(size(Dss,1)+39,size(Dss,2)+39);
for i=1:40
    tmpmat=zeros(size(Dss,1)+39,size(Dss,2)+39);
    tmpmat(((1:size(Dss,1))+i-1),((1:size(Dss,2))+i-1))=Dss;
    finmat=finmat+tmpmat;
    tmpmatGamma=zeros(size(Dss,1)+39,size(Dss,2)+39);
    tmpmatGamma(((1:size(Dss,1))+i-1),((1:size(Dss,2))+i-1))=GammaMat;
    finmatGamma=finmatGamma+tmpmatGamma;
end
finmat=sqrt(finmat./finmatGamma);
Dl=finmat(20:end-20, 20:end-20);
clear Dss 