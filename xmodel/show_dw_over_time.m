t1 = 50;
t2 = 90;


% find corresponding hvc units
[junk, h1] = max(hvc_output(:,t1));
[junk, h2] = max(hvc_output(:,t2));

% find first time msn was overly active
plot(squeeze(dw_before_comp(:,h1,:))', 'b')
hold on
plot(squeeze(dw_before_comp(:,h2,:))', 'g')
hold off
%%
avgdw = squeeze(mean(max(dw_before_comp,0),2));
plot(avgdw')

