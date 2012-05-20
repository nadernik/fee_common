assert(all(sum(hvc_output) == globalmax(hvc_output))) % sum of hvc output must be constant at every time step
[h, t] = find(hvc_output == globalmax(hvc_output));
t = t(h);
w = squeeze(msn_output(:,t,:));