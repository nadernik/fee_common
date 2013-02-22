classdef SparseNetFig < Fig

    properties
        fname
        axh
        color
        bins
    end
    
    methods
        function obj = SparseNetFig()
            obj.h = figure;
            obj.datadir = 'c:\stetner\data\sparsenet\';
            obj.fname.yesltd_yesinhib = 'yesltd_yesinhib.mat';
            obj.fname.yesltd_noinhib  = 'yesltd_noinhib.mat';
            obj.fname.noltd_yesinhib  = 'noltd_yesinhib.mat';
            obj.fname.noltd_noinhib   = 'noltd_noinhib.mat';
            
            % Colors for lines
            obj.color.template        = [0.5, 0.5, 0.5];
            obj.color.yesltd_yesinhib = [1  , 0  , 0  ];
            obj.color.yesltd_noinhib  = [0  , 0.5, 0  ];
            obj.color.noltd_yesinhib  = [0  , 0  , 1  ];
            obj.color.noltd_noinhib   = [0  , 0  , 0  ];
            
            % all axes handles
            obj.axh = nan(5);
            
            % bins for histograms of selectivity and sparseness
            obj.bins = linspace(0,1,20);
        end
        
        function compute(obj)
            obj.compute_yesltd_yesinhib();
            obj.compute_yesltd_noinhib();
            obj.compute_noltd_yesinhib();
            obj.compute_noltd_noinhib();            
        end
        
        function compute_yesltd_yesinhib(obj)
            sn = mySparseNet();
            sn.init();
            sn.simulate();
            filename = fullfile(obj.datadir, obj.fname.yesltd_yesinhib);
            save(filename, 'sn')
        end
        
        function compute_yesltd_noinhib(obj)
            sn = mySparseNet();
            sn.latinhib = 0; % turn off inhibition
            sn.init();
            sn.simulate();
            filename = fullfile(obj.datadir, obj.fname.yesltd_noinhib);
            save(filename, 'sn')
        end
        
        function compute_noltd_yesinhib(obj)
            sn = mySparseNet();
            sn.LTDrate = 0; % turn off long term depression
            sn.init();
            sn.simulate();
            filename = fullfile(obj.datadir, obj.fname.noltd_yesinhib);
            save(filename, 'sn')
        end
        
        function compute_noltd_noinhib(obj)
            sn = mySparseNet();
            sn.latinhib = 0; % turn off inhibition
            sn.LTDrate = 0; % turn off long term depression
            sn.init();
            sn.simulate();
            filename = fullfile(obj.datadir, obj.fname.noltd_noinhib);
            save(filename, 'sn')
        end
        
        function sn = mySparseNet()
            sn = SparseNet;
            sn.nhvc  =  100;
            sn.nmsn  =  300;
            sn.niter = 5000;
            
            sn.hvcburstlen = 11; % Width of HVC burst
            sn.kernelstd   = 12; % Standard deviation of Gaussian dopamine kernel
            
            maxtemplate   = 1;   % maximum template value (this is arbitrary)
            
            % Derived parameters
            sn.lmanstd    = 0.05 * maxtemplate; % Standard deviation of LMAN noise
            sn.lmanoffset = 2    * sn.lmanstd;  % Mean of LMAN noise
            sn.winit      = 0.1  * sn.lmanstd;  % Maximum initial HVC-MSN weight
            sn.msnthresh  = 1    * sn.winit;    % Threshold for MSN output
            
            sn.latinhib = 0.0005; % FIXME how does this scale?
            sn.LTPrate  = 0.05;   % FIXME how does this scale?
            sn.LTDrate  = 2e-6;   % FIXME how does this scale?
            sn.pinhib   = 0.75;   % FIXME how does this scale?
            
            a = (maxtemplate - sn.lmanoffset);
            t1 = linspace(0, 2*pi, sn.nhvc);
            t2 = linspace(0, 4*pi, sn.nhvc);
            y = -cos(t1) - cos(t2);
            y = y - min(y);
            y = y / max(y) * a + sn.lmanoffset;
            sn.template = y;
        end
        
        function draw(obj)            
            % Yes LTD, Yes inhibition
            filename = fullfile(obj.datadir, obj.fname.yesltd_yesinhib);
            load(filename, 'sn')
            obj.axh(1,1) = subplot(5,5,1);
            sn.wimage(sn.niter);
            obj.axh(1,2) = subplot(5,5,2);
            sn.plotbiasvstemplate(sn.niter)
            p = get(gca, 'Children');
            set(p(1), 'Color', obj.color.template)
            set(p(2), 'Color', obj.color.yesltd_yesinhib)
            legend off
            obj.axh(5,1:2) = subplot(5,5,21:22);
            sn.plotmse();
            hold on
            p = get(gca, 'Children');
            set(p(1), 'Color', obj.color.yesltd_yesinhib)
            obj.axh(5,4) = subplot(5,5,24);
            obj.axh(5,4) = subplot(5,5,25);
            stairs(obj.bins, hist(selectivity(sn.msnout(:,:,end)), obj.bins), 'Color', obj.color.yesltd_yesinhib)
            hold on
            clear sn
            
            % Yes LTD, No inhibition
            filename = fullfile(obj.datadir, obj.fname.yesltd_noinhib);
            load(filename, 'sn')
            obj.axh(1,4) = subplot(5,5,4);
            sn.wimage(sn.niter);
            obj.axh(1,5) = subplot(5,5,5);
            sn.plotbiasvstemplate(sn.niter)
            p = get(gca, 'Children');
            set(p(1), 'Color', obj.color.template)
            set(p(2), 'Color', obj.color.yesltd_noinhib)
            legend off
            obj.axh(5,1:2) = subplot(5,5,21:22);
            sn.plotmse();
            p = get(gca, 'Children');
            set(p(1), 'Color', obj.color.yesltd_noinhib)
            obj.axh(5,4) = subplot(5,5,24);
            obj.axh(5,4) = subplot(5,5,25);
            stairs(obj.bins, hist(selectivity(sn.msnout(:,:,end)), obj.bins), 'Color', obj.color.yesltd_noinhib)
            clear sn
            
            % No LTD, Yes inhibition
            filename = fullfile(obj.datadir, obj.fname.noltd_yesinhib);
            load(filename, 'sn')
            obj.axh(3,1) = subplot(5,5,11);
            sn.wimage(sn.niter);
            obj.axh(3,2) = subplot(5,5,12);
            sn.plotbiasvstemplate(sn.niter)
            p = get(gca, 'Children');
            set(p(1), 'Color', obj.color.template)
            set(p(2), 'Color', obj.color.noltd_yesinhib)
            legend off
            obj.axh(5,1:2) = subplot(5,5,21:22);
            sn.plotmse();
            p = get(gca, 'Children');
            set(p(1), 'Color', obj.color.noltd_yesinhib)
            obj.axh(5,4) = subplot(5,5,24);
            obj.axh(5,4) = subplot(5,5,25);
            stairs(obj.bins, hist(selectivity(sn.msnout(:,:,end)), obj.bins), 'Color', obj.color.noltd_yesinhib)
            clear sn
            
            % No LTD, No inhibition
            filename = fullfile(obj.datadir, obj.fname.noltd_noinhib);
            load(filename, 'sn')
            obj.axh(3,4) = subplot(5,5,14);
            sn.wimage(sn.niter);
            obj.axh(3,5) = subplot(5,5,15);
            sn.plotbiasvstemplate(sn.niter)
            p = get(gca, 'Children');
            set(p(1), 'Color', obj.color.template)
            set(p(2), 'Color', obj.color.noltd_noinhib)
            legend off
            obj.axh(5,1:2) = subplot(5,5,21:22);
            sn.plotmse();
            p = get(gca, 'Children');
            set(p(1), 'Color', obj.color.noltd_noinhib)
            obj.axh(5,4) = subplot(5,5,24);
            obj.axh(5,4) = subplot(5,5,25);
            stairs(obj.bins, hist(selectivity(sn.msnout(:,:,end)), obj.bins), 'Color', obj.color.noltd_noinhib)
            clear sn
        end        
    end
end
