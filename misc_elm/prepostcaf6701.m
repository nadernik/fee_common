% 6701 prepost caf montage Nov 18 & 21 (precaf), Nov 29 & 30 (postcaf)

dbasepath = 'E:\ProcessedCalciumData\6701_prepostcaf'; 

load(fullfile(dbasepath, 'analysis.mat')); 
Y = [];
CompSoundSONG = [];
CompSpecSONG = [];
segs = []; 
FnumBnum = []; 
Labels = {};
moat = 3; 
save(fullfile(dbasepath, 'compiled'), 'Y', 'CompSoundSONG', 'CompSpecSONG',...
   '-v7.3')
ForMOCO = zeros(0,300,400);
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
                FnumBnum = [FnumBnum; repmat([filei bi filei<=7],length(useframes),1)];
                display(['SONG file ' num2str(filei) ' bout ' num2str(bi)])
            end
            ForMOCO(end+1,:,:) = squeeze(max(VIDEO(useframes,:,:),[],1)); 
        end
    end
    save(fullfile(dbasepath, 'compiled'), 'ForMOCO','Y', 'CompSoundSONG', 'CompSpecSONG', 'FnumBnum', 'segs', 'Labels', 'VIDEOfs',...
       '-v7.3'); % also saved background subtracted CompVidSONG
end
CompVidSONG = permute(Y,[3 1 2]); % back sub
save(fullfile(dbasepath, 'compiled'), 'ForMOCO','Y', 'CompVidSONG', 'CompSoundSONG', 'CompSpecSONG', 'FnumBnum', 'segs', 'Labels', 'VIDEOfs', ...
       '-v7.3'); % also saved CompVidSONG
% ShowCaVid(CompVidSONG,CompSoundSONG,CompSpecSONG, [], [], 0)

%% save video
clear all
dbasepath = 'E:\ProcessedCalciumData\6701_prepostcaf';
load(fullfile(dbasepath, 'compiled_moco'))
% CompVidSONG = permute(Y,[3 1 2]);
ShowCaVid(CompVidSONG(1:5771,:,:),CompSoundSONG,CompSpecSONG(1:5771,:,:),[],[],0);% 'E:\ProcessedCalciumData\6701_prepostcaf\compiled_moco_vid.avi', [], 0)
%% save highpass filter video
% clearvars -except CompVidSONG CompSoundSONG CompSpecSONG
% for k = 2:size(CompVidSONG,1)
%     A = squeeze(CompVidSONG(k,:,:));
%     A = abs(A-imgaussfilt(A,15));
% end

%% save tiff
load(fullfile(dbasepath, 'compiled'), 'ForMOCO')

V = ForMOCO;
A = squeeze(V(1,:,:));
A = abs(A-imgaussfilt(A,15));
imwrite(A/max(A(:)), fullfile(dbasepath, 'compiledForMOCO.tif'))
for k = 2:size(V,1)
    A = squeeze(V(k,:,:));
    A = abs(A-imgaussfilt(A,15));
    imwrite(A/max(A(:)), fullfile(dbasepath, 'compiledForMOCO.tif'), 'writemode', 'append');
end

%%
clear all
dbasepath = 'E:\ProcessedCalciumData\6701_prepostcaf';
load(fullfile(dbasepath, 'compiled'), 'ForMOCO', 'FnumBnum')
[tmp,~,~] = unique(FnumBnum, 'rows')
pre = squeeze(max(ForMOCO(tmp(:,3)==1,:,:),[],1));
post = squeeze(max(ForMOCO(tmp(:,3)==0,:,:),[],1));
imshowpair(pre,post);shg
%% motion correct 

%get corrections from imagej
% dbasepath = 'E:\ProcessedCalciumData\6701_prepostcaf';
% load(fullfile(dbasepath, 'compiled'))
% tmp = importdata('E:\ProcessedCalciumData\6701_prepostcaf\MocoFromEndResults.csv');
% MOCO2 = tmp.data(:,2:3); 
% tmp = importdata('E:\ProcessedCalciumData\6701_prepostcaf\MocoFromStartResults.csv');
% MOCO1 = tmp.data(:,2:3); 
% MOCO = round((MOCO1+MOCO2)/2);
% clf; plot(MOCO);shg

% moco by hand
load(fullfile(dbasepath, 'compiled'));%, 'ForMOCO', 'FnumBnum')
[tmp,~,~] = unique(FnumBnum, 'rows')
pre = squeeze(max(ForMOCO(tmp(:,3)==1,:,:),[],1));
post = squeeze(max(ForMOCO(tmp(:,3)==0,:,:),[],1));
imshowpair(pre,post);shg
MOCO = tmp(:,3)*[-23 4]; 



