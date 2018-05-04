%% montage awake
% dbasepath = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct18\Undirected1'; 
% dbasepath = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct21\Undirected1'; 
dbasepath = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Nov18'; 
saveherecnmfe = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Nov18\cnmferesults'; 

load(fullfile(dbasepath, 'analysis.mat')); 
Y = [];
CompSoundSONG = [];
CompSpecSONG = [];
segs = []; 
FnumBnum = []; 
Labels = {};
moat = 1; 
save(fullfile(dbasepath, 'compiled'), 'Y', 'CompSoundSONG', 'CompSpecSONG',...
   '-v7.3')
for filei = 1:length(dbase.SegmentTimes)
    segtimes = dbase.SegmentTimes{filei}(dbase.SegmentIsSelected{filei}==1,:); 
    seglabels = dbase.SegmentTitles{filei}(dbase.SegmentIsSelected{filei}==1);
    load(fullfile(dbasepath, dbase.SoundFiles(filei).name), 'VIDEO', 'VIDEOfs', ...
        'SOUND', 'SOUNDfs', 'nFrames', ...
        'tSound','AudBinWhenFrameEnds', 'AudBinWhenFrameStarts',...
        'SPEC', 'specTime', 'F');%,'VIDEO'); 
    % SONG
    if sum(dbase.SegmentIsSelected{filei}==1)>0
        bouts = SegsToBouts(segtimes, moat*SOUNDfs, length(SOUND)); 
        for bi = 1:size(bouts,1)
            useframes = round(bouts(bi,1)/SOUNDfs*VIDEOfs):...
                round(bouts(bi,2)/SOUNDfs*VIDEOfs);
            useframes(useframes<=0) = []; useframes(useframes>nFrames) = []; 
            if length(useframes)>0
                Y1 = permute(VIDEO(useframes,:,:),[2 3 1]); 
                Y = cat(3,Y,Y1); 
                roundingshift = round((AudBinWhenFrameStarts(useframes(1)))+1) - bouts(bi,1);
                segs = [segs; ...
                    segtimes((segtimes(:,1)>bouts(bi,1))&(segtimes(:,2)<bouts(bi,2)),:) ...
                    - bouts(bi,1)...
                    + length(CompSoundSONG)...
                    - roundingshift]; 
                Labels = [Labels seglabels((segtimes(:,1)>bouts(bi,1))&(segtimes(:,2)<bouts(bi,2)))];
                CompSoundSONG = [CompSoundSONG; SOUND(round((AudBinWhenFrameStarts(useframes(1)))+1):...
                    (round(AudBinWhenFrameStarts(useframes(end)))+floor(SOUNDfs/VIDEOfs)))]; 
                CompSpecSONG = cat(1,CompSpecSONG,SPEC(useframes,:,:));
                FnumBnum = [FnumBnum; repmat([filei bi],length(useframes),1)];
                display(['SONG file ' num2str(filei) ' bout ' num2str(bi)])
            end
        end
    end
    save(fullfile(dbasepath, 'compiled'), 'Y', 'CompSoundSONG', 'CompSpecSONG', 'FnumBnum', 'segs', 'Labels', 'VIDEOfs',...
       '-v7.3'); % also saved background subtracted CompVidSONG
end
CompVidSONG = permute(Y,[3 1 2]); % back sub
save(fullfile(dbasepath, 'compiled'), 'Y', 'CompVidSONG', 'CompSoundSONG', 'CompSpecSONG', 'FnumBnum', 'segs', 'Labels', 'VIDEOfs', ...
       '-v7.3'); % also saved background subtracted CompVidSONG
ShowCaVid(CompVidSONG,CompSoundSONG,CompSpecSONG, [], [], 0)

%%
%% montage video during sleep
path = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct21\Sleep';
DIR = dir(fullfile(path, '*.mat')); 

Y = [];
CompSound = [];
CompSpec = [];

for filei = 1:length(DIR)
    load(fullfile(path, DIR(filei).name), 'VIDEO', 'VIDEOfs', ...
        'SOUND', 'SOUNDfs', 'nFrames', ...
        'tSound','AudBinWhenFrameEnds', 'AudBinWhenFrameStarts',...
        'SPEC', 'specTime', 'F');%,'VIDEO'); 
    Y1 = permute(VIDEO,[2 3 1]); 
    Y = cat(3,Y,Y1); 
    CompSound = [CompSound; SOUND]; 
    CompSpec = cat(1,CompSpec,SPEC);
    save(fullfile(path, 'compiled'), 'Y', 'CompSound', 'CompSpec', '-v7.3');
    display(['compiled file ' num2str(filei)])
