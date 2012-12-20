classdef SparseNet < handle
    %SPARSENET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Size of the simulation
        nhvc = 10; % number of hvc units
        nmsn = 20; % number of msn units
        niter = 1e4;
        
        % Tweakable parameters
        LTPrate = 8e-3; % learning rate for Long-Term Potentiation
        LTDrate = 5e-4; % learning rate for Long-Term Depression
        rperate = 0.2;  % learning rate for predicted reward
        tinhib2 = 0; % tonic inhibition on msn output
        winit   = 0.5;  % initial hvc weights
        istr = 1;
        
        % Model output
        wH
        wL
        tonicinhib
        hvcout
        msnout
        lmanout
        noise
        template
        rexp
    end
    
    methods
        function obj = SparseNet()
            obj.init()
        end
        
        function init(obj)
            obj.hvcout = eye(obj.nhvc);
            obj.msnout = zeros(obj.nmsn, obj.nhvc, obj.niter);
            obj.lmanout = zeros(obj.nhvc, obj.niter);
            obj.wH = zeros(obj.nmsn, obj.nhvc, obj.niter);
            obj.wH(:,:,1) = obj.winit * rand(obj.nmsn,obj.nhvc);
            obj.wL = randn(obj.nmsn, 1) / 5 + 1;
            obj.template = sin(linspace(0,2*pi,obj.nhvc)) + 1;
            obj.rexp = zeros(obj.nhvc, obj.niter);
            z = generate_lman_noise_mes010(obj.nhvc, obj.niter);
            obj.noise = max(0, z./std(z(:))/8+0.5);
            obj.tonicinhib = zeros(obj.nmsn, obj.niter);
        end
        
        function simulate(obj)
            for iter = 1:obj.niter
                disp(iter) %FIXME
                obj.ffstep(iter);
                if iter < obj.niter
                    obj.wupdate(iter);
                    obj.rexpupdate(iter);
                end
            end
        end
        
        function ffstep(obj, iter)
            % MSN activity depends on HVC input and noise (from lman)
            msnin = obj.wH(:,:,iter) * obj.hvcout - obj.tinhib2;
            % MSN output is threshold linear
            obj.msnout(:,:,iter) = max(0, msnin);
            obj.lmanout(:,iter) = sum(obj.msnout(:,:,iter), 1)' + ...
                obj.noise(:,iter);
        end
        
        function v = vpost(obj, imsn, iter)
            v = obj.wL(imsn) * obj.lmanout(:,iter)' - ...
                obj.allinhib(imsn, iter) + ...
                obj.wH(imsn,:,iter) * obj.hvcout;
            v = max(0, v);
        end
        
        function wupdate(obj, iter)
            dw = zeros(obj.nmsn, obj.nhvc);           
            for i = 1:obj.nmsn
                dw(i,:) = obj.LTP(i, iter) - obj.LTD(i,iter);
                dI = mean(obj.vpost(i,iter)) - obj.tonicinhib(i,iter);
                obj.tonicinhib(i,iter+1) = obj.tonicinhib(i,iter) + ...
                    obj.rperate * dI;
            end
            
            obj.wH(:,:,iter+1) = max(0, obj.wH(:,:,iter) + dw); % weights must be nonnegative
        end
        
        function dw = LTP(obj, imsn, iter)
            % Long-term potentiation: Whenever an MSN is active, HVC
            % inputs that are also active are eligibile to be
            % strengthened. Eligible synapses are strengthened if a
            % reward is given.
            elig = (ones(obj.nhvc, 1) * obj.vpost(imsn,iter)) .* obj.hvcout';
            dw = obj.LTPrate * obj.rpe(iter) * elig;
        end
        
        function dw = LTD(obj, imsn, iter)
            % Long-term depression: Whenever an MSN is active, HVC weights
            % onto that MSN are weakened unless they were active too.
            dw = obj.LTDrate * obj.vpost(imsn,iter) * (1 - obj.hvcout)';
        end
        
        function d = rpe(obj, iter)
            d = obj.reward(iter)' - obj.rexp(:,iter)';
            assert(all(size(d) == [1, obj.nhvc]))
        end
        
        function I = allinhib(obj, imsn, iter)
            I = obj.tonicinhib(imsn,iter) + obj.istr * sum(obj.msnout(:,:,iter), 1);
        end
        
        function r = reward(obj, iter)
            r = -(obj.lmanout(:,iter) - obj.template').^2;
        end
        
        function rexpupdate(obj, iter)
            if iter < obj.niter
                obj.rexp(:,iter+1) = obj.rexp(:,iter) + ...
                    obj.rperate .* obj.rpe(iter)';
            end
        end
            
        
        function wimage(obj, iter)
            tmax = nan(obj.nmsn, 1);
            for i = 1:obj.nmsn
                [~, tmax(i)] = max(obj.wH(i,:, iter));
            end
            [~, ord] = sort(tmax);
            imagesc(obj.wH(ord,:, iter))
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
        
        function outvstemplate(obj, iter)
            plot(sum(obj.msnout(:,:,iter),1))
            hold all
            plot(obj.template)
            hold off
        end
        
        function moview(obj)
            for iter = 1:obj.niter
                imagesc(obj.wH(:,:,iter))
                title(int2str(iter))
                drawnow
            end
        end
        
        function imagemsn(obj, name, imsn)
            Y = zeros(obj.nhvc, obj.niter);
            for iter = 1:obj.niter
                Y(:,iter) = obj.(name)(imsn, iter);
            end
            imagesc(Y');
        end
            
    end
    
end

