function dbase= Syllable_duration_distribution(dbase,birdName,Date,Category,fileNum, save)

%%% Calculates the syllable and gap distribution
%%% Tatsuo Okubo
%%% 2011/02/21

%%
switch nargin
    case 6
    otherwise
        save = 1;
end
lst = 7:1:700; % array of histogram syllable edges (ms)
lst2 = 7:1:300; % array of histogram gap edges (ms)
B = 20; % # of bins for smoothing

if nargin==5 % fileNum specified
    C = fileNum;
else
    C = 1:length(dbase.FileLength); % all the files
end

durs = zeros(0,2);
gaps = [];
for c = C % for all the files
    f = find(dbase.SegmentIsSelected{c} == 1);
    if ~isempty(f)
        durs = [durs; dbase.SegmentTimes{c}(f,:)]; % gathering all the onsets and offsets
        gap_on = dbase.SegmentTimes{c}(f(1:end-1),2);
        gap_off = dbase.SegmentTimes{c}(f(2:end),1);
        gaps = [gaps;(gap_off-gap_on)/dbase.Fs*1000];  % gathering all the gaps (ms)
        inter_gap_on = dbase.Times(c)+dbase.SegmentTimes{c}(end,2)/dbase.Fs/60/60/24; % onset of the inter-file gap (MATLAB time)
        if c<length(dbase.Times) % not the last file
            if ~isempty(dbase.SegmentIsSelected{c+1})&&dbase.SegmentIsSelected{c+1}(1)==1; % look at the first syllable of the next file, if it's a song syllable, define inter-file gap
                inter_gap_off = dbase.Times(c+1)+dbase.SegmentTimes{c+1}(1,1)/dbase.Fs/60/60/24; % gap offset (first syllable onset)
                inter_gap = (inter_gap_off-inter_gap_on)*24*60*60;
                if inter_gap>0 && inter_gap<30 % less than 30 seconds
                    gaps = [gaps; inter_gap*1000]; % ms
                end
            end
        end

    end
end

durs = durs(:,2)-durs(:,1); % calculating duration (samples)
durs = durs/dbase.Fs*1000; % converting duration to miliseconds
GOF_DA = judge_bird_TO(durs);
handles.durs = durs; % save in handles
handles.gaps = gaps;

%% histogram of syllable duration distribution
y = histc(durs,lst)/length(durs); % converting to probability
y = y(1:end-1)./diff(lst'./1000); % converting to probability density so that it will not depend on bin size
y = smooth(y,B); % moving average
x = (lst(1:end-1)+lst(2:end))/2; % center value of the bin
x = x';

%% histogram of gap duration distribution
y2 = histc(gaps,lst2)/length(gaps); % converting to probability
y2 = y2(1:end-1)./diff(lst2'./1000); % converting to probability density
y2 = smooth(y2,B); % moving average
x2 = (lst2(1:end-1)+lst2(2:end))/2; % center value of the bin
x2 = x2';

%% maximum likelihood fit of the exponential disribution using data from a finite range
a = 25; % lower bound [ms]
b = 400; % upper bound [ms]
Idx = find((durs>a)&(durs<b));
Subset = durs(Idx);
S = mean(Subset);
f = @(x) x+(a*exp(-a/x)-b*exp(-b/x))/(exp(-a/x)-exp(-b/x))-S;
tau = (fzero(f,mean(durs)))/1000; % ML estimate [s]
z = (1/tau).*exp(-(x/1000)./tau); % best fit exponential

y_sub = histc(Subset,a:1:b)/length(Subset); % converting to probability
x_sub = a:1:b;
z_sub = (1/tau).*exp(-(x_sub/1000)./tau);
z_sub = z_sub';

%% Lillifors goodness-of-fit statistic
cum_y = cumsum(y_sub)./sum(y_sub); % cumulative distribution
cum_z = cumsum(z_sub)./sum(z_sub); % cumulative distribution
[KS,I] = max(abs(cum_y-cum_z));
GOF = KS*sqrt(length(Idx)); % Aronov et al. 2010, >2 cutoff for plastic song

figure(19); clf;
hold on
plot(x_sub,cum_y,'k','linewidth',2)
plot(x_sub,cum_z,'r','linewidth',2)
h = line([x_sub(I),x_sub(I)],[min(cum_y(I),cum_z(I)),max(cum_y(I),cum_z(I))]);
set(h,'color','g','linewidth',2);
grid on
xlabel('Syllable duration (ms)','fontsize',16);
ylabel('Cumulative distribution','fontsize',16);
legend('data','best fit exponential','maximum difference','location','southeast')
title([birdName,'    ',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'   GOF: ',num2str(GOF,2)],'fontsize',16);

%% plot for subsong & plastic song bird
figure(20); clf;
s1=subplot(221);
hold on
if ~isempty(durs) % duration is not empty
    plot(x,y,'k','linewidth',1); % x-axis is the value in between the edges
end
plot(x,z,'r','linewidth',2);
%legend('data',['ML estimate using ',num2str(a),'-',num2str(b),' ms'])
xlim([0 lst(end)]);
ylabel('Probability density (s^{-1})','fontsize',12);
title(['Time constant: ', num2str(tau*1000,3),' ms'],'fontsize',14);

s2=subplot(223);
hold on
if ~isempty(durs) % duration is not empty
    plot(x,y,'k','linewidth',1); % x-axis is the value in between the edges
end
plot(x,z,'r','linewidth',2);
set(gca,'yscale','log');
%legend('data',['ML estimate using ',num2str(a),'-',num2str(b),' ms'])
xlim([0 lst(end)]);
xlabel('Syllable duration (ms)','fontsize',12);
ylabel('Probability density (s^{-1})','fontsize',12);
title(['Goodness-of-fit: ', num2str(GOF,2)],'fontsize',14);

s3=subplot(222);
if ~isempty(gaps) % duration is not empty
    plot(x2,y2,'k','linewidth',2); % x-axis is the value in between the edges
end
xlim([0 lst2(end)]);
ylabel('Probability density (s^{-1})','fontsize',12);
title([birdName,'          ',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3))],'fontsize',16);
box off

