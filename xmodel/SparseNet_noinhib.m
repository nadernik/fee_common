classdef SparseNet_noinhib < SparseNet
    
    properties
    end
    
    methods
        
        function I = allinhib(obj, imsn, iter)
            % Inhibition onto MSN dendrite (affects learning)
            % Contrary to the parent class SparseNet, there is no lateral 
            % inhibition between MSNs here.
           
            I = obj.msninhib(imsn);
        end
        
    end
    
end