[~,~,mocoBnum] = unique(FnumBnum,'rows');
MocoVid = zeros(size(CompVidSONG));
Ymoco = zeros(size(Y)); 
[t,y,x] = size(CompVidSONG);
for fi = 1:size(CompVidSONG,1)
    indnewx = max(1,1+MOCO(mocoBnum(fi),1)):min(x,x+MOCO(mocoBnum(fi),1));
    indoldx = max(1,1-MOCO(mocoBnum(fi),1)):min(x,x-MOCO(mocoBnum(fi),1));
    indnewy = max(1,1+MOCO(mocoBnum(fi),2)):min(y,y+MOCO(mocoBnum(fi),2));
    indoldy = max(1,1-MOCO(mocoBnum(fi),2)):min(y,y-MOCO(mocoBnum(fi),2));
    MocoVid(fi,indnewy,indnewx) = CompVidSONG(fi,indoldy,indoldx); 
    Ymoco(indnewy,indnewx,fi) = CompVidSONG(fi,indoldy,indoldx); 
end


% ShowCaVid(MocoVid,CompSoundSONG,CompSpecSONG, [], [], 0)
save(fullfile(dbasepath, 'compiled'), 'ForMOCO','Y', 'CompVidSONG', 'CompSoundSONG', 'CompSpecSONG', 'FnumBnum', 'segs', 'Labels', 'VIDEOfs', ...
       'MocoVid', 'Ymoco', ...
       '-v7.3');
Y = Ymoco; 
CompVidSONG = permute(Y,[3 1 2]);
save(fullfile(dbasepath, 'compiled_moco'), 'Y', 'CompVidSONG', 'CompSoundSONG', 'CompSpecSONG', 'FnumBnum', 'segs', 'Labels', 'VIDEOfs', ...
   '-v7.3');
%% look at alignment

% [tmp,~,~] = unique(FnumBnum, 'rows')
% pre = squeeze(max(Y(:,:,tmp(:,3)==1),[],3)); pre = abs(pre-imgaussfilt(pre,15));
% post = squeeze(max(Y(:,:,tmp(:,3)==0),[],3)); post = abs(post-imgaussfilt(post,15));
% imshowpair(pre,post);shg

%% make separate ones for pre and post
% pre
clearvars -except dbasepath
load(fullfile(dbasepath, 'compiled'));
ind = find(FnumBnum(:,3));
Y = Y(:,:,ind);
FnumBnum = FnumBnum(ind,:);
segs = segs-ind(1)+1;
Labels = Labels;
save(fullfile(dbasepath, 'compiled_pre'), 'Y', 'FnumBnum', 'segs', 'Labels', 'VIDEOfs', ...
   '-v7.3');
'...'
% post
clearvars -except dbasepath
load(fullfile(dbasepath, 'compiled'));
ind = find(~FnumBnum(:,3));
Y = Y(:,:,ind);
FnumBnum = FnumBnum(ind,:);
segs = segs-ind(1)*40000/VIDEOfs+1
Labels = Labels;
save(fullfile(dbasepath, 'compiled_post'), 'Y', 'FnumBnum', 'segs', 'Labels', 'VIDEOfs', ...
   '-v7.3');
%% CNMFE
close all; clearvars -except VIDEOfs
dbasepath = 'E:\ProcessedCalciumData\6701_prepostcaf'; 

saveherecnmfe = 'E:\ProcessedCalciumData\6701_prepostcaf\cnmferesults_moco'
global  d1 d2 numFrame ssub tsub sframe num2read Fs neuron neuron_ds ...
    neuron_full Ybg_weights nam; %#ok<NUSED> % global variables, don't change them manually
nam = fullfile(dbasepath, 'compiled_moco'); %'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6701_Nov16'; 
cnmfe_choose_data;
% create Source2D class object for storing results and parameters
Fs = VIDEOfs;       % frame rate
ssub = 1;           % spatial downsampling factor
tsub = 1;           % temporal downsampling factor
gSig = 15;           % width of the gaussian kernel, which can approximates the average neuron shape
gSiz = 25;          % maximum diameter of neurons in the image plane. larger values are preferred.
neuron_full = Sources2D('d1',d1,'d2',d2, ... % dimensions of datasets
    'ssub', ssub, 'tsub', tsub, ...  % downsampleing
    'gSig', gSig,...
    'gSiz', gSiz, ...
    'merge_thr', 0.5) ;
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
%% plot raster
clear all; close all
% dbasepath = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct18\Undirected1'; 
% saveherecnmfe = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct18\Undirected1\cnmferesults'; 
% dbasepath = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct21\Undirected1'; 
% saveherecnmfe = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct21\Undirected1\cnmferesults'; 
% dbasepath = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6701_Nov16'; 
% saveherecnmfe = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6701_Nov16\cnmferesults'; 
dbasepath = 'E:\ProcessedCalciumData\6701_prepostcaf'; 
saveherecnmfe = 'C:\Users\emackev\Documents\ForOpenMind\cnmfe_results_moco';
soundshift =  0; %1826*40000/30;
load(saveherecnmfe, 'neuron'); 
load(fullfile(dbasepath, 'compiled_moco.mat'), 'Labels', 'segs', 'VIDEOfs', 'CompSoundSONG');

