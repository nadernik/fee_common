function Brainbow = neuron2brainbow(A,C,nColors)
% normalize by spatial footprint
    prc = 5;   
    sA = sum(A,1);
    A = bsxfun(@rdivide, A, sA)*prctile(sA, prc); 
    
% normalize temporal 
    sC =  prctile(C(:),99); 
    baselines = min(C,[],2); 
    C = bsxfun(@minus, C, baselines); 
    C = bsxfun(@rdivide, C, max(sC, max(C,[],2)));
    C(C<0) = 0; C = (3*C+.5)/2; 

    k = size(C,1); 

    % 
    Ir = diag(1-nColors(:,1)); 
    Ig = diag(1-nColors(:,2)); 
    Ib = diag(1-nColors(:,3)); 

    Brainbow = 1-cat(3, A*Ir*C, A*Ig*C, A*Ib*C); 
    Brainbow = reshape(Brainbow, 300,400, size(C,2), 3); 
    Brainbow = permute(Brainbow, [1 2 4 3]); 
end