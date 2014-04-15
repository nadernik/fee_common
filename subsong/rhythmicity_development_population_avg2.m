function rhythmicity_development_population(birdList, datadir, varargin)
% Need to run Combine_development.m for each bird first! datadir is the
% directory where the results from Combine_development.m are stored.

P.AxesAmp = [];
P.AxesFreq = [];
P.Color = 'k';
P.Legend = {'on', 'off'};
P = parseargs(P, varargin{:});

%% Peak Amp
if isempty(P.AxesAmp)
    figure
    P.AxesAmp = axes;
end

if isempty(P.AxesFreq)
    figure
    P.AxesFreq = axes;
end
    
hold(P.AxesAmp , 'on')
hold(P.AxesFreq, 'on')

days = [];
SumPeakFreq = [];
SumPeakAmp = [];
N = [];
AllPeakFreq = {};
AllPeakAmp = {};
for n=1:length(birdList)
    filename = [birdList{n},'_development.mat'];
    load(fullfile(datadir, filename), 'Rel_date', 'PeakAmp', 'PeakFreq');
    
%     hamp(n) = plot(P.AxesAmp,Rel_date,PeakAmp,'.-','Color',P.Color(n));
%     hfreq(n) = plot(P.AxesFreq,Rel_date,PeakFreq,'.-','Color',P.Color(n));
    
    % add rel dates if necessary
    days_to_add = setdiff(Rel_date, days); % values of Rel_date that are not in days
    days = [days, days_to_add];
    N = [N, zeros(size(days_to_add))];
    SumPeakFreq = [SumPeakFreq, zeros(size(days_to_add))];
    SumPeakAmp = [SumPeakAmp, zeros(size(days_to_add))];
    
    for idate = 1:length(Rel_date)
        ndx = find(days == Rel_date(idate));
        
        % add values
        SumPeakFreq(ndx) = SumPeakFreq(ndx) + PeakFreq(idate);
        SumPeakAmp(ndx) = SumPeakAmp(ndx) + PeakAmp(idate);
        
        if length(AllPeakFreq) >= ndx
            AllPeakFreq{ndx} = [AllPeakFreq{ndx}, PeakFreq(idate)];
            AllPeakAmp{ndx} = [AllPeakAmp{ndx}, PeakAmp(idate)];
        else
            AllPeakFreq{ndx} = PeakFreq(idate);
            AllPeakAmp{ndx} = PeakAmp(idate);
        end
            
    
        % add to counts
        N(ndx) = N(ndx) + 1;
    end
    
end

[junk, sndx] = sort(days);

axes(P.AxesAmp)
mn = cellfun(@mean, AllPeakAmp, 'UniformOutput', true);
sd = cellfun(@std, AllPeakAmp, 'UniformOutput', true);
errorbar(days(sndx), mn(sndx), sd(sndx) ./ N(sndx), 'Color', P.Color)

axes(P.AxesFreq)
mn = cellfun(@mean, AllPeakFreq, 'UniformOutput', true);
sd = cellfun(@std, AllPeakFreq, 'UniformOutput', true);
errorbar(days(sndx), mn(sndx), sd(sndx) ./ N(sndx), 'Color', P.Color)


% plot(P.AxesAmp, days(sndx), SumPeakAmp(sndx) ./ N(sndx))
% plot(P.AxesFreq, days(sndx), SumPeakFreq(sndx) ./ N(sndx))

% return
% %% add significance
% for n=1:length(birdList)
%     filename = [birdList{n},'_development.mat'];
%     load(fullfile(datadir, filename));
%     Idx = find(Sig); % find significant peaks
%     
%     plot(P.AxesAmp, Rel_date(Idx),PeakAmp(Idx),'o','Color',P.Color(n));
%     
%     plot(P.AxesFreq, Rel_date(Idx),PeakFreq(Idx),'o','Color',P.Color(n));
% end


%%
xlabel(P.AxesAmp, 'Relative age (days)','fontsize',14);
ylabel(P.AxesAmp, 'Peak Data/Null ratio','fontsize',14);
xlim(P.AxesAmp, [-9 12]);
ylim(P.AxesAmp, [0.8 3.5]);
% if strcmpi(P.Legend, 'on')
%     legend(hamp, birdList,'location','northwest');
% end

xlabel(P.AxesFreq, 'Relative age (days)','fontsize',14);
ylabel(P.AxesFreq, 'Peak frequency (Hz)','fontsize',14);
xlim(P.AxesFreq, [-9 12]);
ylim(P.AxesFreq, [0 14]);
% if strcmpi(P.Legend, 'on')
%     legend(hfreq, birdList,'location','northwest');
% end