%% original parameter set
saveherecnmfe = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\ParamSweep\'; 
global  d1 d2 numFrame ssub tsub sframe num2read Fs neuron neuron_ds ...
    neuron_full Ybg_weights nam; %#ok<NUSED> % global variables, don't change them manually
params.gSig = 3; 
params.gSiz = 15; 
params.min_corr = 0.8; 
params.min_pnr = 9; 
params.sframe = 1; 
params.numFrame = 1200; 
neuron = CNMFEForParamSweep(params);

save(fullfile(saveherecnmfe, 'originalparams'), 'neuron', 'params',...
    '-v7.3')
%% Vary various things
saveherecnmfe = 'C:\Users\emackev\Documents\MATLAB\TEMPORARILY_DATA_STORAGE_FOR_SPEEDIER_ANALYSIS\ParamSweep\'; 

load(fullfile(saveherecnmfe, 'originalparams'), 'neuron', 'params')
oldParams = params; 
oldNeuron = neuron; 

% vary gSig
ParamNames = {'gSig' 'gSiz' 'min_corr' 'min_pnr'};
ParamVals = {[1:10] [9:2:41] [.4:.1:.9] [2:14]};

for pi = 1:length(ParamNames)
    clearvars -except oldNeuron oldParams saveherecnmfe ParamNames ParamVals pi
    paramname = ParamNames{pi}; 
    paramvals = ParamVals{pi}; 
    thisdir = fullfile(saveherecnmfe, paramname); 
    mkdir(thisdir); 
    for i = 1:length(paramvals)
        try
            params = oldParams; 
            params.(paramname) = paramvals(i); 
            neuron = CNMFEForParamSweep(params); 
            save(fullfile(thisdir, ['results_' paramname num2str(paramvals(i)) '.mat']), 'neuron', '-v7.3'); 
            display([paramname paramvals(i)]); 
            SpatCor = max(oldNeuron.A'*neuron.A,[],1);
            TempCor = max(oldNeuron.C*neuron.C',[],1); 
            [~,ind] = sort(SpatCor/mean(SpatCor) +TempCor/mean(TempCor), 'ascend'); 
            clf; 
            subplot(2,2,1:2); imshowpair(reshape(max(neuron.A,[],2),300,400),reshape(max(oldNeuron.A,[],2),300,400), 'colorchannels', [1 2 0])
            title(['new (' paramname '= ' num2str(paramvals(i)) ') in red; original in green'])
            subplot(2,2,3); imagesc(neuron.C(ind(1:15),200:500), 'xdata', (1:300)/20); title('newest units')
            subplot(2,2,4); imagesc(neuron.C(ind(end-14:end),200:500), 'xdata', (1:300)/20); title('most consistent units')
            colormap(flipud(gray))
            drawnow
            saveas(gcf, fullfile(thisdir, ['results_' paramname num2str(paramvals(i)) '.fig']))
        catch exception
        end
    end
end