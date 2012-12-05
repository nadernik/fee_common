classdef SparseNet
    %SPARSENET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nhvc = 10; % number of hvc units
        nmsn = 100; % number of msn units
        thspike
        niter = 1e3;
        stdp
        learnrate %learning rate
        w
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
            obj.w = zeros(obj.nmsn,obj.nhvc);
            obj.thspike = 0.95 * ones(obj.nmsn,1); % threshold for spiking
        end
        
        function obj = simulate(obj)
            for iter = 1:obj.niter
                obj = obj.ffstep(iter);
                obj = obj.wupdate(iter);
                obj = obj.homeostasis(iter);
            end
        end
        
        function obj = ffstep(obj, iter)
            obj.msnin(:,:,iter) = rand(obj.nmsn,obj.nhvc) + obj.w * obj.hvcout;
            obj.msnout(:,:,iter) = obj.msnin(:,:,iter) >= (obj.thspike * ones(1,obj.nhvc));
        end
        
        function obj = wupdate(obj, iter)
            dw = zeros(size(obj.w));
            for imsn = 1:obj.nmsn
                % convolve with stdp kernel and chop off the edges
                temp = conv(obj.msnout(imsn,:,iter), obj.stdp);
                ndrop = (length(obj.stdp) - 1) / 2;
                elig = temp(ndrop+1:end-ndrop);
                
                dw(imsn,:) = elig * obj.hvcout; % ones and zeros
            end
            obj.w = obj.w + obj.learnrate .* dw;
            obj.w = max(0, obj.w); % weights must be nonnegative
        end
        
        function obj = homeostasis(obj, iter)
            % For each MSN that didn't have exactly one spike, adjust its
            % threshold so there would have been exactly one spike.
            numspikes = sum(obj.msnout(:,:,iter), 2);
            ndx = numspikes ~= 1; 
            obj.thspike(ndx) = max(obj.msnin(ndx,:,iter), [], 2);
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

