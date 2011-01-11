function handles = vc_cmf_Heliox(handles)

vcdb = handles.vcdb;
Col = size(vcdb.d.sf,2)+1; % column nubmer to add IsHeliox
for i=1:size(vcdb.d.i,1)
    if vcdb.d.i{i}.dbaseEventNdx < 9
        vcdb.d.sf(i,Col)=1; % Heliox
    else
        vcdb.d.sf(i,Col)=0; % Not Heliox
    end
end
vcdb.f.sfname{Col} = 'IsHeliox';

XFeature = get(handles.popupXFeature,'Value'); % get current x feature (e.g. 1:duration)
XFeaturelabel = strrep(vcdb.f.sfname(XFeature),'_','\_');

Heliox = [];
Baseline = [];
for i=1:size(vcdb.d.i,1)
    if vcdb.d.sf(i,Col) % Heliox
        Heliox = [Heliox; vcdb.d.sf(i,XFeature)];
    else % baseline
        Baseline = [Baseline; vcdb.d.sf(i,XFeature)];
    end
end

% figure(2)
% hold on
% hist(Baseline,20)
% hist(Heliox,20)
% h = findobj(gca,'Type','patch')
% set(h(1),'FaceColor','g')
% set(h(2),'FaceColor','b')
% legend('Baseline','Heliox')
% xlabel(XFeaturelabel)

[H,P] = kstest2(Baseline,Heliox); % K-S test for two sample populations

figure(2)
clf
subplot(1,2,1)
if isempty(Heliox) | isempty(Baseline)
    errordlg('No data!')
    return
else
    X = linspace(min([Heliox; Baseline]),max([Heliox; Baseline]),20);
end
M = histc(Baseline,X)./size(Baseline,1);
N = histc(Heliox,X)./size(Heliox,1);
hold on
plot(X,M,'bx-','linewidth',4)
plot(X,N,'rx-','linewidth',4)
hold off
legend('Baseline','Heliox','location','northwest')
xlabel(XFeaturelabel,'fontsize',16)
ylabel('Probability','fontsize',14)
set(gca,'fontsize',14)

subplot(1,2,2)
hold on
h1 = cdfplot(Baseline);
set(h1,'color','b','linewidth',4)
h2 = cdfplot(Heliox);
set(h2,'color','r','linewidth',4)
xlabel(XFeaturelabel,'fontsize',16)
ylabel('Cumulative distribution','fontsize',14)
title(['P = ',num2str(P,3)],'fontsize',18)
grid off
set(gca,'fontsize',14)
hold off