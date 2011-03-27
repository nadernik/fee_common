function Batch_song_rhythm(birdName,folder,Category,fileNum)
%%% Song rhythm batch
%%% Category 1:subsong, 2:plastic song, 3:HVC lesion, 4:LMAN inactivation
%%% Tatsuo Okubo
%%% 2011/02/20
 
if Category ==7 %% load dbase for TO data for development    
    cd(['Z:\Data\SAP\',birdName,'\',folder,'\bouts'])
    load analysis_segmented % load dbase
    
elseif Category ==8 %% adult song database   
    
else % load dbase for DA data
    load(['c:\stetner\data\' birdName '\' folder '\analysis.mat']) % load dbase
    
    if strfind(dbase.PathName,'z:')
        dbase.PathName = strrep(dbase.PathName,'z:','Y:');
    elseif strfind(dbase.PathName,'Z:')
        dbase.PathName = strrep(dbase.PathName,'Z:','Y:');
    end
end

Date = datevec(dbase.Times(1)); % get experiment date

%% Select syllables within bout, syllable duration distribution
MaxInterval = 0.3; % [s] % maximum gap interval
MinBoutDuration = 0.5; % [s] minimum bout duraion
if nargin > 3
    dbase=Select_syllable_within_bout(dbase,MaxInterval,MinBoutDuration,fileNum); % add dbase.BoutTimes
    dbase = Syllable_duration_distribution(dbase,birdName,Date,Category,fileNum); % add dbase.durs, dbase.gaps
else
    dbase=Select_syllable_within_bout(dbase,MaxInterval,MinBoutDuration); % add dbase.BoutTimes
    dbase = Syllable_duration_distribution(dbase,birdName,Date,Category); % add dbase.durs, dbase.gaps
end

%% Calculate song rhythm from the data
params.L = 1; % spectral analysis window [s]
params.Pad = 4; % number of zero pad for FFT (0: nextpow2)
params.Fs = 1000; % sampling frequency after resampling [Hz]
params.NW = 2; % % time half-bandwidth product
params.K = 1; % number of tapers to use
params.fpass = [0,50];

if nargin > 3
    [Freq,P_amp,P_syll,P_on] = Actual_spectrum(dbase,params,fileNum);
else
    [Freq,P_amp,P_syll,P_on] = Actual_spectrum(dbase,params);
end

%% Simulate song rhythm for the null hypothesis
params.N = 1000; % number of simulations
[Freq,P_syll_null,P_on_null] = Simulate_spectrum(dbase,params);

%% Plot spectrum
Plot_spectrum(3,Freq,P_amp,[],birdName,Date);
Plot_spectrum(4,Freq,P_syll,P_syll_null,birdName,Date);
Plot_spectrum(5,Freq,P_on,P_on_null,birdName,Date);

%% save results
switch Category
    case 1 % subsong
        PathName = 'Z:\Data\Song_rhythm\Subsong';
    case 2 % plastic song
        PathName = 'Z:\Data\Song_rhythm\Plastic_song';
    case 3 % HVC lesion
        PathName = 'Z:\Data\Song_rhythm\HVC_lesion';
    case 4 % LMAN inactivation
        PathName = 'Z:\Data\Song_rhythm\LMAN_inactivation';
%     case 5 % HVC cooling
%         PathName = 'Z:\Data\Song_rhythm\HVC_cooling';
%     case 6 % LMAN cooling
%         PathName = 'Z:\Data\Song_rhythm\LMAN_cooling';
    case 7 % development
        PathName = ['Z:\Data\Song_rhythm\Development'];
end
FileName = [birdName,'_',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'_song_rhythm.mat'];
if exist([PathName,filesep,birdName,filesep,FileName])
    save([PathName,filesep,birdName,filesep,FileName]);
else
     mkdir(PathName,birdName);
     save([PathName,filesep,birdName,filesep,FileName]);
end

cd(PathName)
saveas(3,[birdName,'_',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'_sound_amp_rhythm.fig'],'fig');
saveas(4,[birdName,'_',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'_syll_pattern_rhythm.fig'],'fig');
saveas(5,[birdName,'_',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'_syll_onset_rhythm.fig'],'fig');

    function Plot_spectrum(Fig,Freq,P,P_null,birdName,Date)
        figure(Fig); clf
        s1=subplot(211);
        hold on
        plot(Freq,mean(P,2),'g','linewidth',3);
        if ~isempty(P_null)
            plot(Freq,mean(P_null,2),'r','linewidth',3);
            legend('Data','Null hyp');
        end
        switch Fig
            case 3
                title(['Sound amplitude     ',birdName,'   ',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3))],'fontsize',20);
            case 4
                title(['Syllable pattern     ',birdName,'   ',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3))],'fontsize',20);
            case 5
                title(['Syllable onset     ',birdName,'   ',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3))],'fontsize',20);
        end
        ylabel('Linear spectrum','fontsize',16);
        grid on
        
        s2=subplot(212);
        hold on
        plot(Freq,10*log10(mean(P,2)),'g','linewidth',3);
        if ~isempty(P_null)
            plot(Freq,10*log10(mean(P_null,2)),'r','linewidth',3);
            legend('Data','Null hyp');
        end
        xlabel('Frequency (Hz)','fontsize',16);
        ylabel('Log spectrum (dB)','fontsize',16);
        grid on
        linkaxes([s1,s2],'x');
    end
end