%%% Song_rhythm_population
%%% population analysis on pre-computed spectra
%%% Tatsuo Okubo
%%% 2011/02/22

clear;
%% parameters
p = 0.01; % significance level
ROI = [2 20]; % region for finding the peak [Hz]

Cat = 7;%[1:4];
%%
for Category = Cat
    switch Category
        case 1 % subsong
            PathName = 'Z:\Data\Song_rhythm\Subsong';
            Title = 'Subsong';
        case 2 % plastic song
            PathName = 'Z:\Data\Song_rhythm\Early_plastic_song';
            Title = 'Early plastic song';
        case 3 % HVC lesion
            PathName = 'Z:\Data\Song_rhythm\HVC_lesion';
            Title = 'HVC lesion';
        case 4 % LMAN inactivation
            PathName = 'Z:\Data\Song_rhythm\LMAN_inactivation';
            Title = 'LMAN inactivation';
        case 7 % Development
            PathName = 'Z:\Data\Song_rhythm\Development\to2241'; %%%%%%%%%%%%%%%%%%%%%%%
            Title = 'Development';
    end
    
    cd(PathName);
    List = dir('*song_rhythm.mat');
    P_syll_pop = [];
    PeakAmp_temp = [];
    PeakFreq_temp = [];
    Sig_temp = [];
    MSE_temp = [];
    Bird_temp = {};
    for i=1:length(List)
        i
        List(i).name
        load(List(i).name);
        [PeakAmp_temp(i),PeakFreq_temp(i),Sig_temp(i), MSE_temp(i)] = Test_significance(Freq,P_syll,P_syll_null,p,params,ROI,birdName,Date,Title);
        saveas(50,[birdName,'_',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'_significance.fig'],'fig');
        Bird_temp{i} = birdName;
        Date_list{i} = Date;
        Date_sort(i) = Date(3); % date
        P_syll_pop = [P_syll_pop, mean(P_syll,2)]; % add to population data
    end
    [Y,I] = sort(Date_sort);
    Bird{1,Category} = Bird_temp(I); 
    PeakAmp{1,Category} = PeakAmp_temp(I);
    PeakFreq{1,Category} = PeakFreq_temp(I);
    Sig{1,Category} = Sig_temp(I);
    MSE{1,Category} = MSE_temp(I);
    
    %% plot population spectrum
    figure(40+Category); clf;
    s1=subplot(211);
    hold on
    if Category==7 % development
        plot(Freq,P_syll_pop,'linewidth',2); % color plot
    else
        plot(Freq,P_syll_pop,'k');
        plot(Freq,mean(P_syll_pop,2),'r','linewidth',2);
    end
    xlabel('Frequency (Hz)','fontsize',16);
    ylabel('Linear spectral power ','fontsize',14);
    title([Title, '   (n = ',num2str(size(P_syll_pop,2)),')'],'fontsize',20);
    grid on
    box off
    s2=subplot(212);
    hold on
    if Category==7 % development
        plot(Freq,10*log10(P_syll_pop),'linewidth',2);
    else
        plot(Freq,10*log10(P_syll_pop),'k');
        plot(Freq,10*log10(mean(P_syll_pop,2)),'r','linewidth',2);
    end
    xlabel('Frequency (Hz)','fontsize',16);
    ylabel('Log spectral power (dB)','fontsize',14);
    grid on
    box off
    linkaxes([s1,s2],'x');
end
save(['Z:\Data\Song_rhythm',filesep,'Population']);

%% Peak Amp
figure(60); clf;
hold on
for Category=Cat
    Data = [];
    for n=1:length(PeakAmp{Category})
        if Sig{Category}(n) % significant
            plot(Category+0.08*randn,PeakAmp{Category}(n),'rx','linewidth',2,'markersize',10);
            Data = [Data; PeakAmp{Category}(n)];
        else
            plot(Category+0.08*randn,PeakAmp{Category}(n),'bx','linewidth',2,'markersize',10);
        end
    end
    MEAN(Category) = mean(Data);
    STD(Category) = std(Data);
    plot(Category+0.3,MEAN(Category),'ro');
    errorbar(Category+0.3,MEAN(Category),STD(Category),'r');
end
set(gca,'xtick',1:4,'xticklabel',{'Subsong','Plastic song','HVC lesion','LMAN inactivation'},'fontsize',12);
%xlim([0 5])
ylabel('Difference (dB)','fontsize',16)


%% Peak Freq
figure(61); clf;
hold on
for Category=Cat
    Data = [];
    for n=1:length(PeakFreq{Category})
        if Sig{Category}(n) % significant
            plot(Category+0.08*randn,PeakFreq{Category}(n),'rx','linewidth',2,'markersize',10);
            Data = [Data; PeakFreq{Category}(n)];
        else
            plot(Category+0.08*randn,PeakFreq{Category}(n),'bx','linewidth',2,'markersize',10);
        end
    end
    MEAN(Category) = mean(Data);
    STD(Category) = std(Data);
    plot(Category+0.3,MEAN(Category),'ro');
    errorbar(Category+0.3,MEAN(Category),STD(Category),'r');
end
set(gca,'xtick',1:4,'xticklabel',{'Subsong','Plastic song','HVC lesion','LMAN inactivation'},'fontsize',12);
xlim([0 5])
ylabel('Peak Frequency (Hz)','fontsize',16)

%% MSE
figure(62); clf;
hold on
for Category=Cat
    Data = [];
    for n=1:length(MSE{Category})
        if MSE{Category}(n)<20 % exclude outlier
            plot(Category+0.08*randn,MSE{Category}(n),'rx','linewidth',2,'markersize',10);
            Data = [Data; MSE{Category}(n)];
        end
    end
    MEAN(Category) = mean(Data);
    STD(Category) = std(Data);
    plot(Category+0.3,MEAN(Category),'ro');
    errorbar(Category+0.3,MEAN(Category),STD(Category),'r');
end
set(gca,'xtick',1:4,'xticklabel',{'Subsong','Plastic song','HVC lesion','LMAN inactivation'},'fontsize',12);
%xlim([0 5])
ylabel('Mean squared error (dB^2)','fontsize',16)
