classdef SparseNet
    %SPARSENET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nhvc = 10; % number of hvc units
        nmsn = 100; % number of msn units
        thspike
        niter = 1e4;
        stdp
        learnrate %learning rate
        w
        winit = 0.1;
        hvcout
        msnout
        msnin
    end
    
    methods
        function obj = SparseNet(stdp, learnrate)
            obj.stdp = stdp;
            assert(mod(length(obj.stdp),2) == 1) % length of stdp is odd
            obj.learnrate = learnrate;
            obj.hvcout = eye(obj.nhvc);
            obj.msnout = zeros(obj.nmsn, obj.nhvc, obj.niter);
            obj.msnin = zeros(size(obj.msnout));
            obj.w = obj.winit * ones(obj.nmsn,obj.nhvc);
            obj.thspike = 0.95 * ones(obj.nmsn,1); % threshold for spiking
        end
        
        function obj = simulate(obj)
            for iter = 1:obj.niter
                obj = obj.ffstep(iter);
                obj = obj.wupdate(iter);
                %obj = obj.homeostasis(iter);
            end
        end
        
        function obj = ffstep(obj, iter)
            % MSN activity only depends on HVC input
            obj.msnin(:,:,iter) = obj.w * obj.hvcout;
            obj.msnout(:,:,iter) = obj.msnin(:,:,iter) >= (obj.thspike * ones(1,obj.nhvc));
        end
        
        function obj = wupdate(obj, iter)
            % Modified STDP: use LMAN*MSN instead of spike. 
            % For now, each MSN gets a different random signal from LMAN.
            dw = zeros(size(obj.w));
            lman = double(rand(obj.nmsn, obj.nhvc) > 0.5);
            for imsn = 1:obj.nmsn
                temp = conv(lman(imsn,:), obj.stdp);
                ndrop = (length(obj.stdp) - 1) / 2;
                elig = temp(ndrop+1:end-ndrop);
                dw(imsn,:) = elig .* obj.msnin(imsn,:,iter); % ones and zeros
            end
            
            obj.w = obj.w + obj.learnrate .* dw;
            obj.w = max(0, obj.w); % weights must be nonnegative
        end
        
        function obj = homeostasis(obj, iter)
            warning('Homeostasis not implemented')
        end
        
        function wimage(obj)
            imagesc(obj.w)
            title('Weights on MSN from HVC')
            xlabel('HVC unit')
            ylabel('MSN unit')
        end
        
        function msnimage(obj, imsn)
            imagesc(squeeze(obj.msnout(imsn,:,:))')
            xlabel('Time')
            ylabel('Trial')
            title(sprintf('MSN %g output', imsn))
        end
            
    end
    
end

