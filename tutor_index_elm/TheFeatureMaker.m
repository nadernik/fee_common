function [L,found,Ntutor]=TheFeatureMaker(birdname,Tmax,sil_gap, filenameSave)
%input: 
% name of bird (directory path name where data is located)
% Tmax length(in sec) of a song section (100ms more than double the size of the tutor's motif)
% sil_gap length (in sec) of allowed silent gap
% filenamesvae - name of file that stores the song sections in the feature space

% output:
% L - length of sound section

% function cuts songs to section and produce a feature matrix for each song section.
%save it in 'birdName' directory

birdname
L=0;
if (strcmp(birdname(end-4:end),'motif') || strcmp(birdname(end-5:end-1),'motif')) %feature extraction for the tutor motifs
    timeLimit=0; else timeLimit=1; end
cd([birdname '/bouts']);
dl=dir('features.mat');%if features were allready computed extract the length of the longest bout and return
if ~isempty(dl) && nargin<4
    load(dl(1).name);
    L=0; for k=1:length(Feature)
        if length(Feature{k})>L L=length(Feature{k}); end
    end
    L=L/1000;found=1;
    return
end

if exist ('analysis_selected.mat')
    load('analysis_selected.mat'); %loads the dbase structure
else filename=dir('analysis*'); load(filename.name); end
Bouts=dbase.SoundFiles;
clear Feature
inx=0;
Nbouts=min(5, length(Bouts));%how many bouts to analyze
for b=[1:Nbouts]
    N=0;
    Tseg=dbase.SegmentTimes{b};%
    selected=dbase.SegmentIsSelected{b};
    [Nsyll,stam]=size(Tseg);
    clear a y features labels
    if ~exist(dbase.SoundFiles(b).name,'file') 
        error(['file ' dbase.SoundFiles(b).name ' not found'] ); end
    load(dbase.SoundFiles(b).name);
    j=0;
    bb = fir1(200,[500 8600]/(rec.Fs/2));  rectmp=filtfilt(bb, 1, rec.Data);
    while j<Nsyll
        found=0; Tend=-1; Tstart=-1;ended=0;
        while j<Nsyll
            j=j+1;
            if selected(j)
                if ~found    found=1; Tstart=max(1,round(Tseg(j,1)-rec.Fs*0.025));
                    jStart=j; end
                Tend=min(length(rec.Data),round(Tseg(j,2)+rec.Fs*0.025));
                jend=j;
                if (timeLimit && Tend-Tstart>Tmax*rec.Fs) ||(j<Nsyll && Tseg(j+1,1)-Tseg(j,2)>sil_gap*rec.Fs )
                    break;
                end
            elseif  found %not selected
                jend=j-1; break;
            end
        end
        if timeLimit==0 || Tend-Tstart>Tmax*rec.Fs
            if Tend==-1 || Tstart==-1 continue; end
            if (Tend-Tstart)/rec.Fs>L L=(Tend-Tstart)/rec.Fs; end
            inx=inx+1;
            syll{inx}=rectmp(Tstart:Tend);syll{inx}=syll{inx}./max(abs(syll{inx}));
            [Feature{inx}  labels_features ] = SAPfeatures_YM(syll{inx},rec.Fs); %extract the features
            Tsegs{inx}=[max(1,floor(Tseg(jStart:jend,1)-Tstart+1)) ceil((Tseg(jStart:jend,2)-Tstart+1))] ;
            silent_times{inx}=[1 Tsegs{inx}(1,1); Tsegs{inx}(1:end-1,2) Tsegs{inx}(2:end,1); ];
            Tsegs{inx}=round(Tsegs{inx}./rec.Fs*1000*0.988); if Tsegs{inx}(1,1)==0 Tsegs{inx}(1,1)=1; end
            silent_times{inx}=round(silent_times{inx}./rec.Fs*1000*0.988);
            TS=rectmp(Tstart:Tend);
            if rec.Fs <44100
                TS=interp1(1:length(TS),TS,1:rec.Fs/44100:length(TS))';
            end
            syll{inx}=TS;syll{inx}=syll{inx}./max(abs(syll{inx}));
            break;
        end
    end
    clear rec
end
if inx==0 found=0;
else found=1;
    if nargin<4 save 'features.mat' Feature silent_times Tsegs syll
    else eval(['save ' filenameSave  '  Feature silent_times Tsegs syll'])
    end
end



