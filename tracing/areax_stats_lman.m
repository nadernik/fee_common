% [filename,pathname] = uigetfile('*.xls');
fullfilename = 'C:\Users\Michael\Dropbox\lab\logs\by experiment\area x afferent tracing.xlsx';

sheetname = 'Surgery';
[num, txt] = xlsread(fullfilename, sheetname);
%%
% take column names off the top of text matrix
colnames = txt(1,:)';
txt = txt(2:end,:);

findcol = @(name) strcmp(name, colnames);

col_conc1 = strcmp('LMAN conc (L)', colnames);
col_conc2 = strcmp('LMAN conc (R)', colnames);
conc = [num(:, col_conc1); num(:, col_conc2)];
% conc = log(1./conc);
conc = 1 ./ conc;

col_virus = findcol('LMAN Fluorphore');
virus_str = txt(:,col_virus);
virus = nan(size(virus_str));
virus(strcmp(virus_str, 'GFP'))     = 1;
virus(strcmp(virus_str, 'mCherry')) = 0;
virus = [virus; virus]; % duplicate for both hemispheres

col_vol1 = findcol('LMAN vol (L)');
col_vol2 = findcol('LMAN vol (R)');
vol = [num(:, col_vol1); num(:, col_vol2)];

tmix  = num(:, findcol('virus mix time'));
tinj1 = num(:, findcol('LMAN inj time (L)'));
tinj2 = num(:, findcol('LMAN inj time (R)'));
time = [tinj1 - tmix; tinj2 - tmix];

col_age = strcmp('surg age', colnames);
age = num(:, col_age);
age = [age; age]; % duplicate for both hemispheres

%% count neurons

% Left side
n_in  = num(:, findcol('LMAN cells (L)'));
i_many = strcmp(txt(:, findcol('LMAN cells (L)')), 'many');
n_in(i_many) = 50;
n_out = num(:, findcol('other cells (L)'));
i_many = strcmp(txt(:, findcol('other cells (L)')), 'many');
n_out(i_many) = 50;
total_neurons1 = n_in + n_out;

% Right side
n_in  = num(:, findcol('LMAN cells (R)'));
i_many = strcmp(txt(:, findcol('LMAN cells (R)')), 'many');
n_in(i_many) = 50;
n_out = num(:, findcol('other cells (R)'));
i_many = strcmp(txt(:, findcol('other cells (R)')), 'many');
n_out(i_many) = 50;
total_neurons2 = n_in + n_out;

total_neurons = [total_neurons1; total_neurons2];
total_neurons = min(total_neurons, 50);

% exclude birds with Synaptophysin-mCherry
temp = strcmp(virus_str, 'Synaptophysin mCherry');
i_exclude = [temp; temp]; % duplicate for both hemispheres
total_neurons(i_exclude) = nan;
%%
% X = [ones(size(age)), conc, virus, vol, time, age];
% [b,bint,r,rint,stats] = regress(total_neurons, X);

%%
figure

titer = conc .* vol ./ 9.2;


jitterx = 1;% + 0.1*(rand(size(conc))-0.5);
jittery = rand(size(total_neurons)) -0.5;
scatter(titer.*jitterx, total_neurons+jittery, 300, '.')
set(gca, 'XScale', 'log')
xlabel('Normalized concentration')
ylabel('Total neurons')

%%
figure
lmanx_axons = [num(:, findcol('# LMAN-X axons (L)'))
              num(:, findcol('LMAN-X axons (R)'))];
lman_neurons = [num(:, findcol('LMAN cells (L)'))
               num(:, findcol('LMAN cells (R)'))];

lman_neurons(lman_neurons > 40) = nan;
lman_neurons(lman_neurons == 0) = nan;
jitterx = 0.3*(rand(size(lman_neurons)) -0.5);
jittery = 0.3*(rand(size(lman_neurons)) -0.5);
scatter(lman_neurons, lmanx_axons,300,'.')
xlabel('Labeled neurons in LMAN')
ylabel('Labeled LMAN_X neurons')
xlim([0 6])
ylim([0 6])