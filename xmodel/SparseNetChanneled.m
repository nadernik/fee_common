classdef SparseNetChanneled < SparseNetHardwired
    % This is a network that has multiple parallel channels through Area X
    % that converge on vocal output.
    
    properties
        wL % weights on MSN from LMAN. Transpose this to get weights on LMAN from MSN (they are reciprocally connected).
        wV % weights on vocal output from LMAN units
        nlman = 2; % number of lman channels
        vocalout % vocal output
        nvocal = 1; % number of dimensions in vocal output
    end
    
    methods
        function init(obj)
            % Make sure we have the right numbers of LMAN and MSN units.
            % Each dimension of vocal output must have 2 LMAN units (one to
            % push and one to pull). Each LMAN unit must in turn have one
            % MSN unit for each HVC unit because HVC->MSN will be wired
            % one-to-one in each channel.
            if obj.nlman ~= (2 * obj.nvocal)
                error('SparseNet:badParameter', 'Must have 2 LMAN units for each dimension of vocal output.')
            end
            if obj.nmsn ~= (obj.nlman * obj.nhvc)
                error('SparseNet:badParameter', 'Must have exactly lman*hvc MSN units.')
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
            
            % A separate noise source for each LMAN unit. Each noise source
            % produces variations that have the same spectrum as pitch
            % fluctuations measured from a bird named mes010. HE WAS A GOOD
            % BIRD! HE WILL LIVE FOREVER IN-SILICO!
            obj.noise = zeros(obj.nlman, obj.nhvc, obj.niter);
            for ii = 1:obj.nlman
                obj.noise(ii,:,:) = generate_lman_noise_mes010(obj.nhvc, obj.niter);
            end
            
            % Set up multiple parallel channels through the anterior
            % forebrain pathway. Each LMAN unit projects to an equal,
            % distinct subset of MSN units and receives input from these
            % same MSN units. 
            chanmsn = floor(obj.nmsn/obj.nlman); % number of msn units in each channel
            for ch = 1:obj.nlman
                imsn = (1:chanmsn) + chanmsn*(ch-1);
                obj.wL(imsn,ch) = 1;
            end
            
            % Wire LMAN to vocal output. Each vocal output gets two LMAN
            % units, one pushing it up and the other pulling it down. Gives
            % a warning if there aren't the right number of LMAN units to
            % make this happen.
            obj.wV = zeros(obj.nvocal, obj.nlman);
            for dim = 1:obj.nvocal
                ilman = [1, 2] + 2 * (dim - 1);
                obj.wV(dim, ilman) = [1, -1];
            end
            
            % Wire HVC to MSNs one-to-one
            obj.wH = zeros(obj.nmsn, obj.nhvc, obj.niter);
            obj.wH(:,:,1) = repmat(eye(obj.nhvc), obj.nlman, 1);
            
            % Initialize vocal output
            obj.msnout = zeros(obj.nmsn, obj.nhvc, obj.niter);
            obj.lmanout = zeros(obj.nlman, obj.nhvc, obj.niter);
            obj.vocalout = zeros(obj.nvocal, obj.nhvc, obj.niter);
            
            % Kernel for dopamine and eligibility traces
            x = linspace(-4,4,8*obj.kernelstd + 1);
            k = normpdf(x)'; % Gaussian, column vector
            obj.kernel = k./sum(k);
            
            % Expected reward
            obj.rexp = zeros(obj.nhvc, obj.niter);
            % FIXME: Expected reward might be different? Initialize here.
            
            % FIXME: Is lateral inhibition local to each channel?
            
        end
        
        function ffstep(obj, iter)
            obj.msnout(:,:,iter) = max(0, obj.wH(:,:,iter) * obj.hvcout); % MSN output
            obj.lmanout(:,:,iter) = max(0, obj.wL' * obj.msnout(:,:,iter) + obj.noise(:,:,iter) + obj.lmanoffset); % LMAN output
            % Vocal output
            obj.vocalout(:,:,iter) = obj.wV * obj.lmanout(:,:,iter);
        end
        
        function v = vpost(obj, imsn, iter)
            % add wL
            v = obj.wL(imsn,:) * obj.lmanout(:,:,iter);
        end
        
        function r = reward(obj, iter)
            % reward is the difference between vocal output and the
            % template (with a negative sign so that bigger differences
            % mean LOWER reward)
            % size = nhvc x 1
            r = -(sum(abs(obj.vocalout(:,:,iter) - obj.template), 1))';
        end
        
        function b = bias(obj, iter)
            % Bias is the influence of Area X on vocal output
            b = obj.wV * obj.wL' * obj.msnout(:,:,iter);
        end
        
        function wupdate(obj, iter)
            % Update weights between HVC and MSN. To save time and preserve
            % hardwired architecture, only update the weights that are not
            % zero.
            wlist = find(obj.wH(:,:,iter) > 0); % list of weights to update
            siz = size(obj.wH(:,:,iter));
            for iw = wlist'
                [imsn, ihvc] = ind2sub(siz, iw);
                ilman = find(obj.wL(imsn,:) > 0);
                L = obj.lmanout(ilman,:,iter);
                H = obj.hvcout(ihvc,:);
                e = L .* H;
                etrace = conv(e, obj.kernel);
                dopamine = conv(obj.rpe(iter), obj.kernel);
                obj.wH(imsn,ihvc,iter+1) = obj.wH(imsn,ihvc,iter) + ...
                    obj.LTPrate * etrace * dopamine;
            end
        end
    end
end