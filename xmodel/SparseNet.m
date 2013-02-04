classdef SparseNet < handle
    %SPARSENET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Size of the simulation
        nhvc = 100; % number of hvc units
        nmsn = 200; % number of msn units
        niter = 1000;
        
        % Tweakable parameters
        LTPrate = 1;% learning rate for Long-Term Potentiation
        LTDrate = 1;% learning rate for Long-Term Depression
        rperate = 0.2;  % learning rate for predicted reward
        msnthresh = 1; % tonic inhibition on msn output
        winit =1; % initial hvc weights
        lmanoffset = 1;
        lmanstd = 1;
        v0offset = 0;
        v0decay = 0;
        hvcburstlen = 3;
        kernelstd = 1/8;
        wLstd = 1;
        pinhib = 1; % Probability of one MSN inhibting another
        latinhib = 1;
        MICHALE_IS_WATCHING = false;
        
        % Model output
        wH
        wL
        wI
        v0
        hvcout
        msnout
        lmanout
        noise
        template = nan;
        rexp
        kernel
    end
    
    methods
        function obj = SparseNet()
            obj.init()
        end
        
        function init(obj)
            obj.hvcout = zeros(obj.nhvc);
            assert(mod(obj.hvcburstlen, 2) == 1)
            assert(obj.hvcburstlen >= 3)
            tburst = (1:obj.hvcburstlen)-(obj.hvcburstlen+1)/2 + 1;
            mask = tburst > 0 & tburst <= obj.nhvc;
            t = linspace(0, pi, obj.hvcburstlen);
            hvcburst = sin(t).^2;
            hvcburst = hvcburst ./ sum(hvcburst);
            for ihvc = 1:obj.nhvc
                obj.hvcout(ihvc,tburst(mask)) = hvcburst(mask);
                tburst = tburst + 1;
                mask = tburst > 0 & tburst <= obj.nhvc;
            end
            obj.msnout = zeros(obj.nmsn, obj.nhvc, obj.niter);
            obj.lmanout = zeros(obj.nhvc, obj.niter);
            obj.v0 = zeros(obj.nmsn, obj.niter);
            obj.wH = nan(obj.nmsn, obj.nhvc, obj.niter);
            obj.wH(:,:,1) = obj.winit * rand(obj.nmsn,obj.nhvc);
            
            % LMAN weights are normally distributed around 1 with a
            % standard deviation given by obj.wLstd
            obj.wL = randn(obj.nmsn, 1) * obj.wLstd + 1;
            
            obj.rexp = zeros(obj.nhvc, obj.niter);
            obj.rexp(:,1) = -abs(obj.template-obj.lmanoffset);
            
            z = generate_lman_noise_mes010(obj.nhvc, obj.niter);
            obj.noise = z./std(z(:))*obj.lmanstd+obj.lmanoffset;
            
            % Lateral inhibition weights
            obj.wI = (rand(obj.nmsn) <= obj.pinhib); % random 1s and 0s
            obj.wI = obj.wI & ~eye(obj.nmsn); % make sure no MSN inhibits itself
            obj.wI = obj.latinhib * obj.wI; % scale based on inhibition strength parameter
                        
            x = linspace(-4,4,8*obj.kernelstd);
            k = normpdf(x)'; % Gaussian, column vector
            obj.kernel = k./sum(k);
            
            
            r = -abs(obj.lmanoffset - obj.template');
            sn.rexp(:,1) = conv(r, obj.kernel);
        end
        
        function simulate(obj)
            for iter = 1:obj.niter
%                 disp(iter) %FIXME
                obj.ffstep(iter);
                if iter < obj.niter
                    obj.wupdate(iter);
                    obj.rexpupdate(iter);
                end
                if obj.MICHALE_IS_WATCHING && mod(iter,10) == 0
                    subplot(2,3,[1 4])
                    obj.wimage(iter)
                    subplot(2,3,[2 5])
                    obj.plotbiasvstemplate(iter)
                    title(int2str(iter))
                    subplot(2,3,3)
                    %obj.plotmse();
                    subplot(2,3,6)
                    obj.plotvdw(1,iter)
                    drawnow
                end
                
            end
        end
        
        function reinit(obj)
            obj.msnout = nan(obj.nmsn, obj.nhvc, obj.niter);
            obj.lmanout = nan(obj.nhvc, obj.niter);
            z = generate_lman_noise_mes010(obj.nhvc, obj.niter);
            obj.noise = z./std(z(:))*obj.lmanstd+obj.lmanoffset;
            
            obj.v0(:,1) = obj.v0(:,end);
            obj.v0(:,2:end) = nan;
            
            obj.wH(:,:,1) = obj.wH(:,:,end);
            obj.wH(:,:,2:end) = nan;
            
            obj.rexp(:,1) = obj.rexp(:,end);
            obj.rexp(:,2:end) = nan;
            
            % Preserved:
            % hvcout
            % wL
            % template
            % wI
            % kernel
        end
            
        
        function ffstep(obj, iter)
            % MSN activity depends on HVC input and noise (from lman)
            msnin = obj.wH(:,:,iter) * obj.hvcout - obj.msnthresh;
            % MSN output is threshold linear
            obj.msnout(:,:,iter) = max(0, msnin);
            obj.lmanout(:,iter) = max(0, sum(obj.msnout(:,:,iter), 1)' + ...
                obj.noise(:,iter));
        end
        
        function v = vpost(obj, imsn, iter)
            v = (obj.wL(imsn)        * obj.lmanout(:,iter)' + ...
                 obj.wH(imsn,:,iter) * obj.hvcout) - ...
                 (obj.allinhib(imsn, iter));
        end
        
        function v0update(obj, iter)
            for imsn = 1:obj.nmsn
                vp = obj.vpost(imsn, iter);
                if max(vp) > (obj.v0(imsn,iter) + obj.v0offset)
                    obj.v0(imsn, iter+1) = max(vp) - obj.v0offset;
                else
                    obj.v0(imsn, iter+1) = obj.v0(imsn, iter) * (1-obj.v0decay);
                end
            end
        end
        
        function wupdate(obj, iter)
            dw = zeros(obj.nmsn, obj.nhvc);
            obj.v0update(iter);
            for i = 1:obj.nmsn
                dw(i,:) = obj.LTP(i, iter) + obj.LTD(i,iter);
            end
            
            obj.wH(:,:,iter+1) = max(0, 0.9999*obj.wH(:,:,iter) + dw); % weights must be nonnegative
        end
        
        function dw = LTP(obj, imsn, iter)
            % Long-term potentiation: Whenever an MSN is active, HVC
            % inputs that are also active are eligibile to be
            % strengthened. Eligible synapses are strengthened if a
            % reward is given.
            vp = obj.vpost(imsn,iter) - obj.v0(imsn,iter);
            e = (ones(obj.nhvc, 1) * vp) .* obj.hvcout';
            % blur eligibility trace in time (across rows)
            assert(iscolumn(obj.kernel)) % kernel must be column vector
            etrace   = conv2(e, obj.kernel);
            dopamine = conv(obj.rpe(iter), obj.kernel);
            dw = obj.LTPrate * dopamine' * etrace;
        end
        
        function dw = LTD(obj, imsn, iter)
            % Long-term depression
            dw = -obj.LTDrate * obj.msnout(imsn,:,iter) * (obj.hvcout == 0)';
        end
        
        function d = rpe(obj, iter)
            d = obj.reward(iter) - obj.rexp(:,iter);
        end
        
        function I = allinhib(obj, imsn, newiter)
            persistent iter
            persistent Iall
            if isempty(iter)
                iter = -1;
            end
            if newiter ~= iter
                iter = newiter;
                Iall = obj.wI * obj.msnout(:,:,iter);
            end
            I = Iall(imsn,:);
        end
        
        function r = reward(obj, iter)
            r = -abs(obj.lmanout(:,iter) - obj.template');
        end
        
        function rexpupdate(obj, iter)
            if iter < obj.niter
                obj.rexp(:,iter+1) = obj.rexp(:,iter) + ...
                    obj.rperate .* obj.rpe(iter);
            end
        end
        
        function b = bias(obj, iter)
            msnin = obj.wH(:,:,iter) * obj.hvcout - obj.msnthresh;
            mout = max(0, msnin);
            b = obj.lmanoffset + sum(mout, 1);
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
        
        function plotbiasvstemplate(obj, iter)
            Y = sum(obj.msnout(:,:,iter),1) + obj.lmanoffset;
            plot(Y)
            hold all
            plot(obj.template)
            hold off
            legend({'Bias', 'Template'})
            xlabel('Time (ms)')
            ylabel('Output')
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
        
        function plotmse(obj)
            % Plot the mean squared error between the bias and template,
            % across trials.
            mse = zeros(1,obj.niter);
            for iter = 1:obj.niter
                mse(iter) = mean((obj.bias(iter) - obj.template).^2);
            end
            plot(mse)
            xlim([1 obj.niter])
            ylim([0, mse(1)*1.1])
            xlabel('Trial')
            ylabel('Mean Squared Error')
        end
        
        function plotvdw(obj, imsn, iter)
            v = obj.vpost(imsn,iter) - obj.v0(imsn,iter);
            p = obj.LTP(imsn, iter);
            d = obj.LTD(imsn, iter);
            plot(v/max(abs(v)), 'k', 'LineWidth', 2)
            hold on
            plot(p/max(abs(p)), 'g', 'LineWidth', 2)
            plot(d/max(abs(p)), 'r', 'LineWidth', 2)
            hold off
            title(sprintf('MSN %g on trial %g', imsn, iter))
            legend({'V_p_o_s_t - V_0', 'LTP', 'LTD'})
        end
            
    end
    
end
