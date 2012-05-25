%%% Developmental tracking (figure 2)
%%% load birdName_development.mat
%%% Tatsuo Okubo
%%% 2011/06/26

birdList = {'to2223','to2241','to2253','to2313','to2352','to2403'};
cd('Z:\Data\Song_rhythm\Development');

%Color = ['k','b','g','c','m','r'];
Color = ['k','k','k','k','k','k'];

%% Peak Amp
figure(60); clf; hold on
figure(61); clf; hold on
for n=1:length(birdList)
    load([birdList{n},'_development.mat']);
    Idx = find(Sig); % find significant peaks
    
    figure(60);
    plot(Rel_date,PeakAmp,'.-','Color',Color(n));
    
    figure(61);
    %%% remove non-peak
    if n==3
        PeakFreq(3) = nan;
    end
    plot(Rel_date,PeakFreq,'.-','Color',Color(n));
end


%% add significance
for n=1:length(birdList)
    load([birdList{n},'_development.mat']);
    Idx = find(Sig); % find significant peaks
    
    figure(60);
    plot(Rel_date(Idx),PeakAmp(Idx),'o','Color',Color(n));
    
    figure(61);
    plot(Rel_date(Idx),PeakFreq(Idx),'o','Color',Color(n));
end


%%
figure(60);
xlabel('Relative age (days)','fontsize',14);
ylabel('Peak Data/Null ratio','fontsize',14);
xlim([-9 12]);
ylim([0.8 3.5]);
legend(birdList,'location','northwest');

figure(61);
xlabel('Relative age (days)','fontsize',14);
ylabel('Peak frequency (Hz)','fontsize',14);
xlim([-9 12]);
ylim([0 14]);
legend(birdList,'location','northwest');