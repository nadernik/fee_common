function daq_deleteListeners()
global GLISTENERS;
for lNo = 1:numel(GLISTENERS)
    delete(GLISTENERS{lNo});
end
end