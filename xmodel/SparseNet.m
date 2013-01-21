classdef SparseNet < handle
    %SPARSENET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Size of the simulation
        nhvc = 10; % number of hvc units
        nmsn = 20; % number of msn units
        niter = 1e4;
        
        % Tweakable parameters
        LTPrate = 1;% learning rate for Long-Term Potentiation
        LTDrate = 1;% learning rate for Long-Term Depression
        rperate = 0.2;  % learning rate for predicted reward
        msnthresh = 1; % tonic inhibition on msn output
        winit =1; % initial hvc weights
        lmanoffset = 1;
        lmanstd = 1;
        istr = 1;
        hvcburstlen = 3;
        kernelstd = 1/8;
        wLstd = 1;
        plearn = 1;
        
        % Model output
        wH
        wL
        msninhib
        latinhib
        hvcout
        msnout
        lmanout
        noise
        template
        rexp
        kernel
        randlearn
    end
    
    methods
        function obj = SparseNet()
            obj.init()
        end
        
        function init(obj)
            obj.hvcout = zeros(obj.nhvc);
            assert(mod(obj.hvcburstlen, 2) == 1)
            assert(obj.hvcburstlen >= 3)
            tburst = modnonzero((1:obj.hvcburstlen)-(obj.hvcburstlen+1)/2 + 1, obj.nhvc);
            t = linspace(0, pi, obj.hvcburstlen);
            hvcburst = sin(t).^2;
            hvcburst = hvcburst ./ sum(hvcburst);
            for ihvc = 1:obj.nhvc
                obj.hvcout(ihvc,tburst) = hvcburst;
                tburst = modnonzero(tburst + 1, obj.nhvc);
            end
            obj.msnout = zeros(obj.nmsn, obj.nhvc, obj.niter);
            obj.lmanout = zeros(obj.nhvc, obj.niter);
            obj.wH = nan(obj.nmsn, obj.nhvc, obj.niter);
            obj.wH(:,:,1) = obj.winit * rand(obj.nmsn,obj.nhvc);
            
            % LMAN weights are normally distributed around 1 with a
            % standard deviation given by obj.wLstd
            obj.wL = randn(obj.nmsn, 1) * obj.wLstd + 1;
            
            obj.template = sin(linspace(0,2*pi,obj.nhvc)) + 1;
            obj.rexp = zeros(obj.nhvc + 8*obj.kernelstd - 1, obj.niter);
            z = generate_lman_noise_mes010(obj.nhvc, obj.niter);
            obj.noise = z./std(z(:))*obj.lmanstd+obj.lmanoffset;
            
            obj.randlearn = rand(obj.nmsn, obj.niter) < obj.plearn;
            
            obj.msninhib = obj.wL * obj.istr;
            
            x = linspace(-4,4,8*obj.kernelstd);
            k = normpdf(x)'; % Gaussian, column vector
            obj.kernel = k./sum(k);
        end
        
        function simulate(obj)
            for iter = 1:obj.niter
%                 disp(iter) %FIXME
                obj.ffstep(iter);
                if iter < obj.niter
                    obj.wupdate(iter);
                    obj.rexpupdate(iter);
                end
                
                
%                 %%%FIXME
                clf
                subplot(1,3,1)
                obj.wimage(iter)
                subplot(1,3,2)
                obj.plotbiasvstemplate(iter)
                xlabel('Time (ms)')
                ylabel('Pitch')
                legend('Learned Song', 'Template')
                ylim([0 4])
                subplot(1,3,3)
                obj.plotmse()
                title(sprintf('Trial %g', iter))
                drawnow
%                 %%%%%%%%%%%
                
            end
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
            v = obj.wL(imsn) * obj.lmanout(:,iter)' - ...
                obj.allinhib(imsn, iter) + ...
                obj.wH(imsn,:,iter) * obj.hvcout;
        end
        
        function wupdate(obj, iter)
            dw = zeros(obj.nmsn, obj.nhvc);           
            for i = 1:obj.nmsn
                dw(i,:) = obj.LTP(i, iter) - obj.LTD(i,iter);
            end
            
            obj.wH(:,:,iter+1) = max(0, obj.wH(:,:,iter) + dw); % weights must be nonnegative
        end
        
        function dw = LTP(obj, imsn, iter)
            % Long-term potentiation: Whenever an MSN is active, HVC
            % inputs that are also active are eligibile to be
            % strengthened. Eligible synapses are strengthened if a
            % reward is given.
            vp = max(0, obj.vpost(imsn,iter));
            e = (ones(obj.nhvc, 1) * vp) .* obj.hvcout';
            % blur eligibility trace in time (across rows)
            assert(iscolumn(obj.kernel)) % kernel must be column vector
            etrace = conv2(e, obj.kernel);
            dw = obj.LTPrate * obj.rpe(iter) * etrace .* obj.randlearn(imsn, iter);
        end
        
        function dw = LTD(obj, imsn, iter)
            % Long-term depression: Whenever an MSN is active, HVC weights
            % onto that MSN are weakened unless they were active too.
            dw = obj.LTDrate * obj.msnout(imsn,:,iter) * (max(obj.hvcout(:)) - obj.hvcout)';
        end
        
        function d = rpe(obj, iter)
            x = obj.reward(iter)';
            d = conv(x, obj.kernel) - obj.rexp(:,iter)';
        end
        
        function I = allinhib(obj, imsn, iter)
            I = obj.msninhib(imsn) + obj.latinhib * sum(obj.msnout((1:obj.nmsn)~=imsn,:,iter), 1);
        end
        
        function r = reward(obj, iter)
            r = -abs(obj.lmanout(:,iter) - obj.template');
        end
        
        function rexpupdate(obj, iter)
            if iter < obj.niter
%                 obj.rexp(:,iter+1) = -(obj.bias(iter+1) - obj.template).^2;
                obj.rexp(:,iter+1) = obj.rexp(:,iter) + ...
                    obj.rperate .* obj.rpe(iter)';
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
            YL = ylim;
            ylim([0, YL(2)])
            xlabel('Trial')
            ylabel('Mean Squared Error')
        end
            
    end
    
end

