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
        tinhib  = 0.5;  % INHIBition, Tonic
        winit   = 0.5;  % initial hvc weights        
        istr = 1;
        
        % Model output
        wH
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
            obj.wH = obj.winit * rand(obj.nmsn,obj.nhvc);
            obj.template = sin(linspace(0,2*pi,obj.nhvc)) + 1;
            obj.rexp = zeros(obj.nhvc, obj.niter);
            %obj.noise = rand(obj.nhvc, obj.niter);
            %obj.noise = max(0,randn(obj.nhvc, obj.niter)/8+.5);
            z = generate_lman_noise_mes010(obj.nhvc, obj.niter);
            obj.noise = max(0, z./std(z(:))/8+0.5);
        end
        
        function simulate(obj)
            for iter = 1:obj.niter
                iter
                obj.ffstep(iter);
                obj.wupdate(iter);
                obj.rexpupdate(iter);
            end
        end
        
        function ffstep(obj, iter)
            % MSN activity depends on HVC input and noise (from lman)
            msnin = obj.wH * obj.hvcout - obj.tinhib;
            % MSN output is threshold linear
            obj.msnout(:,:,iter) = max(0, msnin);
            obj.lmanout(:,iter) = sum(obj.msnout(:,:,iter), 1)' + ...
                obj.noise(:,iter);
        end
        
        function v = vpost(obj, imsn, iter)
            v = obj.lmanout(:,iter)' - obj.allinhib(iter) + ...
                obj.wH(imsn,:) * obj.hvcout;
            v = max(0, v);
        end
        
        function wupdate(obj, iter)
            dw = zeros(size(obj.wH));           
            for i = 1:obj.nmsn
                % Long-term potentiation: Whenever an MSN is active, HVC
                % inputs that are also active are eligibile to be
                % strengthened. Eligible synapses are strengthened if a
                % reward is given.
                elig = (ones(obj.nhvc, 1) * obj.vpost(i,iter)) .* obj.hvcout';
                LTP = obj.rpe(iter) * elig; 
                
                % Long-term depression: Whenever an MSN is active, HVC weights
                % onto that MSN are weakened unless they were active too.
                LTD = obj.vpost(i,iter) * (1 - obj.hvcout)';
                
                dw(i,:) = obj.LTPrate * LTP - obj.LTDrate * LTD;
            end

            obj.wH = obj.wH + dw;
            obj.wH = max(0, obj.wH); % weights must be nonnegative
        end
        
        function d = rpe(obj, iter)
            d = obj.reward(iter)' - obj.rexp(:,iter)';
            assert(all(size(d) == [1, obj.nhvc]))
        end
        
        function inhib = allinhib(obj, iter)
            inhib = obj.tinhib + obj.istr * sum(obj.msnout(:,:,iter), 1);
            %inhib = zeros(size(inhib)); %FIXME
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
            
        
        function wimage(obj)
            tmax = nan(obj.nmsn, 1);
            for i = 1:obj.nmsn
                [~, tmax(i)] = max(obj.wH(i,:));
            end
            [~, ord] = sort(tmax);
            imagesc(obj.wH(ord,:))
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
            
    end
    
end