% Ybg = neuron.localBG(Y); 
% Ysignal = reshape(Y,120000,size(Y,3))-Ybg; 
% neuron.downSample(Ysignal);
% neuron.C = (neuron.A'*neuron.A)\(neuron.A'*Ysignal); 
% neuron.updateTemporal_endoscope(Ysignal); 

% find full motifs
LabelCanon = {'A' 'B' 'C' 'D' 'E'}; 
SOUNDfs = 40000; 
% VIDEOfs = 20; 
moat = 1; 
mstart = []; 
msegs = zeros(length(LabelCanon),2,0); 
params.WantTheseLabels = LabelCanon;
for li = 1:length(Labels)-length(LabelCanon)
    params.Method = 'labels'; 
    params.CheckTheseLabels = Labels(li:li+length(LabelCanon)-1); 
    if MotifCheck(params) & (segs(li,1)/40000-moat)*VIDEOfs> 0 & (segs(li,2)/40000+moat)*VIDEOfs<size(neuron.C,2)
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
upFac = 30/5; 
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
        if length(tIndUnwarped)>0
            ByMotif(ni,mi,:) = spline((tIndUnwarped/VIDEOfs/upFac-segs(mstart(mi),1)/SOUNDfs), Unwarped(ni,:),DesUnwarpedTimes);
        end
    end
    if mi == 2
        sampsong = CompSoundSONG(floor(soundshift+(tIndUnwarped(1)*SOUNDfs/VIDEOfs/upFac:tIndUnwarped(end)*SOUNDfs/VIDEOfs/upFac))); 
    end
%     clf; subplot(4,1,1); displaySpecgramQuick(CompSoundSONG(tIndUnwarped(1)*SOUNDfs/VIDEOfs/upFac:tIndUnwarped(end)*SOUNDfs/VIDEOfs/upFac), SOUNDfs)
%     subplot(4,1,2:4); imagesc(squeeze(ByMotif(:,mi,:))); colormap(flipud(gray)); pause
    %     ByMotif(:,mi,:) = neuron.C(:,
end
% imagesc reshaped matrix, and/or average matrix
% GravCent = bsxfun(@rdivide, sum(squeeze(median(ByMotif,2)).*repmat(tCanon,Nneurons,1),2),...
%     sum(squeeze(median(ByMotif,2)),2)); 
% [~,ind] = sort(GravCent);

% exclude bad (noisy) motifs
% exclude bad (non song-locked) neurons
% figure
I = [];
mproj = reshape(sum(neuron.A,2),300,400); imagesc(mproj)
clf
for ni = 1:size(ByMotif,1)
%     plot(squeeze(sum(ByMotif(ni,:,:),2)), ); hold on
%     psth = squeeze(mean(ByMotif(ni,:,:),2));
%     I(ni) = anova1(squeeze(ByMotif(ni,:,:)),[],'off'); %(max(psth)-median(psth))/max(psth); 
%     I(ni) = sum(ByMotif(ni,:));
    subplot(2,1,1); imagesc(mproj); hold on; contour(reshape(neuron.A(:,ni),300,400), 'r'); colormap(flipud(gray))
    subplot(2,1,2); 
    imagesc(squeeze(ByMotif(ni,:,:)), [0 max(squeeze(ByMotif(ni,:)))]); hold on
%     colormap(flipud(gray)); clf
    shg
    I(ni) = input('Keep this neuron? 1 or 0');
end
% save(fullfile(dbasepath, 'selectedneurons'), 'I');

[~,tmax] = max(squeeze(median(ByMotif(:,:,tCanon>-.05&tCanon<(tCanon(end)-moat)),2)),[],2);
[~,indSeqSort] = sort(tmax); 
indSeqSort(I<.5) = []; Nneurons = length(indSeqSort);
neuron.C = neuron.C(indSeqSort,:); 
neuron.A = neuron.A(:,indSeqSort); 
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
% AllMotifs(AllMotifs<0) = 0; 
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
set(gcf, 'papersize', [8.5 11], 'paperposition', [0 0 8.5 11])
tmp = sum(AllMotifs,1); tmp = tmp-min(tmp); tmp = tmp/max(tmp)*6; 
subplot(h(1)); hold on; plot(tCanon+moat,tmp, 'r')
% imagesc(squeeze(median(ByMotif,2)))
% decide how to sort
% colormap(flipud(gray))
axis tight
figure; hold all
imagesc(reshape(sum(neuron.A,2),300,400), [0 max(neuron.A(:))]); colormap gray
for ni = 1:Nneurons
    tmp = reshape(neuron.A(:,(ni)),300,400);
    [C,hh] = contour(tmp,1, 'color',1-nColors((ni),:));
    text(mean(C(1,:)), mean(C(2,:)), num2str((ni)),'color',1-nColors((ni),:), ...
       'verticalalignment', 'middle',...
        'horizontalalignment', 'center')
end
% clear all; close all; clc
set(gca, 'ydir', 'reverse')
axis image; axis off