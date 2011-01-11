function t = vc_feat_threshtime(sig, thresh, tmax)

t = find(sig > thresh, 1, 'first');
if isempty(t) || t > tmax
    t = tmax;
end