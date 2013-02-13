classdef SparseNetHardwired < SparseNet
    
    properties
    end
    
    methods
        function obj = SparseNetHardwired()
            % Different default parameters for hard-wired network
            obj.latinhib  = 0;
            obj.msnthresh = 0;
            obj.LTDrate   = 0;
            obj.wLstd     = 0;
        end
            
        function init(obj)
            msgid = 'SparseNet:badParameter';
            if obj.latinhib  ~= 0
                warning(msgid, 'Lateral inhibtion set to zero.')
                obj.latinhib = 0;
            end
            if obj.LTDrate  ~= 0
                warning(msgid, 'LTD rate set to zero.')
                obj.LTDrate = 0;
            end
%             if obj.msnthresh  ~= 0
%                 warning(msgid, 'MSN threshold set to zero.')
%                 obj.msnthresh = 0;
%             end
            if obj.wLstd  ~= 0
                warning(msgid, 'LMAN weight variance set to zero.')
                obj.wLstd = 0;
            end
            if obj.nmsn ~= obj.nhvc
                warning(msgid, 'Number of MSNs set to equal number of HVC units')
            	obj.nmsn = obj.nhvc;
            end

            % Call superclass init()
            init@SparseNet(obj)
            
            % Initialize HVC-MSN weights to be sparse. Any weights that are
            % initialized to zero will remain zero through the whole run
            % (see wupdate() function).
            wprofile = normpdf(linspace(0,3,5));
            wprofile = wprofile ./ max(wprofile);
            w = wprofile(1) * eye(obj.nhvc);
            for n = 1:length(wprofile)-1
                dp = diag(ones(obj.nhvc-n,1),  n);
                dn = diag(ones(obj.nhvc-n,1), -n);
                w = w + wprofile(n+1) * (dp + dn);
            end 
            obj.wH(:,:,1) = obj.winit * w;
        end
        
        function wupdate(obj, iter)
            wupdate@SparseNet(obj, iter)
            % Preserve hard-wired sparesness by forcing all weights that
            % were zero on the first trial to stay zero.
            womit = obj.wH(:,:,1) == 0;
            wnew = obj.wH(:,:,iter+1);
            wnew(womit) = 0;
            obj.wH(:,:,iter+1) = wnew;
        end
        
        function v = vpost(obj, imsn, iter)
            % v = vpost(obj, imsn, iter)
            %
            % Post-synaptic depolarization used in learning rule (see LTP).
            % The learning rule is roughly Vpost * HVC * RPE.
            v = obj.wL(imsn) * obj.lmanout(:,iter)';
        end
                
    end
end