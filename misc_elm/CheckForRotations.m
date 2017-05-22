%% checking for rotations
savedir = 'U:\ProcessedCalciumData\AllRows'; %'Z:\emackev\inscopix'; 'C:\Users\emackev\Documents\StuffICanDelete';

CheckRows = ([3730 3739 3781 4024 4048 4061]); %[1181:5:1211 1212:1214]; %1046:8:1145
COMP = []; 
COMPT = []; 
for rowi = 1:numel(CheckRows)
    load(fullfile(savedir, ['CaELM_row' num2str(CheckRows(rowi))]), 'VIDEO'); 
    tmp = squeeze(median(VIDEO,1)); 
    COMP = [COMP tmp]; 
    COMPT = [COMPT; tmp]; 
    clf; imagesc(tmp); title(num2str(CheckRows(rowi)))
    axis image; axis tight; colormap gray;drawnow; shg
%     sound(sin(1:1000))
    CheckRows(rowi)
end
tmp = repmat(COMP,numel(CheckRows),1) - ...
    repmat(COMPT,1,numel(CheckRows)); 
imagesc(abs(tmp))
set(gca, 'xtick', size(VIDEO,3)*((1:numel(CheckRows))-.5),...
    'xticklabel', arrayfun(@num2str, CheckRows, 'uniformoutput', 0))
set(gca, 'ytick', size(VIDEO,2)*((1:numel(CheckRows))-.5),...
    'yticklabel', arrayfun(@num2str, CheckRows, 'uniformoutput', 0))
