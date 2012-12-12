classdef SparseNet < handle
    %SPARSENET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nhvc = 10; % number of hvc units
        nmsn = 20; % number of msn units
        winit = 0.5;
        
        niter = 1e4;
        LTPrate % learning rate for Long-Term Potentiation
        LTDrate % learning rate for Long-Term Depression
        w
        hvcout
        msnout
        lman
        msnin
        thspike = 1.4; % threshold for spiking
    end
    
    methods
        function obj = SparseNet(LTPrate, LTDrate)
            obj.LTPrate = LTPrate;
            obj.LTDrate = LTDrate;
            obj.hvcout = eye(obj.nhvc);
            obj.msnout = zeros(obj.nmsn, obj.nhvc, obj.niter);
            obj.msnin = zeros(size(obj.msnout));
            obj.w = obj.winit * ones(obj.nmsn,obj.nhvc);
        end
        
        function simulate(obj)
            for iter = 1:obj.niter
                obj.ffstep(iter);
                obj.wupdate(iter);
            end
        end
        
        function ffstep(obj, iter)
            % MSN activity depends on HVC input and randomness (from lman)
            common = ones(obj.nmsn, 1) * rand(1, obj.nhvc);
            obj.lman = 0.6*common + 0.4*rand(obj.nmsn, obj.nhvc);
            obj.msnin(:,:,iter) = obj.w * obj.hvcout + obj.lman;
            % MSN output is threshold linear
            obj.msnout(:,:,iter) = max(0, obj.msnin(:,:,iter) - obj.thspike);
        end
        
        function wupdate(obj, iter)
            dw = zeros(size(obj.w));
            for i = 1:obj.nmsn
                % Long-term potentiation: Whenever an MSN is active, HVC
                % inputs that are also active are eligibile to be
                % strengthened. Eligible synapses are strengthened if a
                % reward is given.
                elig = (ones(obj.nhvc, 1) * obj.msnout(i,:,iter)) .* obj.hvcout';
                LTP = obj.reward(iter) * elig; 
                
                % Long-term depression: Whenever an MSN is active, HVC weights
                % onto that MSN are weakened unless they were active too.
                LTD = obj.msnout(i,:,iter) * (1 - obj.hvcout)';
                
                dw(i,:) = obj.LTPrate * LTP - obj.LTDrate * LTD;
            end

            obj.w = obj.w + dw;
            obj.w = max(0, obj.w); % weights must be nonnegative
        end
        
        function r = reward(obj, iter)
            r = zeros(1, obj.nhvc);
            if mean(obj.lman(:,3)) > 0.5
                r(3) = 1;
            else
                r(3) = -1;
            end
            if mean(obj.lman(:,7)) > 0.5
                r(7) = 1;
            else
                r(7) = -1;
            end
        end
            
        
        function wimage(obj)
            imagesc(obj.w)
            title('Weights on MSN from HVC')
            xlabel('HVC unit')
            ylabel('MSN unit')
        end
        
        function msnimage(obj, imsn)
            image(squeeze(obj.msnout(imsn,:,:))' * 64)
            xlabel('Time')
            ylabel('Trial')
            title(sprintf('MSN %g output', imsn))
        end
            
    end
    
end

