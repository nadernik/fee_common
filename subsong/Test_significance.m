function Stats = Test_significance(Freq,P,P_null,p,params,ROI,birdName,Date, Title, Leg)
%%% TO DO: combine with Test_significance

%%% Testing significance of two spectra
%%% Bokil et al. (JNM, 2007)
%%% Test_significance(Freq,P,P_null,p,params,ROI)
%%% region of frequency to find the peak
%%% Tatsuo Okubo
%%% 2011/02/22
x = mean(P,2);
x_null = mean(P_null,2);
Ratio = x./x_null; % ration in linear space
Idx = find(Freq>ROI(1) & Freq<ROI(2)); % index within ROI
MSE = mean((x(Idx)-x_null(Idx)).^2); % mean square error within the region of interest
[PeakAmp,I] = max(Ratio(Idx));
PeakFreq = Freq(Idx(I));
[dz,vdz,Adz]=  two_group_test_spectrum(P,P_null);
CI_lower = norminv(p/2,0,sqrt(vdz)); % confidence interval
CI_upper = norminv(1-p/2,0,sqrt(vdz)); % confidence interval
Sig = (dz<CI_lower | dz>CI_upper);
Lower = Freq(find(diff([0;Sig])==1)); % [Hz]
Upper = Freq(find(diff([Sig;0])==-1)); % [Hz]
Idx = find((Upper-Lower)>(params.NW/params.L)); % significance region has to be greater than W (multiple comparison)
Lower = Lower(Idx); % significant region [Hz]
Upper = Upper(Idx); % significant region [Hz]
if sum(PeakFreq>=Lower & PeakFreq<=Upper)
    Sig = 1;
else
    Sig = 0;
end

%%
figure(50); clf;
s1=subplot(211);
hold on
plot(Freq,mean(P,2),'g','linewidth',3);
plot(Freq,mean(P_null,2),'r','linewidth',3);
xlim([0 30]); %%% added
if exist('Leg')
    legend(Leg,'interpreter','none');
else
    legend('Data','Null hyp');
end
xlabel('Frequency (Hz)','fontsize',14);
ylabel('Power spectrum','fontsize',12);
title([birdName,'    ',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'      ',Title],'fontsize',20,'interpreter','none');
grid on

s2=subplot(212);
hold on
plot(Freq,Ratio,'g','linewidth',3);
if Sig
    plot(PeakFreq,PeakAmp,'gx','markersize',10,'linewidth',2); % green star on a significant peak
else
    plot(PeakFreq,PeakAmp,'kx','markersize',10,'linewidth',2); % black star on a non-significant peak
end
h=line(xlim,[1 1]);
xlim([0 30]); %%% added
%ylim([0 3]);
set(h,'color','k','linewidth',2);
xlabel('Frequency (Hz)','fontsize',16);
ylabel('Ratio','fontsize',12);
grid on
if ~isempty(Lower)
    yl = ylim;
    for n=1:length(Lower)
        h=line([Lower(n),Upper(n)],[yl(1)+0.1 yl(1)+0.1]);
        set(h,'color','r','linewidth',10);
    end
end

%% output is a structure with 4 different fields
Stats.PeakAmp = PeakAmp;
Stats.PeakFreq = PeakFreq;
Stats.Sig = Sig;
Stats.MSE = MSE;
end