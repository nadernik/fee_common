datadir = 'c:\stetner\data\sparsenet\';
conditions = {'yesltd_yesinhib'
              'yesltd_noinhib'
              'noltd_yesinhib'
              'noltd_noinhib'};

%% Run simulations
for ic = 1:length(conditions)
    clear sn
    
    %% Create the network
    switch conditions{ic}
        case 'yesltd_yesinhib'
            sn = SparseNet();
        case 'yesltd_noinhib'
            sn = SparseNet_noinhib();
        case 'noltd_yesinhib'
            sn = SparseNet_noltd();
        case 'noltd_noinhib'
            sn = SparseNet_noltd_noinhib();
        otherwise
            error('Unknown condition')
    end
    
    %% Set parameters
    sn.nhvc = 100;
    sn.nmsn = 100;
    sn.niter = 1000;
    
    sn.hvcburstlen = 3;
    sn.kernelstd = 1/8;
    
    % Choose maximum template value = 1.
    template = 0.5 * sin(linspace(0,2*pi,sn.nhvc)) + 0.5;
    
    sn.lmanstd    = 0.25 * max(template);
    sn.lmanoffset = 2    * sn.lmanstd;
    sn.winit      = 1    * sn.lmanstd;
    sn.msnthresh  = 1    * sn.winit; % MSN threshold
    sn.wLstd      = 0.2; %standard deviation of LMAN weights
    sn.istr       = sn.lmanoffset + 2 * sn.lmanstd;
    
    sn.LTPrate = 1e-1;
    sn.LTDrate = 5e-2;
    
    sn.init()
    sn.template = template;
    
    %% Run
    sn.simulate()
    
    %% Save
    save(fullfile(datadir, conditions{ic}));
end        

%% Plot results
for ic = 1:length(conditions)
    clear sn
    figure
    load(fullfile(datadir, conditions{ic}))
    
    subplot(1,3,1)
    sn.wimage(sn.niter)
    
    subplot(1,3,2)
    sn.plotbiasvstemplate(sn.niter)
    title(conditions{ic})
    
    subplot(1,3,3)
    sn.plotmse()
end 