end
%% CNMFE to find neurons for singing data
close all; %clear all
% saveherecnmfe = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct18\Undirected1\cnmferesults'; 
global  d1 d2 numFrame ssub tsub sframe num2read Fs neuron neuron_ds ...
    neuron_full Ybg_weights nam; %#ok<NUSED> % global variables, don't change them manually
nam = fullfile(dbasepath, 'compiled'); %'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6701_Nov16'; 
cnmfe_choose_data;
% create Source2D class object for storing results and parameters
Fs = VIDEOfs;             % frame rate
ssub = 1;           % spatial downsampling factor
tsub = 1;           % temporal downsampling factor
gSig = 3;           % width of the gaussian kernel, which can approximates the average neuron shape
gSiz = 25;          % maximum diameter of neurons in the image plane. larger values are preferred.
neuron_full = Sources2D('d1',d1,'d2',d2, ... % dimensions of datasets
    'ssub', ssub, 'tsub', tsub, ...  % downsampleing
    'gSig', gSig,...
    'gSiz', gSiz, ...
    'merge_thr', 0.5);
neuron_full.Fs = Fs;         % frame rate

% with dendrites or not 
with_dendrites = true;
if with_dendrites
    % determine the search locations by dilating the current neuron shapes
    neuron_full.options.search_method = 'dilate'; 
    neuron_full.options.bSiz = 20;
else
    % determine the search locations by selecting a round area
    neuron.options.search_method = 'ellipse';
    neuron.options.dist = 4;
end
% create convolution kernel to model the shape of calcium transients
tau_decay = 1;  %
tau_rise = 0.1;
nframe_decay = ceil(10*tau_decay*neuron_full.Fs);  % number of frames in decaying period
bound_pars = false;     % bound tau_decay/tau_rise or not
neuron_full.kernel = create_kernel('exp2', [tau_decay, tau_rise]*neuron_full.Fs, nframe_decay, [], [], bound_pars);

% downsample data for fast and better initialization
sframe=1;						% user input: first frame to read (optional, default:1)
num2read= numFrame;             % user input: how many frames to read   (optional, default: until the end)

tic;
cnmfe_load_data;
fprintf('Time cost in downsapling data:     %.2f seconds\n', toc);

Y = neuron.reshape(Y, 1);       % convert a 3D video into a 2D matrix

% compute correlation image and peak-to-noise ratio image.
% cnmfe_show_corr_pnr;    % this step is not necessary, but it can give you some...
%                         % hints on parameter selection, e.g., min_corr & min_pnr

% initialization of A, C
% parameters
debug_on = false;
save_avi = false;
patch_par = [1,1]*1; %1;  % divide the optical field into m X n patches and do initialization patch by patch
K = [1000]; % maximum number of neurons to search within each patch. you can use [] to search the number automatically

min_corr = 0.8;     % minimum local correlation for a seeding pixel
min_pnr = 9;       % minimum peak-to-noise ratio for a seeding pixel
min_pixel = 4;      % minimum number of nonzero pixels for each neuron
bd = 1;             % number of rows/columns to be ignored in the boundary (mainly for motion corrected data)
neuron.updateParams('min_corr', min_corr, 'min_pnr', min_pnr, ...
    'min_pixel', min_pixel, 'bd', bd);

% greedy method for initialization
tic;
neuron.options.deconv_flag = false; 
neuron.options.seed_method = 'auto'; 
[center, Cn, ~] = neuron.initComponents_endoscope(Y, K, patch_par, debug_on, save_avi);
fprintf('Time cost in initializing neurons:     %.2f seconds\n', toc);

% show results
figure;
imagesc(Cn);
hold on; plot(center(:, 2), center(:, 1), 'or');
colormap; axis off tight equal;

% sort neurons
[~, srt] = sort(max(neuron.C, [], 2), 'descend');
neuron.orderROIs(srt);
neuron_init = neuron.copy();

% iteratively update A, C and B
% parameters, merge neurons
display_merge = false;          % visually check the merged neurons
view_neurons = false;           % view all neurons

