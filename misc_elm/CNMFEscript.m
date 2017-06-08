function CNMFEscript()
% dataName = 'C:\Users\emackev\Documents\ForOpenMind\ForOm\analysisIn\compiled_moco.mat';
% saveName = 'C:\Users\emackev\Documents\ForOpenMind\ForOm\analysisOut\cnmfe_results_moco.mat';
% codedir = 'C:\Users\emackev\Documents\ForOpenMind\ForHome\codedump';

% to get data and code files onto openmind and back
% scp -rp /home/emackev/MyDocuments/ForOpenMind/ForOm/* elm@openmind7.mit.edu:/om/user/elm
% scp -rp /home/emackev/MyDocuments/ForOpenMind/ForHome/* elm@openmind7.mit.edu:/home/elm
% scp elm@openmind7.mit.edu:/om/user/elm/analysisOut/cnmfe_results_moco.mat /home/mobaxterm/MyDocuments/ForOpenMind/

% To mount feevault on openmind:
% mkdir feevault
% sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 elm@feevault.mit.edu:/data0/elm ~/feevault/
% see: https://serverfault.com/questions/6709/sshfs-mount-that-survives-disconnect

% need to label data using electrogui, put analysis file and data files into om
%% compile data
% display('Testing 1')

moat = 1; 
% SaveFolder = '/om/user/elm/analysisOut'
% DataFolder = '/home/elm/feevault/ProcessedCalciumData/6992_FirstTutNewSyll'; %'/home/elm/feevault/ProcessedCalciumData/6938_FirstTutNewSyll'; /home/elm/feevault/
SaveFolder = 'U:\ProcessedCalciumData\6992_FirstTutNewSyll'
DataFolder = 'U:\ProcessedCalciumData\6992_FirstTutNewSyll'; %'/home/elm/feevault/ProcessedCalciumData/6938_FirstTutNewSyll'; /home/elm/feevault/

dataName = fullfile(DataFolder, 'compiled.mat');
saveName = fullfile(SaveFolder, 'cnmfe_results.mat');

codedir = '/home/elm/codedump'; 
% set up
addpath(genpath(codedir))

% compile, if necessary
analysis2compiled(DataFolder, SaveFolder, moat)

%% cnmfe stuff
almostnothing = []; 
save(fullfile(SaveFolder, ...
   ['AboutToStartCNMFE' 'stamp.mat']), ...
   'almostnothing'); 

load(dataName, 'VIDEOfs')

global  d1 d2 numFrame ssub tsub sframe num2read Fs neuron neuron_ds ...
    neuron_full Ybg_weights nam; %#ok<NUSED> % global variables, don't change them manually

nam = dataName;
cnmfe_choose_data;

almostnothing = []; 
save(fullfile(SaveFolder, ...
   ['chosedata' 'stamp.mat']), ...
   'almostnothing'); 

% create Source2D class object for storing results and parameters
Fs = VIDEOfs;       % frame rate
ssub = 1;           % spatial downsampling factor
tsub = 1;           % temporal downsampling factor
gSig = 15;          % width of the gaussian kernel, which can approximates the average neuron shape
gSiz = 25;          % usally do 25... doing 50 for bigger neurons% maximum diameter of neurons in the image plane. larger values are preferred.
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

almostnothing = []; 
save(fullfile(SaveFolder, ...
   ['loadeddata' 'stamp.mat']), ...
   'almostnothing'); 

Y = neuron.reshape(Y, 1);       % convert a 3D video into a 2D matrix

% compute correlation image and peak-to-noise ratio image.
% cnmfe_show_corr_pnr;    % this step is not necessary, but it can give you some...
%                         % hints on parameter selection, e.g., min_corr & min_pnr

% initialization of A, C
% parameters
debug_on = false;
save_avi = false;
patch_par = [1,1]*10; %1;  % divide the optical field into m X n patches and do initialization patch by patch
K = [20]; % maximum number of neurons to search within each patch. you can use [] to search the number automatically

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

almostnothing = []; 
save(fullfile(SaveFolder, ...
   ['initialized' 'stamp.mat']), ...
   'almostnothing'); 

% show results
% figure;
% imagesc(Cn);
% hold on; plot(center(:, 2), center(:, 1), 'or');
% colormap; axis off tight equal;

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

almostnothing = []; 
save(fullfile(SaveFolder, ...
   ['estimatedbg' 'stamp.mat']), ...
   'almostnothing'); 

% parameters, estimate the spatial components
max_overlap = 20;       % maximum number of neurons overlaping at one pixel 

% parameters, estimate the temporal components
smin = 5;       % thresholding the amplitude of the spike counts as smin*noise level

neuron.options.maxIter = 2;   % iterations to update C

% parameters for running iteratiosn 
nC = size(neuron.C, 1);    % number of neurons 

maxIter = 2;        % maximum number of iterations 
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
    neuron.options.max_timesteps=1000;
    cnmfe_update_BG;
    fprintf('Time cost in estimating the background:        %.2f seconds\n', toc);
    % neuron.playMovie(Ysignal); % play the video data after subtracting the background components.
    
    % update spatial & temporal components
    tic;
    for m=1:2    
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
    almostnothing = []; 
    save(fullfile(SaveFolder, ...
       ['updatedspattemp' 'stamp.mat']), ...
       'almostnothing'); 
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
almostnothing = []; 
save(fullfile(SaveFolder, ...
   ['abouttosave' 'stamp.mat']), ...
   'almostnothing'); 
try 
save(saveName, 'neuron', ...
    '-v7.3')
catch
save('/om/user/elm/analysisOut', 'neuron', ...
    '-v7.3')
end
end