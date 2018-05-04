function p = setSortedRastersParams_elm(row, XLS, Columns)
load('C:\Users\emackev\Documents\MATLAB\code\misc_elm\sort_rast_params_elm.mat', 'p') % sorted raster parameters

dbase = getDbase_elm(row, XLS, Columns);
fs = dbase.Fs;
nFiles = length(dbase.SegmentTimes); 

p.FileRange = 1:nFiles; 
p.EventSource = XLS.data.Sheet1(row,strmatch('spikeEventNum', Columns));

% p.Alignment = 'Onset'; 
% p.TriggerSyllIncluded = ''; % change to include only certain syllables
% p.WindowLimits = [.2 .3]; 
% p.RasterXLim = [-.2 .3];
% p.RasterYAxis = 'Trial #'; 
% p.PsthBinSize = .005; 
% p.PsthYLim = [0 50]; 
% p.VerticalHistogramShow = 0; 
% p.Output = 'raster';
% save('C:\Users\emackev\Documents\MATLAB\code\misc_elm\sort_rast_params_elm.mat', 'p')