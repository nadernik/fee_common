classdef Fig < handle
    properties
        h
        datadir
        filename
    end
    
    methods
        function compute(obj)
            % All child classes of Fig should define their own compute
            % method! This method processes data into a form that is ready
            % to plot, and then saves the data to obj.filename. The file is
            % loaded by obj.draw() method to draw the plot.
            warning('Fig:undefinedMethod', 'Compute method is undefined for class %s', class(obj))
        end
        
        function draw(obj)
            % All child classes of Fig should define their own draw method,
            % but may call this function at the beginning to do the setup.
            % The draw method should 
            figure(obj.h)
            clf
        end
        
        function save(obj)
            fname = fullfile(obj.datadir, [class(obj) '.fig']);
            if exist(fname, 'file')
                ff = dir(fname);
                fprintf('File %s already exists! Last modified on %s.\n', fname, ff.date)
                overwrite = input('Do you want to overwrite this file? Y/N [N]: ', 's');
                if ~strcmpi(overwrite, 'y')
                    disp('Figure not saved.')
                    return
                end
            end
            
            saveas(obj.h, fname)
            fprintf('Figure saved as %s.\n', fname)
        end
        
        function load(obj)
            fname = fullfile(obj.datadir, [class(obj) '.fig']);
            obj.h = open(fname);
        end
    end
end