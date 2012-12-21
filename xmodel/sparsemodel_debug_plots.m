% figure
% imsn = 1;
% for iter = 1:200
%     mn(iter) = mean(sn.vpost(imsn, iter));
% end
% plot(mn)
% hold all
% plot(sn.tonicinhib(imsn,:))

% 37 didnt work
imsn = 71;
for iter = 1:sn.niter
    subplot(4,1,1)
    vp = sn.vpost(imsn, iter);
    plot(vp)
    xlabel('Time')
    ylabel('V_p_o_s_t')
    ylim([-1 1])
    title(sprintf('Motif %g', iter))
    
    subplot(4,1,2)
    plot(sn.wH(imsn,:,iter))
    ylim([0 2])
    xlabel('HVC unit')
    ylabel('Weight')

    subplot(4,1,3)
    sn.outvstemplate(iter)
    ylim([0 3])
    
    
    subplot(4,1,4)
    plot(sn.LTP(imsn, iter), 'b')
    hold on
    plot(-sn.LTD(imsn,iter), 'r')
    
    ylim([-0.05, 0.05])
    hold off
    
    pause
end
