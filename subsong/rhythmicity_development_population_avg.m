function rhythmicity_development_population_avg(birdList, datadir, varargin)
% Need to run Combine_development.m for each bird first! datadir is the
% directory where the results from Combine_development.m are stored.

P.AxesAmp = [];
P.AxesFreq = [];
P.Color = repmat('k', 1, length(birdList));
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

Rel_date = nan(9,length(birdList));
PeakAmp = nan(9,length(birdList));
PeakFreq = nan(9,length(birdList));
for n=1:length(birdList)
    filename = [birdList{n},'_development.mat'];
    d = load(fullfile(datadir, filename));
    Rel_date(:,n) = d.Rel_date;
    PeakAmp(:,n) = d.PeakAmp;
    PeakFreq(:,n) = d.PeakFreq;
end

max(cellfun(max, Rel_date)
for iday = 1:length(day_list)
    for ibird = 1:
    avg_peak_amp = 

axes(P.AxesAmp)
hold on
plotbyfactor(Rel_date, PeakAmp, ones(length(Rel_date)), 1)

return

%% add significance
for n=1:length(birdList)
    filename = [birdList{n},'_development.mat'];
    load(fullfile(datadir, filename));
    Idx = find(Sig); % find significant peaks
    
    plot(P.AxesAmp, Rel_date(Idx),PeakAmp(Idx),'o','Color',P.Color(n));
    
    plot(P.AxesFreq, Rel_date(Idx),PeakFreq(Idx),'o','Color',P.Color(n));
end


%%
xlabel(P.AxesAmp, 'Relative age (days)','fontsize',14);
ylabel(P.AxesAmp, 'Peak Data/Null ratio','fontsize',14);
xlim(P.AxesAmp, [-9 12]);
ylim(P.AxesAmp, [0.8 3.5]);
if strcmpi(P.Legend, 'on')
    legend(hamp, birdList,'location','northwest');
end

xlabel(P.AxesFreq, 'Relative age (days)','fontsize',14);
ylabel(P.AxesFreq, 'Peak frequency (Hz)','fontsize',14);
xlim(P.AxesFreq, [-9 12]);
ylim(P.AxesFreq, [0 14]);
if strcmpi(P.Legend, 'on')
    legend(hfreq, abirdList,'location','northwest');
end