% [filename,pathname] = uigetfile('*.xls');
fullfilename = 'C:\Users\Michael\Dropbox\lab\logs\by experiment\area x afferent tracing.xlsx';

sheetname = 'Surgery';
[num, txt] = xlsread(fullfilename, sheetname);
%%
% take column names off the top of text matrix
colnames = txt(1,:)';
txt = txt(2:end,:);

findcol = @(name) strcmp(name, colnames);

col_conc1 = strcmp('HVC left virus', colnames);
col_conc2 = strcmp('HVC right virus', colnames);
conc = [num(:, col_conc1); num(:, col_conc2)];
% conc = log(1./conc);
conc = 1 ./ conc;

col_virus = findcol('HVC fp');
virus_str = txt(:,col_virus);
virus = nan(size(virus_str));
virus(strcmp(virus_str, 'GFP'))     = 1;
virus(strcmp(virus_str, 'mCherry')) = 0;
virus = [virus; virus]; % duplicate for both hemispheres

col_vol1 = findcol('HVC left volume');
col_vol2 = findcol('HVC right volume');
vol = [num(:, col_vol1); num(:, col_vol2)];

tmix  = num(:, findcol('virus mix time'));
tinj1 = num(:, findcol('HVC inj time (L)'));
tinj2 = num(:, findcol('HVC inj time (R)'));
time = [tinj1 - tmix; tinj2 - tmix];

col_age = strcmp('surg age', colnames);
age = num(:, col_age);
age = [age; age]; % duplicate for both hemispheres

%% count neurons

% Left side
n_in  = num(:, findcol('N in HVC (L)'));
i_many = strcmp(txt(:, findcol('N in HVC (L)')), 'many');
n_in(i_many) = 50;
n_out = num(:, findcol('N out HVC (L)'));
i_many = strcmp(txt(:, findcol('N out HVC (L)')), 'many');
n_out(i_many) = 50;
total_neurons1 = n_in + n_out;

% Right side
n_in  = num(:, findcol('N in HVC (R)'));
i_many = strcmp(txt(:, findcol('N in HVC (R)')), 'many');
n_in(i_many) = 50;
n_out = num(:, findcol('N out HVC (R)'));
i_many = strcmp(txt(:, findcol('N out HVC (R)')), 'many');
n_out(i_many) = 50;
total_neurons2 = n_in + n_out;

total_neurons = [total_neurons1; total_neurons2];
total_neurons = min(total_neurons, 50);

%%
% X = [ones(size(age)), conc, virus, vol, time, age];
% [b,bint,r,rint,stats] = regress(total_neurons, X);

%%
figure

titer = conc .* vol ./ 9.2;

jitterx = 1;% + 0.1*(rand(size(conc))-0.5);
jittery = 0.5*(rand(size(total_neurons)) -0.5);
scatter(titer.*jitterx, total_neurons+jittery, 300, '.')
set(gca, 'XScale', 'log')
xlabel('Normalized concentration')
ylabel('Total neurons')

%%
figure
hvcx_axons = [num(:, findcol('HVCX axons (L)'))
              num(:, findcol('HVCX axons (R)'))];
hvc_neurons = [num(:, findcol('N in HVC (L)'))
               num(:, findcol('N in HVC (R)'))];
hvc_neurons(hvc_neurons > 40) = nan;
hvc_neurons(hvc_neurons == 0) = nan;
jitterx = 0.3*(rand(size(total_neurons)) -0.5);
jittery = 0.3*(rand(size(total_neurons)) -0.5);
scatter(hvc_neurons+jitterx, hvcx_axons+jittery,300,'.')
xlabel('Labeled neurons in HVC')
ylabel('Labeled HVC_X neurons')