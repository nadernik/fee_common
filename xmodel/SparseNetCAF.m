classdef SparseNetCAF < SparseNetChanneled
    properties
        caftargetthresh = 0; % Threshold for punishment. I
        caftargettime = 100; % Target time for CAF
        caferrorval = 800; % Error value during punishment
        caferrortime = 2; % Duration of punishment, in milliseconds.
        lmanstretch = 1; % LMAN fluctuations stretched by this factor. Set to 1 for unstretched fluctuations, 2 for twice as fast, and 1/2 for half speed.
    end
    
    methods
        function init(obj)
            % Initialize the model. Use the init() method from the parent
            % class (SparseNetChanneled), but then generate LMAN noise with
            % variable time constant. The time constant of LMAN
            % fluctuations is set with the lmanstretch property.
            
            init@SparseNetChanneled(obj) % Call parent method
            
            % For each LMAN unit, generate noise with stretched spectrum
            for ii = 1:obj.nlman
                obj.noise(ii,:,:) = ... 
                    generate_lman_noise_streched_spectrum(obj.nhvc, ...
                    obj.niter, obj.lmanstretch);
            end
        end
        
        function r = reward(obj, iter)
            % Reward is the same as parent class unless CAF is triggered.
            % If the rendition does not escape punishment, the error is set
            % to obj.caferrorval for obj.caferrortime milliseconds at the
            % target time.
            r = reward@SparseNetChanneled(obj, iter);
            if ~obj.isescape(iter)
                t = obj.caftargettime + (1:obj.caferrortime);
                r(t) = -obj.caferrorval;
            end
        end
        
        function esc = isescape(obj, iter)
            % Returns true if this rendition escapes punishment or false if
            % this rendition is hit with punishment. The rendition escapes 
            % if the first dimension of the vocal output at the target time
            % is greater than the threshold.
            vout = obj.vocalout(1,obj.caftargettime, iter);
            esc = vout > obj.caftargetthresh;
        end
    end
end