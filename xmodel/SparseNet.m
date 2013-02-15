classdef SparseNet < handle
    %SPARSENET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Size of the simulation
        nhvc  =  100; % number of hvc units
        nmsn  =  200; % number of msn units
        niter = 1000;
        
        % Tweakable parameters
        LTPrate     = 1;% learning rate for Long-Term Potentiation
        LTDrate     = 1;% learning rate for Long-Term Depression
        rperate     = 0.2;  % learning rate for predicted reward
        msnthresh   = 1; % tonic inhibition on msn output
        winit       = 1; % initial hvc weights
        lmanoffset  = 1;
        lmanstd     = 1;
        hvcburstlen = 1; % width of HVC burst
        kernelstd   = 0; % standard deviation of Gaussian kernel that blurs reward and eligibility traces
        pinhib      = 1; % Probability of one MSN inhibting another
        latinhib    = 1; % Strength of lateral inhibition
        
        MICHALE_IS_WATCHING = false;
        
        % Model output
        wH
        wI
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
            
            % Initialize empty matrices
            obj.hvcout  = zeros(obj.nhvc);
            obj.msnout  = zeros(obj.nmsn, obj.nhvc, obj.niter);
            obj.lmanout =   nan(obj.nhvc, obj.niter);
            obj.rexp    = zeros(obj.nhvc, obj.niter);
            obj.wH      = zeros(obj.nmsn, obj.nhvc, obj.niter);
            
            % Check to make sure HVC burst width parameter is odd 
            if mod(obj.hvcburstlen, 2) == 0
                obj.hvcburstlen = obj.hvcburstlen + 1;
                warning('SparseNet:badParameter', 'HVC burst length set to %g because it must be odd.', obj.hvcburstlen)
            end
            
            % HVC burst is one period of sine squared, scaled so that its
            % area is unity.
            BL = obj.hvcburstlen + 2; % add 2 to burst length because the first and last points of the burst will be zero
            t = linspace(0, pi, BL);
            hvcburst = sin(t).^2; 
            hvcburst = hvcburst ./ sum(hvcburst);
            
            tburst = (1:BL)-(BL+1)/2 + 1; % first burst is centered on t=1            
            for ihvc = 1:obj.nhvc
                mask = tburst > 0 & tburst <= obj.nhvc; % chop off parts of the burst that extend outside the song
                obj.hvcout(ihvc,tburst(mask)) = hvcburst(mask);
                tburst = tburst + 1;
            end
            sumh = ones(obj.nhvc, 1) * sum(obj.hvcout,1);
            obj.hvcout = obj.hvcout ./ sumh;
                        
            
            % HVC-MSN weights
            obj.wH(:,:,1) = obj.winit * rand(obj.nmsn,obj.nhvc);
            
            % Expected reward is error between bias and template
            obj.rexp(:,1) = -abs(obj.template-obj.lmanoffset);
            
            z = generate_lman_noise_mes010(obj.nhvc, obj.niter);
            obj.noise = z./std(z(:))*obj.lmanstd;
            
            % Lateral inhibition weights
            wii1 = (rand(obj.nmsn) <= obj.pinhib); % random 1s and 0s
            wii2 = wii1 & ~eye(obj.nmsn); % make sure no MSN inhibits itself
            obj.wI = obj.latinhib * wii2; % scale based on inhibition strength parameter
            
            % Kernel for dopamine and eligibility traces
            x = linspace(-4,4,8*obj.kernelstd + 1);
            k = normpdf(x)'; % Gaussian, column vector
            obj.kernel = k./sum(k);
            
            obj.rexp(:,1) = -abs(obj.lmanoffset - obj.template');
        end
        
        function simulate(obj)
            for iter = 1:obj.niter
                disp(iter)
                obj.ffstep(iter);
                if iter < obj.niter
                    obj.wupdate(iter);
                    obj.rexpupdate(iter);
                end
                
                if obj.MICHALE_IS_WATCHING && mod(iter,10) == 0
                    subplot(2,3,[1 4])
                    obj.imagemsnout(iter)
                    subplot(2,3,[2 5])
                    obj.plotbiasvstemplate(iter)
                    title(int2str(iter))
                    subplot(2,3,3)
                    %obj.plotmse();
                    subplot(2,3,6)
                    obj.plotvdw(50,iter)
                    drawnow
                end
            end
        end
        
        function reinit(obj, iter)
            % Reinitializes the model and sets the initial conditions to
            % the state at the specified iteration.
            
            % Save the state of the model on trial 'iter'
            saved.wH   = obj.wH(:,:,iter);
            saved.rexp = obj.rexp(:,iter);
            
            % Save the randomly generated things
            saved.wI   = obj.wI;
            
            % Re-initialize
            obj.init()
            
            % Set initial state to the saved state
            obj.wH(:,:,1) = saved.wH;
            obj.rexp(:,1) = saved.rexp;
            obj.wI        = saved.wI;
        end
            
        
        function ffstep(obj, iter)
            % MSN activity depends on HVC input and noise (from lman)
            msnin = obj.wH(:,:,iter) * obj.hvcout - obj.msnthresh;
            % MSN output is threshold linear
            obj.msnout(:,:,iter) = max(0, msnin);
            
            bias = sum(obj.msnout(:,:,iter), 1)';
            lmanin = obj.lmanoffset + obj.noise(:,iter) + bias;
            obj.lmanout(:,iter) = max(0, lmanin);
        end
        
        function v = vpost(obj, imsn, iter)
            % v = vpost(obj, imsn, iter)
            %
            % Post-synaptic depolarization used in learning rule (see LTP).
            % The learning rule is roughly Vpost * HVC * RPE.
            L = obj.noise(:,iter)';
            H = obj.wH(imsn,:,iter) * obj.hvcout;
            I = obj.inhib(imsn,iter);
            v = L + H - I;
        end
        
        function wupdate(obj, iter)
            dw = zeros(obj.nmsn, obj.nhvc);
            for i = 1:obj.nmsn
                dw(i,:) = obj.LTP(i, iter) + obj.LTD(i,iter);
            end
            
            obj.wH(:,:,iter+1) = max(0,obj.wH(:,:,iter) + dw); % weights must be nonnegative
        end
        
        function dw = LTP(obj, imsn, iter)
            % Long-term potentiation: Whenever an MSN is active, HVC
            % inputs that are also active are eligibile to be
            % strengthened. Eligible synapses are strengthened if a
            % reward is given.
            vp = max(0, obj.vpost(imsn,iter));
            L = ones(obj.nhvc,1) * vp;
            H = obj.hvcout';
            e = L .* H;
            % blur eligibility trace in time (across rows)
            assert(iscolumn(obj.kernel)) % kernel must be column vector
            etrace   = conv2(e, obj.kernel);
            dopamine = conv(obj.rpe(iter), obj.kernel);
            dw = obj.LTPrate * dopamine' * etrace;
        end
        
        function dw = LTD(obj, imsn, iter)
            % Long-term depression
            msnactive = obj.msnout(imsn,:,iter) > 0;
            hvcactive = obj.hvcout > 0;
            dw = -obj.LTDrate * msnactive * (~hvcactive)';
        end
        
        function d = rpe(obj, iter)
            d = obj.reward(iter) - obj.rexp(:,iter);
        end
        
        function I = inhib(obj, imsn, newiter)
            persistent iter
            persistent Iall
            if isempty(iter)
                iter = -1;
            end
            if newiter ~= iter
                iter = newiter;
                Iall = obj.wI * (obj.msnout(:,:,iter) > 0);
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
        
        function imagemsnout(obj, iter, dosort)
            % imagemsnout(obj, iter, dosort)
            %   imagesc of msn output on a given iteration. If dosort is 
            if ~exist('dosort', 'var')
                dosort = true;
            end
            if dosort == true
                tmax = nan(obj.nmsn, 1);
                for i = 1:obj.nmsn
                    [~, tmax(i)] = max(obj.msnout(i,:, iter));
                end
                [~, ord] = sort(tmax);
                w = obj.msnout(ord,:,iter);
            else
                w = obj.msnout(:,:,iter);
            end
            imagesc(w)
            xlabel('HVC neuron')
            ylabel('MSN')
            title(sprintf('MSN output on trial %g', iter))
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
            %PLOTVDW Plots Vpost, LTP and LTD for one MSN on one trial
            %Usage: plotvdw(obj, imsn, iter) 
            v = obj.vpost(imsn,iter);
            p = obj.LTP(imsn, iter);
            d = obj.LTD(imsn, iter);
            plot(v/max(abs(v)), 'k', 'LineWidth', 2)
            hold on
            plot(p/max(abs(p)), 'g', 'LineWidth', 2)
            plot(d/max(abs(p)), 'r', 'LineWidth', 2)
            hold off
            title(sprintf('MSN %g on trial %g', imsn, iter))
            legend({'V_p_o_s_t', 'LTP', 'LTD'})
        end
        
        function ltp = allltp(obj)
            ltp = zeros(obj.nmsn, obj.nhvc, obj.niter);
            for iter = 1:obj.niter
                for imsn = 1:obj.nmsn
                    ltp(imsn,:,iter) = obj.LTP(imsn, iter);
                end
            end
        end
        
        function ltd = allltd(obj)
            ltd = zeros(obj.nmsn, obj.nhvc, obj.niter);
            for iter = 1:obj.niter
                for imsn = 1:obj.nmsn
                    ltd(imsn,:,iter) = obj.LTD(imsn, iter);
                end
            end
        end
        
        function bias = allbias(obj)
            bias = zeros(obj.nhvc, obj.niter);
            for iter = 1:obj.niter
                fprintf('Trial %g\n', iter)
                bias(:,iter) = obj.bias(iter);
            end
        end
        
        function vp = allvpost(obj)
            T = obj.nhvc + length(obj.kernel) - 1;
            vp = zeros(obj.nmsn, T, obj.niter);
            for iter = 1:obj.niter
                for imsn = 1:obj.nmsn
                    vp(imsn, :, iter) = obj.vpost(imsn, iter);
                end
            end
        end
        
        function save(obj, filename)
            % Saves object to a file and attempts to use less disk space by
            % emptying the properties that can be derived again later.
            % Use obj.load(filename) to load from file and recalculate the
            % empty properties
            
            % Copy values that will be emptied
            temp.msnout  = obj.msnout; 
            temp.lmanout = obj.lmanout;
            
            % Empty the values
            obj.msnout  = [];
            obj.lmanout = [];
            
            % Save object with the empty values
            save(filename, 'obj')
            
            % Put the emptied values back so we can continue using the
            % object like normal.
            obj.msnout  = temp.msnout;
            obj.lmanout = temp.lmanout;
        end
        
        function load(obj, filename)
            % Loads an object from a save file created by obj.save(). All
            % properties in obj will be replaced with the values in the
            % loaded file. MSN output and LMAN output are recalculated
            % based on other stored values.
            
            % Fill in loaded values
            temp = load(filename, 'obj');
            fn = fieldnames(temp.obj);
            for i = 1:length(fn)
                fname = fn{i};
                obj.(fname) = temp.obj.(fname);
            end
            
            % Recalculate MSN and LMAN output
            for iter = 1:obj.niter
                obj.ffstep(iter)
            end
        end 
    end % methods
end % classdef
