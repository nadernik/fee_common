function [Freq,P_amp,P_syll,P_on] = Actual_spectrum(dbase,params,fileNum)
%%% calculate song rhythm from actual data
%%% Tatsuo Okubo
%%% 2011/01/21
%%% dbase.Fs : sampling frequency of the original data
%%% params.Fs : sampling frequency of the down-sampled data

P_amp = [];
P_syll = [];
P_on = [];

Shift = round(dbase.Fs*params.L); % [samples]
Margin = round(dbase.Fs*0.05); % 50ms before and after bout onset [samples]

%% for all the files
h = waitbar(0,'Calculating song rhythm...');

if nargin==3 % fileNum specified
    C = fileNum;
else
    C = 1:length(dbase.FileLength);
end

for c = C % array of files to be analyzed
    waitbar(c/length(dbase.FileLength));
    
    if ~isempty(dbase.BoutTimes{c}) % only analyze files with bouts
        %% load sound and calculate amplitude
        [x fs] = eval(['egl_' dbase.SoundLoader '([''' dbase.PathName '\' dbase.SoundFiles(c).name '''],1)']);
        filtered_sound = egf_FIRBandPass1000to4000(x,fs); %  bandpass from 1-4 kHz to avoid fricatives
        wind = round(0.0025*dbase.Fs); % 2.5 ms sliding window
        amp = smooth(10*log10(filtered_sound.^2+eps),wind);
        amp = amp-min(amp(wind:length(amp)-wind));
        amp(find(amp<0))=0;
        
        %% binarize syllables
        SyllBinary = zeros(length(x),1); % initialize
        SyllIdx = find(dbase.SegmentIsSelected{c} == 1);
        SyllOnset = dbase.SegmentTimes{c}(SyllIdx,1);
        SyllOffset = dbase.SegmentTimes{c}(SyllIdx,2);
        for m=1:length(SyllIdx) % for all syllables
            SyllBinary(SyllOnset(m):SyllOffset(m)) = 1;
            Syll_onset_Binary(SyllOnset(m)) = 1;
            Syll_offset_Binary(SyllOffset(m)) = 1;
        end
        
        %%
        for m = 1:size(dbase.BoutTimes{c},1) % for all the bouts
            if dbase.BoutTimes{c}(m,1)-Margin<=0
                continue
            end
            BoutOnset = dbase.BoutTimes{c}(m,1)-Margin;
            BoutOffset = min(length(x),dbase.BoutTimes{c}(m,2)+Margin);
            BoutDuration = (BoutOffset-BoutOnset)./dbase.Fs;
            
            if BoutDuration>params.L
                for n=1:floor(BoutDuration/params.L) % divide bout duration (s) by the size of window (s)
                    Onset = BoutOnset + Shift*(n-1);
                    Song = x(Onset:Onset+Shift-1);
                    Sound_temp = amp(Onset:Onset+Shift-1); % sound amplitude (dB)
                    Sound = resample(Sound_temp,params.Fs,round(dbase.Fs)); % down sample
                    Times = (0:length(Sound)-1)/params.Fs;
                    
                    Syll_window = find(SyllOnset>=Onset & SyllOffset<=Onset+Shift-1);
                    Syll_onset_times = (SyllOnset(Syll_window)-Onset)/dbase.Fs; % [s]                    
                    Syll_offset_times = (SyllOffset(Syll_window)-Onset)/dbase.Fs; % [s]
                    TempIdx = find(Syll_onset_times>0); % avoid Syll_onset_times = 0
                    Syll_onset_times = Syll_onset_times(TempIdx);
                    Syll_offset_times = Syll_offset_times(TempIdx);
                    Syllable = zeros(params.Fs*params.L,1);
                    for k=1:length(Syll_onset_times)
                        Syllable(ceil(params.Fs*Syll_onset_times(k)):ceil(params.Fs*Syll_offset_times(k))) = 1;
                    end
                    Point = zeros(params.Fs*params.L,1);
                    Point(ceil(params.Fs*Syll_onset_times)) = 1;

                    %% Plot each bout (down sampled)
%                     figure(1);
%                     s1=subplot(411);
%                     displaySpecgramQuick(Song,dbase.Fs,[500 8000]);
%                     title(['File: ',num2str(c),' Bout: ',num2str(m),' Window:',num2str(n)]);
%                     xlabel('','fontsize',16);
%                     ylabel('Frequency (Hz)','fontsize',12);
%                     s2=subplot(412);
%                     plot(Times,Sound);
%                     ylabel('Sound amplitude (dB)','fontsize',12);
%                     box off
%                     s3=subplot(413);
%                     plot(Times,Syllable);
%                     ylim([-0.1 1.1])
%                     xlim([0 params.L]);
%                     box off
%                     title('Binary syllable pattern');
%                     s4=subplot(414);
%                     stem(Times,Point);
%                     xlim([0 params.L]);
%                     ylim([-0.1 1.1]);
%                     title('Syllable onset')
%                     box off
%                     linkaxes([s4,s3,s2,s1],'x');
                    
                    %% spectral analysis on sound amplitude
                    Sound = Sound-mean(Sound); % mean subtract
                    [Freq, P1] = myMultitaper(Sound,params.Fs,params.NW,params.K,params.Pad,params.fpass);
                    P_amp = [P_amp, P1];
                    
                    %% spectral analysis on syllable pattern
                    Syllable = Syllable-mean(Syllable);
                    [Freq, P2] = myMultitaper(Syllable,params.Fs,params.NW,params.K,params.Pad,params.fpass);
                    P_syll = [P_syll,P2];
                    
                    %% spectral analysis on point processes
                    Point = Point-mean(Point);
                    [Freq, P3] = myMultitaper(Point,params.Fs,params.NW,params.K,params.Pad,params.fpass);
                    P_on = [P_on, P3];
                    
                    %% plot spectrum
%                     figure(2); clf;
%                     hold on
%                     plot(Freq,P2,'r','linewidth',2);
%                     title(['File: ',num2str(c),' Bout: ',num2str(m),' Window:',num2str(n)]);
%                     xlabel('Frequency (Hz)','fontsize',16);
%                     ylabel('Linear power spectrum','fontsize',16);
%                     
                end
            end
        end
    end
end
close(h) ; % close waitbar