% parameters, estimate the background
spatial_ds_factor = 3;      % spatial downsampling factor. it's for faster estimation
thresh = 10;     % threshold for detecting frames with large cellular activity. (mean of neighbors' activity  + thresh*sn)
if ~isfield(neuron.P, 'sn') || isempty(neuron.P.sn)
    sn = neuron.estNoise(Y);
else
    sn = neuron.P.sn; 
end
bg_neuron_ratio = 1.5;  % spatial range / diameter of neurons

% parameters, estimate the spatial components
max_overlap = 20;       % maximum number of neurons overlaping at one pixel 

% parameters, estimate the temporal components
smin = 5;       % thresholding the amplitude of the spike counts as smin*noise level

neuron.options.maxIter = 4;   % iterations to update C

% parameters for running iteratiosn 
nC = size(neuron.C, 1);    % number of neurons 

maxIter = 5;        % maximum number of iterations 
miter = 1; 
while miter <= maxIter
    % merge neurons, order neurons and delete some low quality neurons
    % parameters
        merge_thr = [1e-5, 0.70, .1];     % thresholds for merging neurons
        % corresponding to {sptial overlaps, temporal correlation of C,
        %temporal correlation of S}
    
    % merge neurons
    cnmfe_quick_merge;              % run neuron merges
    
    % udpate background (cell 1, the following three blocks can be run iteratively)
    % estimate the background
    tic;
    cnmfe_update_BG;
    fprintf('Time cost in estimating the background:        %.2f seconds\n', toc);
    % neuron.playMovie(Ysignal); % play the video data after subtracting the background components.
    
    % update spatial & temporal components
    tic;
    for m=1:5    
        %temporal
        neuron.updateTemporal_endoscope(Ysignal, smin);
        cnmfe_quick_merge;              % run neuron merges
        %spatial
        neuron.updateSpatial_endoscope(Ysignal, max_overlap);
        neuron.trimSpatial(.01); 
        if isempty(merged_ROI)
            break;
        end
    end
    fprintf('Time cost in updating spatial & temporal components:     %.2f seconds\n', toc);
    
    % pick neurons from the residual (cell 4).
    if miter==1
        neuron.options.seed_method = 'auto'; % methods for selecting seed pixels {'auto', 'manual'}
        [center_new, Cn_res, pnr_res] = neuron.pickNeurons(Ysignal - neuron.A*neuron.C, patch_par, 'auto'); % method can be either 'auto' or 'manual'
    end
    
    % stop the iteration 
    temp = size(neuron.C, 1); 
    if or(nC==temp, miter==maxIter)
        break; 
    else
        miter = miter+1; 
        nC = temp; 
    end
end
save(saveherecnmfe, 'neuron', ...
    '-v7.3')
%%
%% using old A, find C for new Y!! 
saveherecnmfe = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct21\Undirected1\cnmferesults'; 
load C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct21\Sleep\compiled
clearvars -except Y saveherecnmfe
Ysleep = reshape(Y,120000,size(Y,3)); 
clearvars -except Ysleep saveherecnmfe
Csleep = []; 
for istart = 1:1000:size(Ysleep,2)
    load(saveherecnmfe,  'neuron')
    Y = Ysleep(:,istart:min((istart+1000-1),size(Ysleep,2)));
    Ybg = neuron.localBG(Y); 
    Ysignal = Y-Ybg; 
    neuron.downSample(Ysignal);
    neuron.C = (neuron.A'*neuron.A)\(neuron.A'*Ysignal); 
    neuron.updateTemporal_endoscope(Ysignal); 
    Csleep = [Csleep neuron.C]; 
    clearvars -except Ysleep Csleep istart saveherecnmfe
    istart
end
save('C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct21\cnmfe_results_sleep', 'Csleep',...
     '-v7.3')
%% make motif-aligned plot, choose neuron order
clear all
% dbasepath = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct18\Undirected1'; 
% saveherecnmfe = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct18\Undirected1\cnmferesults'; 
% dbasepath = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct21\Undirected1'; 
% saveherecnmfe = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct21\Undirected1\cnmferesults'; 
% dbasepath = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6701_Nov16'; 
% saveherecnmfe = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6701_Nov16\cnmferesults'; 

dbasepath = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Nov18'; 
saveherecnmfe = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Nov18\cnmferesults'; 


load(fullfile(dbasepath, 'compiled.mat'));
load(saveherecnmfe, 'neuron'); 

clf
% find full motifs
LabelCanon = {'B' 'C' 'D' 'E' 'F'}; 
SOUNDfs = 40000; 
% VIDEOfs = 20; 
moat = .2; 
mstart = []; 
msegs = zeros(length(LabelCanon),2,0); 
params.WantTheseLabels = LabelCanon;
for li = 1:length(Labels)-length(LabelCanon)
    params.Method = 'labels'; 
    params.CheckTheseLabels = Labels(li:li+length(LabelCanon)-1); 
    if MotifCheck(params)
        mstart = [mstart li];
        msegs = cat(3,msegs, segs(li:li+length(LabelCanon)-1,:)); 
    end
end
% find average dur of each syllable and gap
DurSylCanon = mean(squeeze(diff(msegs,[],2)),2)/SOUNDfs; 
DurGapCanon = mean(squeeze(diff([msegs(1:end-1,2) msegs(2:end,1)],[],2)),2)/SOUNDfs; 
tmp = cumsum(reshape([DurSylCanon'; [DurGapCanon' 0]],1,2*length(DurSylCanon))); 
DesiredSegTimes = [-moat 0 ...
    tmp(1:end-1)...
    sum(DurSylCanon)+sum(DurGapCanon)+moat];
