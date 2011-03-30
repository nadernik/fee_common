function C = catnanpad(dim, A, B)

finalsize = max(size(A), size(B));
for d = 1:length(finalsize)
    if d == dim
        continue
    end
    
    siz = size(A);
    siz(d) = finalsize(d) - siz(d);
    pad = nan(siz);
    A = cat(d, A, pad);
    
    siz = size(B);
    siz(d) = finalsize(d) - siz(d);
    pad = nan(siz);
    B = cat(d, B, pad);
    
end

C = cat(dim, A, B);