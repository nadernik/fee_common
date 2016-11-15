function neuron = CNMFEForParamSweep(params)
nam = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\6719_Oct21\Undirected1\compiled.mat'; 
cnmfe_choose_data;
% create Source2D class object for storing results and parameters
Fs = 20;             % frame rate
ssub = 1;           % spatial downsampling factor
tsub = 1;           % temporal downsampling factor
gSig = params.gSig;           % width of the gaussian kernel, which can approximates the average neuron shape
gSiz = params.gSiz;          % maximum diameter of neurons in the image plane. larger values are preferred.
neuron_full = Sources2D('d1',d1,'d2',d2, ... % dimensions of datasets
    'ssub', ssub, 'tsub', tsub, ...  % downsampleing
    'gSig', gSig,...
    'gSiz', gSiz, ...
    'merge_thr', 0.5);
neuron_full.Fs = Fs;         % frame rate

% with dendrites or not 

% determine the search locations by dilating the current neuron shapes
neuron_full.options.search_method = 'dilate'; 
neuron_full.options.bSiz = 20;

% create convolution kernel to model the shape of calcium transients
tau_decay = 1;  %
tau_rise = 0.1;
nframe_decay = ceil(10*tau_decay*neuron_full.Fs);  % number of frames in decaying period
bound_pars = false;     % bound tau_decay/tau_rise or not
neuron_full.kernel = create_kernel('exp2', [tau_decay, tau_rise]*neuron_full.Fs, nframe_decay, [], [], bound_pars);

% downsample data for fast and better initialization
sframe=params.sframe;						% user input: first frame to read (optional, default:1)
num2read= params.numFrame;             % user input: how many frames to read   (optional, default: until the end)

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
K = []; % maximum number of neurons to search within each patch. you can use [] to search the number automatically

min_corr = params.min_corr;     % minimum local correlation for a seeding pixel
min_pnr = params.min_pnr;       % minimum peak-to-noise ratio for a seeding pixel
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