s4=subplot(224);
if ~isempty(gaps) % duration is not empty
    plot(x2,y2,'k','linewidth',2); % x-axis is the value in between the edges
end
set(gca,'yscale','log');
xlim([0 lst2(end)]);
xlabel('Gap duration (ms)','fontsize',12);
ylabel('Probability density (s^{-1})','fontsize',12);
box off

%% save data and figures (TO DO: separate the save part)
if save
    FileName = [birdName,'_',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'_syll_gap_duration.mat'];
    switch Category
        case 1 % subsong
            PathName = 'Z:\Data\Song_rhythm\Subsong';
        case 2 % early plastic song
            PathName = 'Z:\Data\Song_rhythm\Early_plastic_song';
        case 3 % HVC lesion
            PathName = 'Z:\Data\Song_rhythm\HVC_lesion';
        case 4 % LMAN inactivation
            PathName = 'Z:\Data\Song_rhythm\LMAN_inactivation';
        case 5 % LMAN inactivation
            PathName = 'Z:\Data\Song_rhythm\HVC_cooling';
        case 6 % LMAN inactivation
            PathName = 'Z:\Data\Song_rhythm\LMAN_cooling';
        case 7 % LMAN inactivation
            PathName = 'Z:\Data\Song_rhythm\Development';
        case 8 % Late plastic song
            PathName = 'Z:\Data\Song_rhythm\Late_plastic_song';
        case 9 % X lesion
            PathName = 'Z:\Data\Song_rhythm\X_lesion';
        case 10 % MMAN lesion
            PathName = 'c:\stetner\data\mman lesion';
        otherwise
            error('Unknown category')
    end

    if Category==7 | Category==9
        if exist([PathName,filesep,birdName])
            save([PathName,filesep,birdName,filesep,FileName],'lst','lst2','durs','gaps','GOF','GOF_DA','tau');
        else % make new directory for the bird
            mkdir(PathName,birdName);
            save([PathName,filesep,birdName,filesep,FileName],'lst','lst2','durs','gaps','GOF','GOF_DA','tau');
        end
        cd([PathName,filesep,birdName]);
    else
        save([PathName,filesep,FileName],'lst','lst2','durs','gaps','GOF','GOF_DA','tau'); % save .mat
        cd(PathName)
    end

    saveas(20,[birdName,'_',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'_syll_gap_duration.fig'],'fig');
    %close(19);
    %close(20);
end
    dbase.durs = durs;
    dbase.gaps = gaps;
