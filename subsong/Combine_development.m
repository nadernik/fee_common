%%% Developmental tracking of the song rhythm
%%% Figure 2
%%% Tatsuo Okubo
%%% 2011/06/26

clear;
birdName = '2303'; % for development
Thres_day = [2011,4,2]; % first day where GOF > 2
indir = 'C:\stetner\data\mman lesion';
outdir = 'C:\stetner\data\mman lesion\rhythmicity development';

%%
List = dir(fullfile(indir, [birdName '*song_rhythm.mat'])); % find all song_rhythm files
% initialize
P_syll_pop = [];
P_ratio_pop = [];
PeakAmp_temp = [];
PeakFreq_temp = [];
Sig_temp = [];
MSE_temp = [];
Bird_temp = {};
Date_list = {};
Date_sort = [];
for i=1:length(List) % for all the days within the folder
    i
    List(i).name
    load(fullfile(indir, List(i).name)); % load song_rhythm.mat
    
    PeakAmp_temp(i) = Stats.PeakAmp;
    PeakFreq_temp(i) = Stats.PeakFreq;
    Sig_temp(i) = Stats.Sig;
    MSE_temp(i) = Stats.MSE;
    
    Date_list_temp{i} = [num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3))];
    Rel_date_temp(i) = datenum(Date(1),Date(2),Date(3)) - datenum(Thres_day); % relative developmental day
    P_syll_pop = [P_syll_pop, mean(P_syll,2)]; % add to population data
    P_ratio_pop = [P_ratio_pop, mean(P_syll,2)./mean(P_syll_null,2)];
end
[Y,I] = sort(Rel_date_temp); % sort according to days
P_syll_pop = P_syll_pop(:,I); % sort
P_ratio_pop = P_ratio_pop(:,I); % sort
Abs_date = Date_list_temp(I);
Rel_date = Rel_date_temp(I);
PeakAmp = PeakAmp_temp(I);
PeakFreq = PeakFreq_temp(I);
Sig = Sig_temp(I);
MSE = MSE_temp(I);

%% save as .mat
FileName = [birdName,'_development.mat'];
save(fullfile(outdir, FileName),'Abs_date','Rel_date','PeakAmp','PeakFreq','Sig','MSE');
%msgbox('Done')