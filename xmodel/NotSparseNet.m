classdef NotSparseNet < SparseNet
    properties
        initready = false;
    end
    
    methods
        function obj = NotSparseNet()
            % Different default parameters
            obj.LTDrate = 0;
            obj.msnthresh = 0;
            obj.winit = 0;
            obj.latinhib = 0;
            obj.initready = true;
        end
        
        function init(obj)
            if obj.initready
                assert(obj.LTDrate   == 0)
                assert(obj.msnthresh == 0)
                assert(obj.winit     == 0)
                assert(obj.latinhib  == 0)
                init@SparseNet(obj);
            end
        end
        
        function v = vpost(obj, imsn, iter)
            v = obj.lmanout(:,iter)';
        end
    end
end
