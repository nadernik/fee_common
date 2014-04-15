function [Freq,P_syll_null,P_on_null] = Simulate_spectrum(dbase,params);
%%% calculate song rhythm from actual data
%%% Tatsuo Okubo
%%% 2011/01/21
%%% dbase.params.Fs : sampling frequency of the original data
%%% params.params.Fs : sampling frequency of the down-sampled data

Shift = round(params.Fs*params.L); % [samples]
Margin = round(params.Fs*0.05); % 50ms before and after bout onset [samples]
P_syll_null = [];
P_on_null = [];

durs = dbase.durs./1000; % syllable duration distribution [s]
gaps = dbase.gaps./1000; % gap duration distribution [s]
Idx = find(gaps<0.3); % gaps in the bout has to be less than 0.3s by definition
gaps = gaps(Idx);
tau_syll = mean(durs);
tau_gap = mean(gaps);
durs_check_1 = []; % checking the simulated syllable duration distribution [ms]
gaps_check_1 = []; % checking the simlated gap duration distribution [ms]
durs_check_2 = []; % checking the simulated syllable duration distribution [ms]
gaps_check_2 = []; % checking the simlated gap duration distribution [ms]

h = waitbar(0,'Null hypothesis...');
for n = 1:params.N % for all the simulated bouts
    waitbar(n/params.N);
    
    %% null hypothesis: discard syllables shorter than 7ms, gaps shorter than 7ms, and longer than 300ms
    x = Generate_syllable(tau_syll);
    Syllable = ones(round(params.Fs*x),1);
    while length(Syllable)<params.L*params.Fs % add up to params.L
        y = Generate_gap(tau_gap);%gaps(temp(1))
        Syllable = [Syllable; zeros(round(params.Fs*y),1)];
        x = Generate_syllable(tau_syll);
        Syllable = [Syllable; ones(round(params.Fs*x),1)];
    end
    Syllable = Syllable(1:round(params.L*params.Fs)); % take the duration of the window;
    Syll_onset_times = [1; find(diff(Syllable)==1)]./1000; % [s]
    
    Point = zeros(params.Fs*params.L,1);
    Point(ceil(params.Fs*Syll_onset_times)) = 1;
    
    % check syllable gap duration distribution (sanity check)
    Syll_on = find(Syllable(1:end)==1 & [0;Syllable(1:end-1)]==0);
    Syll_off = find(Syllable(1:end)==1 & [Syllable(2:end);1]==0);
    L = min(length(Syll_on),length(Syll_off));
    Syll_on = Syll_on(1:L);
    Syll_off = Syll_off(1:L);
    if ~isempty(Syll_on)
        durs_check_1 = [durs_check_1; ((Syll_off-Syll_on)/params.Fs)*1000];
        gaps_check_1 = [gaps_check_1; ((Syll_on(2:end)-Syll_off(1:end-1))/params.Fs)*1000];
    end
    Times = (0:length(Syllable)-1)./params.Fs;
    %% Plot each bout (down sampled)
%     figure(1); clf;
%     plot(Times,Syllable);
%     xlim([0 params.L]);
%     xlabel('Time (s)','fontsize',16);
%     ylabel('Syllables','fontsize',12);
%     title(['n = ',num2str(n)]);
%     ylim([-0.1 1.1]);
    
    %% spectral analysis on syllable pattern
    Syllable = Syllable-mean(Syllable);
    [Freq, P] = myMultitaper(Syllable,params.Fs,params.NW,params.K,params.Pad,params.fpass);
    P_syll_null = [P_syll_null,P];
    
    %% spectral analysis on point processes
    Point = Point-mean(Point);
    [Freq, P] = myMultitaper(Point,params.Fs,params.NW,params.K,params.Pad,params.fpass);
    P_on_null = [P_on_null,P];
end
close(h) ; % close waitbar

%% check syllable and gap distribution (sanity check)
durs = durs*1000; % [ms]
gaps = gaps*1000; % [ms]
lst = 7:1:700; % syllable bins (ms)
lst2 = 7:1:250; % gap bins (ms)
B = 20;

y = histc(durs,lst)/length(durs); % converting to probability
y = y(1:end-1)./diff(lst'./1000); % converting to probability density so that it will not depend on bin size
y = smooth(y,B); % moving average
x = (lst(1:end-1)+lst(2:end))/2; % center value of the bin
x = x';

y2 = histc(gaps,lst2)/length(gaps); % converting to probability
y2 = y2(1:end-1)./diff(lst2'./1000); % converting to probability density
y2 = smooth(y2,B); % moving average
x2 = (lst2(1:end-1)+lst2(2:end))/2; % center value of the bin
x2 = x2';

y_check_1 = histc(durs_check_1,lst)/length(durs_check_1); % converting to probability
y_check_1 = y_check_1(1:end-1)./diff(lst'./1000); % converting to probability density so that it will not depend on bin size
y_check_1 = smooth(y_check_1,B); % moving average

y2_check_1 = histc(gaps_check_1,lst2)/length(gaps_check_1); % converting to probability
y2_check_1 = y2_check_1(1:end-1)./diff(lst2'./1000); % converting to probability density
y2_check_1 = smooth(y2_check_1,B); % moving average

%% syllable and gap duration distribution
figure(10); clf;
s1=subplot(211);
hold on
plot(x,y,'k','linewidth',2);
plot(x,y_check_1,'b','linewidth',2);
xlabel('Syllable duration (ms)','fontsize',16);
legend('Data','Null');
grid on
s2=subplot(212);
hold on
plot(x2,y2,'k','linewidth',2);
plot(x2,y2_check_1,'b','linewidth',2);
xlabel('Gap duration (ms)','fontsize',16)
legend('Data','Null');
grid on

    function x=Generate_syllable(tau_syll)
        x = exprnd(tau_syll);
        while x<0.007
            x = exprnd(tau_syll);
        end
    end

    function y=Generate_gap(tau_gap)
        y = exprnd(tau_gap);
        while y<0.007 | y>=0.3
            y = exprnd(tau_gap);
        end
    end
end