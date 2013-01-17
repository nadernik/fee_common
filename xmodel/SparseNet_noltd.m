classdef SparseNet_noltd < SparseNet
    
    properties
    end
    
    methods
        
        function wupdate(obj, iter)
            
            % Update HVC->MSN synaptic weights at the end of an iteration
            dw = zeros(obj.nmsn, obj.nhvc);
            for i = 1:obj.nmsn
                % Change in weight only depends on LTP, not LTD. Compare to
                % SparseNet.
                dw(i,:) = obj.LTP(i, iter);
            end
            obj.wH(:,:,iter+1) = max(0, obj.wH(:,:,iter) + dw); % weights must be nonnegative
        end
        
    end
    
end