upFac = 3; 
tCanon = (-moat*VIDEOfs*upFac:(sum(DurSylCanon)+sum(DurGapCanon)+moat)*VIDEOfs*upFac)/VIDEOfs/upFac; 
% make a new matrix Nneurons X Nmotifs X Tmotif
[Nneurons,TotalDur] = size(neuron.C);
Nmotifs = length(mstart); 
Tmotif = length(tCanon); 
ByMotif = zeros(Nneurons,Nmotifs,Tmotif);
UpC = spline((1:TotalDur)/VIDEOfs, neuron.C, 1/VIDEOfs:1/VIDEOfs/upFac:(TotalDur)/VIDEOfs); 
% UpC(3,round(segs(:)/SOUNDfs*VIDEOfs*upFac))=100; % for debugging
for mi = 1:length(mstart)
    tIndUnwarped = max(1,round((segs(mstart(mi),1)/SOUNDfs-moat)*VIDEOfs*upFac)):...
        min(round((segs(mstart(mi)+length(LabelCanon)-1,2)/SOUNDfs+moat)*VIDEOfs*upFac),size(UpC,2));
    Unwarped = UpC(:,tIndUnwarped);
    UnwarpedSegTimes = [-moat reshape(segs(mstart(mi):mstart(mi)+length(LabelCanon)-1,:)'-segs(mstart(mi),1),1,2*length(LabelCanon))/SOUNDfs ...
        (segs(mstart(mi)+length(LabelCanon)-1,2)-segs(mstart(mi),1))/SOUNDfs+moat];
%     warpedSpiketimes = TimeWarp_elm(Spiketimes, ActualSegTimes, DesiredSegTimes)
    DesUnwarpedTimes = TimeWarp_elm(tCanon, DesiredSegTimes, UnwarpedSegTimes);
    for ni = 1:Nneurons
        ByMotif(ni,mi,:) = spline((tIndUnwarped/VIDEOfs/upFac-segs(mstart(mi),1)/SOUNDfs), Unwarped(ni,:),DesUnwarpedTimes);
    end
    if mi == 2
        sampsong = CompSoundSONG(tIndUnwarped(1)*SOUNDfs/VIDEOfs/upFac:tIndUnwarped(end)*SOUNDfs/VIDEOfs/upFac); 
    end
%     clf; subplot(4,1,1); displaySpecgramQuick(CompSoundSONG(tIndUnwarped(1)*SOUNDfs/VIDEOfs/upFac:tIndUnwarped(end)*SOUNDfs/VIDEOfs/upFac), SOUNDfs)
%     subplot(4,1,2:4); imagesc(squeeze(ByMotif(:,mi,:))); colormap(flipud(gray)); pause
    %     ByMotif(:,mi,:) = neuron.C(:,
end
% imagesc reshaped matrix, and/or average matrix
% GravCent = bsxfun(@rdivide, sum(squeeze(median(ByMotif,2)).*repmat(tCanon,Nneurons,1),2),...
%     sum(squeeze(median(ByMotif,2)),2)); 
% [~,ind] = sort(GravCent);
[~,tmax] = max(squeeze(median(ByMotif(:,:,tCanon>-.05&tCanon<(tCanon(end)-moat)),2)),[],2);
[~,indSeqSort] = sort(tmax); 
clims = [0 10]; 
h(1) = subplot('position', [.1 .8 .8 .1]);
spectrogramELM(sampsong, SOUNDfs, .002, 1);
axis off
h(2) = subplot('position', [.1 .1 .8 .7]);
AllMotifs = reshape(permute(ByMotif(indSeqSort,:,:),[2 1 3]),Nneurons*Nmotifs,length(tCanon)); 
color_palet = 1-[[1 0 0]; [1 .6 0]; [.7 .6 .4]; [.6 .8 .3]; [0 .6 .3]; [0 0 1]; [0 .6 1]; [0 .7 .7]; [.7 0 .7];  [.7 .4 1]]; 
color_palet = color_palet([1:2:end 2:2:end],:); % scramble slightly
nColors = color_palet(mod(1:(Nneurons),size(color_palet,1))+1,:); 
satPrc = 95;
AllMotifs(AllMotifs>prctile(AllMotifs(:),satPrc)) = prctile(AllMotifs(:),satPrc);
ColoredAllMotifs = cat(3,...
    repmat(reshape(repmat(nColors(:,1)',Nmotifs,1),Nneurons*Nmotifs,1),1,Tmotif).*AllMotifs,...
    repmat(reshape(repmat(nColors(:,2)',Nmotifs,1),Nneurons*Nmotifs,1),1,Tmotif).*AllMotifs,...
    repmat(reshape(repmat(nColors(:,3)',Nmotifs,1),Nneurons*Nmotifs,1),1,Tmotif).*AllMotifs);
image(1-ColoredAllMotifs/max(ColoredAllMotifs(:)),'xdata', tCanon+moat, 'ydata', .5+(0:Nneurons))
xlabel('Time (s, warped)')
ylabel('Neuron #')
% axis off
hold on
% set(gca, 'ytick', [])
% for ni = 1:Nneurons
%     text(0, Nmotifs*(indSeqSort(ni)-.5),num2str(indSeqSort(ni)), 'verticalalignment', 'middle',...
%         'horizontalalignment', 'right','color', nColors(indSeqSort(ni),:))
%     plot(tCanon+moat, tCanon*0 + Nmotifs*ni, 'r')
% end
for syli = 1:length(DesiredSegTimes)
    plot(DesiredSegTimes(syli)*ones(1,2)+moat, [.5 Nneurons+.5], 'k:')
    plot(DesiredSegTimes(syli)*ones(1,2)+moat, [.5 Nneurons+.5], 'k:')
end
shg
linkaxes(h,'x')
cmap = flipud(bone); flipud(gray); 
cmap(1,:) = ones(1,3); colormap(cmap); shg
set(gca,'color','none','tickdir','out','ticklength', [0.01, 0.01])

% imagesc(squeeze(median(ByMotif,2)))
% decide how to sort
% colormap(flipud(gray))
axis tight
figure; hold all
imagesc(reshape(sum(neuron.A,2),300,400), [0 max(neuron.A(:))]); colormap gray
for ni = 1:Nneurons
    tmp = reshape(neuron.A(:,indSeqSort(ni)),300,400);
    [C,hh] = contour(tmp,1, 'color',1-nColors(indSeqSort(ni),:));
    text(mean(C(1,:)), mean(C(2,:)), num2str(indSeqSort(ni)),'color',1-nColors(indSeqSort(ni),:), ...
       'verticalalignment', 'middle',...
        'horizontalalignment', 'center')
end
% clear all; close all; clc
set(gca, 'ydir', 'reverse')
axis image; axis off
% %% 
% binned_data = {};
% binned_labels.warpedtime = {}; 
% shifts = -15:15; 
% binned_site_info.binning_parameters.the_bin_start_times = shifts/upFac/VIDEOfs;
% binned_site_info.binning_parameters.bin_width =  1/upFac/VIDEOfs;
% binned_site_info.binning_parameters.sampling_interval =  1/upFac/VIDEOfs;
% for neuroni = 1:size(ByMotif,1)
%     binned_data{neuroni} = []; 
%     for shifti = 1:length(shifts)
%         tind = mod((1:size(ByMotif,3))+shifts(shifti),size(ByMotif,3)); 
%         tind(tind==0)=1;
%         tmp = squeeze(ByMotif(neuroni,:,tind));
%         tmp(1:(-shifts(shifti)+1),:) = 0; 
%         tmp(end:-1:(end-shifts(shifti)),:) = 0; 
%         binned_data{neuroni} = [binned_data{neuroni} tmp(:)]; 
%     end
%     tmp = repmat(tCanon,size(ByMotif,2),1);
%     binned_labels.warpedtime{neuroni} = tmp(:); 
% end
% 
% save('C:\Users\emackev\Documents\MATLAB\code\misc_elm\tmp.mat', 'binned_data', 'binned_labels', 'binned_site_info')
%% decoding
% use pretty small 'moat' and 'upFac'
% compile training set using ByMotif
% [Nneurons,TotalDur] = size(neuron.C);
% Nmotifs = length(mstart); 
% Tmotif = length(tCanon); 
% ByMotif = zeros(Nneurons,Nmotifs,Tmotif);
clf
NormByMotif = ByMotif; %bsxfun(@rdivide, ByMotif, mean(ByMotif,1)); 
% NormByMotif = zscore(ByMotif,1); 
Canon = cdfscore(squeeze(median(NormByMotif,2))); imagesc(Canon(indSeqSort,:))
% Canon = squeeze(median(NormByMotif,2));
TimeGuesses = zeros(Nmotifs,Tmotif);
for mi = 1:Nmotifs
    for ti = 1:Tmotif
        
        [~,tmp] = max(squeeze(NormByMotif(:,mi,ti))'*Canon);
        TimeGuesses(mi,ti) = tCanon(tmp);
    end
end
plot(tCanon,TimeGuesses'+.01*rand(Nmotifs,Tmotif)', '.')
xlabel('actual warped time (s)'); ylabel('decoded warped time (s)');shg
hold on
for syli = 1:length(DesiredSegTimes)
    plot(DesiredSegTimes(syli)*ones(1,2), [tCanon(1) tCanon(end)], 'k:')
    plot(DesiredSegTimes(syli)*ones(1,2), [tCanon(1) tCanon(end)], 'k:')
    plot( [tCanon(1) tCanon(end)],DesiredSegTimes(syli)*ones(1,2), 'k:')
    plot( [tCanon(1) tCanon(end)],DesiredSegTimes(syli)*ones(1,2), 'k:')
end
axis tight
% we will use object identity labels to decode which object was shown (disregarding the position of the object)
% specific_binned_labels_names = 'warpedtime';
% num_cv_splits = 20; 
% ds = basic_DS('C:\Users\emackev\Documents\MATLAB\code\misc_elm\tmp.mat', specific_binned_labels_names,  num_cv_splits);
% the_classifier = max_correlation_coefficient_CL;%the_classifier = libsvm_CL;
% the_cross_validator = standard_resample_CV(ds, the_classifier);%, the_feature_preprocessors);  
% the_cross_validator.num_resample_runs = 2;  % usually more than 2 resample runs are used to get more accurate results, but to save time we are using a small number here
% DECODING_RESULTS = the_cross_validator.run_cv_decoding; 
% save_file_name = 'C:\Users\emackev\Documents\MATLAB\code\misc_elm\tmp1.mat';
% save(save_file_name, 'DECODING_RESULTS'); 
% result_names{1} = save_file_name;
% 
% % create an object to plot the results
% plot_obj = plot_standard_results_object(result_names);
% 
% % put a line at the time when the stimulus was shown
% plot_obj.significant_event_times = 0;  
% plot_obj.plot_results;   % actually plot the results

% do decoding! 
% compare decoding accuracy for different time lags
% at good time lag, visualize decoding throughout undirected song (and sleep??)
%% finding broken motifs, plotting in same order
VIDEOfs = 20; 
SOUNDfs = 40000; 
stepdur = 180;

% if doing sleep
load('C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct21\cnmfe_results_sleep', 'Csleep')
PlotC = Csleep;

% if doing awake
% PlotC = neuron.C; 


PlotC(:,(diff([0; FnumBnum(:,1)])~=0)|(diff([0; FnumBnum(:,1)])~=0)) = nan; 

% for decoding
PlotC = bsxfun(@rdivide, PlotC, mean(PlotC,1)); 
% NormByMotif = zscore(ByMotif,1); 
Canon = cdfscore(squeeze(mean(NormByMotif,2))); imagesc(Canon(indSeqSort,:))
TimeGuesses = zeros(Tmotif,size(PlotC,2));
for ti = 1:size(PlotC,2)
%     [~,tmp] = max(PlotC(:,ti)'*Canon);
%     TimeGuesses(:,ti) = -sum((repmat(PlotC(:,ti),1,Tmotif) - Canon).^2./...
%         repmat(squeeze(std(std(ByMotif+randn(Nneurons,Nmotifs,Tmotif),[],2),[],3)),1,Tmotif)); %./squeeze(std(ByMotif+10*randn(Nneurons,Nmotifs,Tmotif),[],2).^2),1);
    TimeGuesses(:,ti) = (PlotC(:,ti)'*Canon)'; %tCanon(tmp);
    
end
for istart = 1:stepdur/2:size(PlotC,2)
    shg; clf; 
    
   
    
    h(3) = subplot('position', [.1 .7 .8 .15]);
    imagesc(TimeGuesses(:,istart:istart+stepdur-1), 'xdata', (1:stepdur)/VIDEOfs, 'ydata', tCanon); ylim([tCanon(1) tCanon(end)])
    set(gca, 'ydir', 'reverse'); ylabel('decoded time (s)')
    
    % if doing song
%     sampsong = CompSoundSONG(istart*SOUNDfs/VIDEOfs:(istart+stepdur)*SOUNDfs/VIDEOfs); 
%     h(1) = subplot('position', [.1 .85 .8 .05]);
%     spectrogramELM(sampsong, SOUNDfs, .002, 1); title(num2str(istart)); 
%     SegsInFrame = (segs(segs(:,2)>istart*SOUNDfs/VIDEOfs &...
%         segs(:,1)<(istart+stepdur)*SOUNDfs/VIDEOfs,:) - istart*SOUNDfs/VIDEOfs)/SOUNDfs;
%     hold on
%     for syli = 1:size(SegsInFrame,1)
%         patch([SegsInFrame(syli,1) SegsInFrame(syli,2) SegsInFrame(syli,2) SegsInFrame(syli,1)],...
%             [6 6 6.5 6.5], 'k')
%     end
%     
    axis off
    h(2) = subplot('position', [.1 .1 .8 .6]);hold on
    tmp = PlotC(indSeqSort,istart:istart+stepdur-1); tmp(tmp>prctile(ByMotif(:),satPrc)) = prctile(ByMotif(:),satPrc);
    ColoredC = cat(3,...
        PlotC(indSeqSort,istart:istart+stepdur-1).*repmat(nColors(:,1),1,stepdur),...
        PlotC(indSeqSort,istart:istart+stepdur-1).*repmat(nColors(:,2),1,stepdur),...
        PlotC(indSeqSort,istart:istart+stepdur-1).*repmat(nColors(:,3),1,stepdur));
    image(1-ColoredC/max(ColoredAllMotifs(:)), 'xdata', (1:stepdur)/VIDEOfs); 
    colormap(flipud(gray))
    set(gca, 'ydir', 'reverse'); ylabel('neuron')
    xlabel('Time (s)')
    linkaxes(h,'x'); axis tight
    drawnow; pause; 

end
%%
%% video
% 
% neuron.A = [];
% Ybg = neuron.localBG(Y); 
% Ysignal = Y-reshape(Ybg,300,400,size(Ybg,2)); 
% CompVidSONG = permute(Ysignal,[3 1 2]); % back sub
% ShowCaVid(CompVidSONG,CompSoundSONG,CompSpecSONG, [], [], 0)
% save(fullfile(dbasepath, 'compiled'), 'Y', 'CompVidSONG', 'CompSoundSONG', 'CompSpecSONG', 'FnumBnum', 'segs', 'Labels',...
%        '-v7.3');

dbasepath = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct21\Undirected1'; 
load(fullfile(dbasepath, 'compiled'), 'CompVidSONG', 'CompSoundSONG', 'CompSpecSONG');
ShowCaVid(CompVidSONG,CompSoundSONG,CompSpecSONG, [], [], 0)

% ShowCaVid(VIDEObs,SOUND,SPEC,[] ,params,showcontour)%, fullfile(savedir, 'tmp.avi'))
HandpickROIs(CompVidSONG,CompSoundSONG,CompSpecSONG, [] , params,showcontour)%, fullfile(savedir, 'tmp.avi'))


   