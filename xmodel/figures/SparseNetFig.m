classdef SparseNetFig < Fig
    properties
    end
    
    methods
        function obj = SparseNetFig()
            obj.datadir = 'c:\stetner\data\sparsenet';
            obj.filename.not_sparse = 'notsparsenet.mat';
            obj.filename.ltd_only = 'SparseNetFigureCandidate_slow_6.mat';
            obj.filename.ltd_inhib = 'SparseNetFigureCandidate_inhib_5.mat';
            obj.h = figure;
        end
        
        function compute(obj)
            obj.compute_not_sparse()
            obj.compute_ltd_only()
            obj.compute_ltd_inhib()
        end
        
        function draw(obj)
            fname = fullfile(obj.datadir, obj.filename.not_sparse);
            load(fname, 'sn')
            subplot(3,2,2)
            sn.wimage(sn.niter)
            subplot(3,2,1)
            sn.plotbiasvstemplate(sn.niter)
            clear sn
            
            fname = fullfile(obj.datadir, obj.filename.ltd_only);
            load(fname, 'sn')
            subplot(3,2,4)
            sn.wimage(sn.niter)
            subplot(3,2,3)
            sn.plotbiasvstemplate(sn.niter)
            clear sn
            
            fname = fullfile(obj.datadir, obj.filename.ltd_inhib);
            load(fname, 'sn')
            subplot(3,2,6)
            sn.wimage(sn.niter)
            subplot(3,2,5)
            sn.plotbiasvstemplate(sn.niter)
            clear sn
        end
        
        function compute_not_sparse(obj)
            sn = NotSparseNet();

            sn.nhvc  =  100;
            sn.nmsn  =  300;
            sn.niter = 5000;

            % Parameters
            sn.hvcburstlen = 11; % Width of HVC burst
            sn.kernelstd   = 12; % Standard deviation of Gaussian dopamine kernel
            maxtemplate   = 1;   % maximum template value (this is arbitrary)
            sn.lmanstd    = 0.05 * maxtemplate; % Standard deviation of LMAN noise
            sn.lmanoffset = 2    * sn.lmanstd;  % Mean of LMAN noise
            sn.LTPrate  = 2e-3;

            % Template
            a = (maxtemplate - sn.lmanoffset);
            t1 = linspace(0, 2*pi, sn.nhvc);
            t2 = linspace(0, 4*pi, sn.nhvc);
            y = -cos(t1) - cos(t2);
            y = y - min(y);
            y = y / max(y) * a + sn.lmanoffset;
            sn.template = y;

            sn.init()
            sn.simulate()
            filename = fullfile(obj.datadir, obj.filename.notsparse);
            save(filename, 'sn')
        end
        
        function compute_ltd_only(obj)
            % Run the simulation ten times so later we can pick the one
            % that looks best!
            % WARNING!!! THIS TAKES A VERY LONG TIME! Each 10,000 trial
            % simulation takes about 30 mins, so total takes about 5 hours.
            sn = SparseNet2();

            sn.nhvc  =  100;
            sn.nmsn  =  300;
            sn.niter = 10000;
            
            sn.hvcburstlen = 11; % Width of HVC burst
            sn.kernelstd   = 12; % Standard deviation of Gaussian dopamine kernel
            
            maxtemplate   = 1;   % maximum template value (this is arbitrary)
            
            % Derived parameters
            sn.lmanstd    = 0.05 * maxtemplate; % Standard deviation of LMAN noise
            sn.lmanoffset = 2    * sn.lmanstd;  % Mean of LMAN noise
            sn.winit      = 0.1  * sn.lmanstd;  % Maximum initial HVC-MSN weight
            sn.msnthresh  = 1    * sn.winit;    % Threshold for MSN output
            
            sn.LTPrate  = 0.05;   % FIXME how does this scale?
            sn.LTDrate  = 1e-6;   % FIXME how does this scale?
            
            a = (maxtemplate - sn.lmanoffset);
            t1 = linspace(0, 2*pi, sn.nhvc);
            t2 = linspace(0, 4*pi, sn.nhvc);
            y = -cos(t1) - cos(t2);
            y = y - min(y);
            y = y / max(y) * a + sn.lmanoffset;
            sn.template = y;
            
            for i = 0:9
                disp(i)
                sn.init()
                sn.simulate()
                
                filename = ['SparseNetFigureCandidate_slow_' int2str(i)];
                save([filename '.mat'], 'sn', '-v7.3')
                
                clf
                subplot(2,3,[1 4])
                sn.imagemsnout(sn.niter)
                subplot(2,3,[2 5])
                sn.plotbiasvstemplate(sn.niter)
                title(int2str(sn.niter))
                subplot(2,3,3)
                sn.plotmse();
                subplot(2,3,6)
                sn.plotvdw(50,sn.niter)
                saveas(gcf, [filename '.fig'])
            end
        end
        
        function compute_ltd_inhib(obj)
            % Run the simulation ten times so later we can pick the one
            % that looks best!
            % WARNING!!! THIS TAKES A VERY LONG TIME! Each 10,000 trial
            % simulation takes about 30 mins, so total takes about 5 hours.
            sn = SparseNet();
            
            sn.nhvc  =  100;
            sn.nmsn  =  300;
            sn.niter = 10000;
            
            sn.hvcburstlen = 11; % Width of HVC burst
            sn.kernelstd   = 12; % Standard deviation of Gaussian dopamine kernel
            
            maxtemplate   = 1;   % maximum template value (this is arbitrary)
            
            % Derived parameters
            sn.lmanstd    = 0.05 * maxtemplate; % Standard deviation of LMAN noise
            sn.lmanoffset = 2    * sn.lmanstd;  % Mean of LMAN noise
            sn.winit      = 0.1  * sn.lmanstd;  % Maximum initial HVC-MSN weight
            sn.msnthresh  = 1    * sn.winit;    % Threshold for MSN output
            
            sn.LTPrate  = 0.05;   % FIXME how does this scale?
            sn.LTDrate  = 2e-6;   % FIXME how does this scale?
            
            sn.latinhib = 5e-4;
            sn.pinhib = .75;
            
            a = (maxtemplate - sn.lmanoffset);
            t1 = linspace(0, 2*pi, sn.nhvc);
            t2 = linspace(0, 4*pi, sn.nhvc);
            y = -cos(t1) - cos(t2);
            y = y - min(y);
            y = y / max(y) * a + sn.lmanoffset;
            sn.template = y;
            
            %%
            for i = 0:9
                disp(i)
                sn.init()
                sn.simulate()
                
                filename = ['SparseNetFigureCandidate_inhib_' int2str(i)];
                save([filename '.mat'], 'sn', '-v7.3')
                
                clf
                subplot(2,3,[1 4])
                sn.imagemsnout(sn.niter)
                subplot(2,3,[2 5])
                sn.plotbiasvstemplate(sn.niter)
                title(int2str(sn.niter))
                subplot(2,3,3)
                sn.plotmse();
                subplot(2,3,6)
                sn.plotvdw(50,sn.niter)
                saveas(gcf, [filename '.fig'])
            end
        end
    end
end
