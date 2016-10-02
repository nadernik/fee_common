clear all
A0 = h5read('C:\Users\emackev\Downloads\w2v_expansion0.h5', '/w2v'); 
A1 = h5read('C:\Users\emackev\Downloads\w2v_expansion1.h5', '/w2v'); 
A2 = h5read('C:\Users\emackev\Downloads\w2v_expansion2.h5', '/w2v'); 
A = [A0; ...
    A1; ...
    A2]; 
% labels = importdata('C:\Users\emackev\Downloads\common_words.txt'); 
% useind = 1:200; 
% 
% labels = labels(useind); 
% A = A(:,useind); 
% 
% parameters = setRunParameters; 
% parameters.perplexity = 32;
% parameters.training_perplexity = parameters.perplexity;
% [yData,betas,P,errors] = run_tSne(A'+1-min(A(:)), parameters);
% %
% figure(3); clf; plot(yData(:,1), yData(:,2),'.');hold on
% Colors = jet(3); 
% for li = 1:length(labels); 
% %     for ji = 0:2; 
%         Ai = li;
%         text(yData(Ai,1), yData(Ai,2),labels{li})%, 'Color', Colors(ji+1,:))
% %     end
% end

%
changes = sum((cov(A0)-cov(A2)).^2); 
labels = importdata('C:\Users\emackev\Downloads\common_words.txt'); 
[~,sorted] = sort(changes, 'descend'); 
induse = sorted(1:500); 

labels = labels(induse); 
A0 = A0(:,induse); 
A1 = A1(:,induse); 
A2 = A2(:,induse); 

parameters = setRunParameters; 
parameters.perplexity = 50;
parameters.training_perplexity = parameters.perplexity;


% make an embedding for each epoch, seeded at previous epoch
[yData0,betas,P,errors] = run_tSne(A0'+1-min(A0(:)), parameters);
parameters.num_tsne_dim = yData0; 
[yData1,betas,P,errors] = run_tSne(A1'+1-min(A1(:)), parameters);
parameters.num_tsne_dim = yData1; 
[yData2,betas,P,errors] = run_tSne(A2'+1-min(A2(:)), parameters);

%
% plot snake for each word, size based on changes
figure(1); clf; hold on
Colors = repmat(.5-.5*cdfscore(changes)',1,3); 
for i = 1:length(labels)
    plotx = yData2(i,1); %[yData0(i,1) yData1(i,1) yData2(i,1)];
    ploty = yData2(i,2); %[yData0(i,2) yData1(i,2) yData2(i,2)];
    plot(plotx, ploty, '.','Color', [1 1 1]); %Colors(i,:))
    text(yData2(i,1),yData2(i,2), labels{i}, 'fontsize', 5000*changes(i), ...
        'Color', Colors(i,:), 'interpreter', 'none', 'horizontalalignment', 'center')
end
axis off; set(gcf, 'color', 'w')