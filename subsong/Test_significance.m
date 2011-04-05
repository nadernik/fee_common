function [PeakAmp,PeakFreq,Sig,MSE] = Test_significance(Freq,P,P_null,p,params,ROI,birdName,Date, Title, Legend)
%%% Testing significance of two spectra
%%% Bokil et al. (JNM, 2007)
%%% Test_significance(Freq,P,P_null,p,params,ROI)
%%% region of frequency to find the peak
%%% Tatsuo Okubo
%%% 2011/02/22
x = 10*log10(mean(P,2));
x_null = 10*log10(mean(P_null,2));
Difference = x-x_null; % difference in log space
Ratio = mean(P,2)./mean(P_null,2); % ratio in linear space
Idx = find(Freq>ROI(1) & Freq<ROI(2)); % index within ROI
MSE = (sum((x(Idx)-x_null(Idx)).^2))./length(Idx); % mean square error within the region of interest
%[PeakAmp,I] = max(Difference(Idx));
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

figure(50); clf;
s1=subplot(311);
hold on
plot(Freq,mean(P,2),'g','linewidth',3);
plot(Freq,mean(P_null,2),'r','linewidth',3);
if nargin==10
    legend(Legend,'interpreter','none');
else
    legend('Data','Null hyp');
end
ylabel('Linear power spectrum (dB)','fontsize',12);
title([birdName,'    ',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'      ',Title],'fontsize',20,'interpreter','none');
grid on

s2=subplot(312);
hold on
plot(Freq,10*log10(mean(P,2)),'g','linewidth',3);
plot(Freq,10*log10(mean(P_null,2)),'r','linewidth',3);
if nargin==10
    legend(Legend,'interpreter','none');
else
    legend('Data','Null hyp');
end
ylabel('Log power spectrum (dB)','fontsize',12);
%title([birdName,'    ',num2str(Date(1)),'-',num2str(Date(2)),'-',num2str(Date(3)),'      ',Title],'fontsize',20);
grid on
s3=subplot(313);
hold on
plot(Freq,Ratio,'b','linewidth',3);
if Sig
    plot(PeakFreq,PeakAmp,'rx','markersize',10,'linewidth',2); % red star on a significant peak
else
    plot(PeakFreq,PeakAmp,'bx','markersize',10,'linewidth',2); % black star on a non-significant peak
end
h=line(xlim,[1 1]);
set(h,'color','k','linewidth',2);
ylabel('Ratio','fontsize',12);
grid on
if ~isempty(Lower) % significant bars
    yl = ylim;
    for n=1:length(Lower)
        h=line([Lower(n),Upper(n)],[yl(1)+0.5 yl(1)+0.5]);
        set(h,'color','r','linewidth',10);
        %h2=patch([Lower(n),Upper(n),Upper(n),Lower(n)],[yl(1) yl(1) yl(2) yl(2)],'r');
        %set(h2,'FaceAlpha',0.1);
    end
end

% s3=subplot(313);
% hold on
% plot(Freq,dz,'linewidth',2);
% plot(Freq,CI_lower,'r:','linewidth',2);
% plot(Freq,CI_upper,'r:','linewidth',2);
% 
% if ~isempty(Lower)
%     yl = ylim;
%     for n=1:length(Lower)
%         h=line([Lower(n),Upper(n)],[yl(1)+1 yl(1)+1]);
%         set(h,'color','r','linewidth',10);
%         %h2=patch([Lower(n),Upper(n),Upper(n),Lower(n)],[yl(1) yl(1) yl(2) yl(2)],'r');
%         %set(h2,'FaceAlpha',0.1);
%     end
% end
% h=line(xlim,[0 0]);
% set(h,'color','k','linewidth',2);
% ylabel('Test statistic','fontsize',12);
% % s4=subplot(414);
% plot(Freq,vdz);
% xlabel('Frequency (Hz)','fontsize',16);
% ylabel('Jackknifed variance','fontsize',12);
% box off
end