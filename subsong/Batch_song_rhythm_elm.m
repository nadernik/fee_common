function Batch_song_rhythm_elm(birdName, fileName,Category,fileNum)
%%% Song rhythm batch for all categories except cooling
%%% Batch_song_rhythm(birdName,fileName,Category,fileNum)
%%% fileName: e.g.) Z:\Data\SAP\to2253\2245\bouts\analysis_segmented.mat
%%% Category: 1:subsong, 2:early plastic,
%%% 3:HVC lesion, 4:LMAN inactivation, 7:development
%%% fileNum: file # to be analyzed e.g.)1:300, leave it blank for all files
%%% Category 1:subsong, 2:plastic song, 3:HVC lesion, 4:LMAN inactivation
%%% Tatsuo Okubo
%%% 2011/04/01
%%% Emily Mackevicius, modified the folder structure it expects, and how it
%%% saves things.

load(fileName)
Date = datevec(dbase.Times(1)); % get experiment date

%% Select syllables within bout, syllable duration distribution
MaxInterval = 0.3; % [s] % maximum gap interval
MinBoutDuration = 0.5; % [s] minimum bout duraion
if nargin > 3 % file number specified
    dbase=Select_syllable_within_bout(dbase,MaxInterval,MinBoutDuration,fileNum); % add dbase.BoutTimes
    dbase = Syllable_duration_distribution(dbase,birdName,Date,Category,fileNum, 0); % add dbase.durs, dbase.gaps
else
    dbase=Select_syllable_within_bout(dbase,MaxInterval,MinBoutDuration); % add dbase.BoutTimes
    dbase = Syllable_duration_distribution(dbase,birdName,Date,Category,0); % add dbase.durs, dbase.gaps
end

%% Calculate song rhythm from the data
params.L = 1; % size of the spectral analysis window [s]
params.Pad = 4; % number of zero pad for FFT (0: nextpow2)
params.Fs = 1000; % sampling frequency after resampling [Hz]
params.NW = 2; % % time half-bandwidth product
params.K = 1; % number of tapers to use
params.fpass = [0,30]; % frequency region of interest [Hz]

if nargin > 2 % fileNum specified
    [Freq,P_amp,P_syll,P_on] = Actual_spectrum(dbase,params,fileNum);
else % all files
    [Freq,P_amp,P_syll,P_on] = Actual_spectrum(dbase,params);
end

%% Simulate song rhythm for the null hypothesis
params.N = 1000; % number of simulations
[Freq,P_syll_null,P_on_null] = Simulate_spectrum(dbase,params);

%% Plot spectrum
Plot_spectrum(3,Freq,P_amp,[],birdName,Date);
Plot_spectrum(4,Freq,P_syll,P_syll_null,birdName,Date);
Plot_spectrum(5,Freq,P_on,P_on_null,birdName,Date);

%% Statistical test
p = 0.01; % significance level
ROI = [2 20]; % region for finding the peak [Hz]
Title = '';
Stats = Test_significance(Freq,P_syll,P_syll_null,p,params,ROI,birdName,Date, Title);
% %% save results
% FileName = [birdName,'_',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'_song_rhythm.mat'];
% if Category==7 | Category==9 % development or X lesion
%     if exist([PathName,filesep,birdName])
%         save([PathName,filesep,birdName,filesep,FileName]);
%     else % make new directory for the bird
%         mkdir(PathName,birdName);
%         save([PathName,filesep,birdName,filesep,FileName]);
%     end
%     cd([PathName,filesep,birdName]);
% else
%     save([PathName,filesep,FileName]); % save .mat
%     cd(PathName)
% end
% saveas(3,[birdName,'_',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'_sound_amp_rhythm.fig'],'fig');
% saveas(4,[birdName,'_',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'_syll_pattern_rhythm.fig'],'fig');
% saveas(5,[birdName,'_',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'_syll_onset_rhythm.fig'],'fig');
% saveas(50,[birdName,'_',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'_significance.fig'],'fig');
% 
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
        xlim([0 30]);
        
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
        xlim([0 30]);
%    end
% end