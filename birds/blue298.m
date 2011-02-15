%% 2011-02-10
% Analyzing variability after CNQX + APV injections

% He was in experiment 12/12 thru 12/18

% cluster syllables

date_of_birth = datenum('09/24/2010');

days(1).datenum       = datenum('12/12/2010');
days(1).expername     = '2010-12-12';
days(1).drug          = 'PBS';
days(1).concentration = 10; %millimolar
days(1).time_in       = datenum([2010 12 12 14 25 00]); % 2:25pm
days(1).time_out      = NaN; % just left it in

days(2).datenum       = datenum('12/13/2010');
days(2).expername     = '2010-12-13';
days(2).drug          = 'CNQX + APV';
days(2).concentration = 2.25; %millimolar
days(2).time_in       = datenum([2010 12 13 13 58 00]); % 1:58pm
days(2).time_out      = datenum([2010 12 13 22 21 00]); % 10:21pm

days(3).datenum       = datenum('12/14/2010');
days(3).expername     = '2010-12-14';
days(3).drug          = 'PBS';
days(3).concentration = 10; %millimolar
days(3).time_in       = NaN; % left it in from yesterday night
days(3).time_out      = NaN;

days(4).datenum       = datenum('12/15/2010');
days(4).expername     = '2010-12-15';
days(4).drug          = 'PBS';
days(4).concentration = 10; %millimolar
days(4).time_in       = NaN;
days(4).time_out      = NaN;

days(5).datenum       = datenum('12/16/2010');
days(5).expername     = '2010-12-16';
days(5).drug          = 'CNQX + APV';
days(5).concentration = 3; %millimolar
days(5).time_in       = datenum([2010 12 16 17 28 00]); % 5:28pm
days(5).time_out      = datenum([2010 12 17 00 26 00]); % 12:26am

days(6).datenum       = datenum('12/17/2010');
days(6).expername     = '2010-12-17';
days(6).drug          = 'PBS';
days(6).concentration = 10; %millimolar
days(6).time_in       = NaN; % left it in from yesterday night
days(6).time_out      = NaN;

days(7).datenum       = datenum('12/18/2010');
days(7).expername     = '2010-12-18';
days(7).drug          = 'CNQX + APV';
days(7).concentration = 4.5; %millimolar
days(7).time_in       = datenum([2010 12 18 15 08 00]); % 3:08pm
days(7).time_out      = datenum([2010 12 19 08 00 00]); % 8:00am next morning

% annotate expers that haven't been already
annotate_exper('blue298','2010-12-12')
annotate_exper('blue298','2010-12-15')
annotate_exper('blue298','2010-12-16')

%% 2011-02-11

% cluster
for dotm = 12:18
    expername = ['2010-12-' int2str(dotm)];
    vcQuickCluster('blue298',expername,'polygons20101214.mat',1,'root','c:\stetner\data\')
end

%% 2011-02-15
 
targetSyll = 1;
targetRegion = [30 70];
variability_vs_drug('blue298', days, targetSyll, targetRegion)