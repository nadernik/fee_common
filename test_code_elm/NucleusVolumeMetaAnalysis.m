%% volumes of nuclei
i = 1; 
RA.Initials{i} = 'KKBHJ';
RA.Ages{i} = [5 10 20 40 70 100 365];
RA.MeanVolume{i} = [.022 .043 .056 .185 .29 .198 .207];
RA.SDVolume{i} = [.001 .011 .028 .040 .059 .061 .01];
HVC.Initials{i} = 'KKBHJ';
HVC.Ages{i} = [10 20 40 70 100 365];
HVC.MeanVolume{i} = [.038 .119 .243 .257 .261 .267];
HVC.SDVolume{i} = [.005 .021 .042 .059 .005 .044];

i = 2; 
RA.Initials{i} = 'SBEMAA';
RA.Ages{i} = [25 53];
RA.MeanVolume{i} = [.228 .402];
RA.SDVolume{i} = [.03 .101];
HVC.Initials{i} = 'SBEMAA';
HVC.Ages{i} = [25 53];
HVC.MeanVolume{i} = [.408 .521];
HVC.SDVolume{i} = [.085 .124];

i = 3; 
RA.Initials{i} = 'BNN';
RA.Ages{i} = [25 50 65 120];
RA.MeanVolume{i} = [.120 .232 .211 .228];
RA.SDVolume{i} = [.03 .019 .021 .017];
HVC.Initials{i} = 'BNN';
HVC.Ages{i} = [25 50 65 120];
HVC.MeanVolume{i} = [.215 .355 .309 .322];
HVC.SDVolume{i} = [.008 .030 .020 .019];

i = 4; 
RA.Initials{i} = 'GNRRG';
RA.Ages{i} = [14*30]; % songs were measured at 14 months, so birds were at least this old
RA.MeanVolume{i} = [.21]; % using numbers for medium broods
RA.SDVolume{i} = [.01];
HVC.Initials{i} = 'GNRRG';
HVC.Ages{i} = [14*30]; % songs were measured at 14 months, so birds were at least this old
HVC.MeanVolume{i} = [.31]; % using numbers for medium broods
HVC.SDVolume{i} = [.01];

i = 5; 
RA.Initials{i} = 'AK';
RA.Ages{i} = [90]; % 90 or older
RA.MeanVolume{i} = [.24]; % estimated from bar graph, control side
RA.SDVolume{i} = [.02];
%% 
figure; hold all; 
for i = 1:numel(RA.Initials)
    errorbar(RA.Ages{i}, RA.MeanVolume{i}, RA.SDVolume{i}); 
end

plot(datenum('10/20/2013') - datenum('5/25/13'), .144, 'r.', 'markersize', 10)
%text(datenum('10/20/2013') - datenum('5/25/13'), .144, '3827')
legend(RA.Initials)
xlabel('age (dph)')
ylabel('RA volume (mm^3)')

figure; hold all
for i = 1:numel(HVC.Initials)
    errorbar(HVC.Ages{i}, HVC.MeanVolume{i}, HVC.SDVolume{i}); 
end
plot(datenum('10/20/2013') - datenum('5/25/13'), .256, 'r.', 'markersize', 10)
%text(datenum('10/20/2013') - datenum('5/25/13'), .256, '3827')
xlabel('age (dph)')
ylabel('HVC volume (mm^3)')
legend(HVC.Initials)