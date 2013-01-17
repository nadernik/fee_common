classdef SparseNet_noltd_noinhib < SparseNet_noltd & SparseNet_noinhib
    properties
    end
    
    methods
        % Use the inhibition from SparseNet_noinhib (to get rid of lateral 
        % inhibition) and the weight update from SparseNet_noltd (to get 
        % rid of LTD).
        
        function wupdate(obj, iter)
            wupdate@SparseNet_noltd(obj, iter);
        end
        
        function I = allinhib(obj, imsn, iter)
            I = allinhib@SparseNet_noinhib(obj, imsn, iter);
        end
    end
end