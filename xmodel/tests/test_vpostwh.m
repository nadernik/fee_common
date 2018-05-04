%% 
% Upon changing Vpost from just noise to noise + w*H I observed very little
% change in performance. I hypothesize that because the coverage is
% relatively high, the bias contribution from each MSN is low. The low bias
% is caused by a low weight which in turn would give a low w*H. A small w*H
% compared to the rest of the terms in Vpost may be the reason adding w*H
% had such a small effect. Here I compare the values of vpost with and
% without w*H

vpost_yeswh = zeros(sn.nmsn, sn.nhvc, sn.niter);
vpost_nowh  = zeros(sn.nmsn, sn.nhvc, sn.niter);
for iter = 1:sn.niter
    fprintf('Calculating trial %g/%g\n', iter, sn.niter)
    for imsn = 1:sn.nmsn
        vp = sn.vpost(imsn, iter);
        wh = sn.wH(imsn, :, iter) * sn.hvcout;
        vpost_yeswh(imsn, :, iter) = vp;
        vpost_nowh( imsn, :, iter) = vp - wh;
    end
end

%%
imsn = 1;
for iter = sn.niter
    plot(vpost_yeswh(imsn,:,iter), 'r')
    hold on
    plot(vpost_nowh(imsn,:,iter), 'k')
    hold off
    title(sprintf('MSN %g on trial %g', imsn, iter))
    xlabel('Time')
    ylabel('V_p_o_s_t')
    pause
end