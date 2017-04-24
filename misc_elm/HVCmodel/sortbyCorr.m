function perm = sortbyCorrCA(W)
    DisMatrix = W; %W*W' + W'; %W*W'+W'*W+10*W'; %W*W' + W' sometimes works pretty well
    me = find(max(max(W))); 
    togo = [(1:(me-1)) ((me+1):size(DisMatrix,1))]; 
    for i = 1:length(W)-1
        %indPlot(i) = i;
        %[~,indPlot(i)] = max(EW(:,indPlot(i-1))); 
        %eliPlot(i-1) = 0; 
        [~,next] = max(DisMatrix(me(end),togo));
        me(end+1) = togo(next);
        togo(next) = [];
    end
    perm = me; 