function combinedgroups = graphSplit(w, xdyn, k, wmax)

cla
n=length(w);
w(w<wmax/10)=0;

ITI = mode(diff(find(xdyn(1,:)>0))); % Inter-trial interval for external input
trainint = mean(diff(find(mean(xdyn(1:k,:))>0)));
if ITI>trainint; split = 1; else split = 0; end

tstart = trainint*2;
xdyn1 = xdyn(:,tstart + (1:trainint));
if split
    xdyn2 = xdyn(:,tstart + (trainint+1:trainint*2)); % split
else
    xdyn2 = zeros(size(xdyn1));
end

%% Group 1
[activity1, groups1] = max(xdyn1,[],2);
activity1 = activity1>eps;
groups1(~activity1) = NaN;

%% Group 2
[activity2, groups2] = max(xdyn2,[],2);
activity2 = activity2>eps;
groups2(~activity2) = NaN;

%% Label each cell with overlap between groups
combinedgroups = groups1;
combinedgroups(~isnan(groups2)&isnan(groups1)) = groups2(~isnan(groups2)&isnan(groups1));
x = combinedgroups; % x pos in graph

%% Calculate y position in graph
y = NaN(n,1); % y pos in graph

ngroups = max(x);

if split
offset1 = k/4+1;
offset2 = -offset1;
else
    offset1 = 0;
    offset2 = 0;
end

for i = 1:ngroups
    nAll = nnz(x==i);    
    n1 = nnz(groups1==i);
    n2 = nAll-n1;
    curr_y1s = (1:n1)-mean(1:n1) + offset1;
    
    curr_y2s = (1:n2)-mean(1:n2) + offset2;
    
    y(groups1==i) = curr_y1s;
    y(groups2==i & groups2~=groups1) = curr_y2s;
end

%% Plot graph
cla
[i, j] = find(w);
[~, p] = sort(max(i,j));

i = i(p);
j = j(p);

X = [x(i) x(j)]';
Y = [y(i) y(j)]';

% [X Y]=gplot(w, [x y]);

h = plot(X,Y,'o-k','MarkerFaceColor','k'); % Main plot

% Change colors of lines according to synapse strength
val = w(w>0);
val = val(p)/wmax; 

strength  = mat2cell(val,ones(1,length(val)),1);
colors  = mat2cell(repmat(1-val,1,3),ones(1,length(val)),3);
% colors(X(1,:)==X(2,:)) = {[1 0 0]}; % Vertical connections red
longcnx = abs(diff(X))>1;
colors(longcnx) = {[.8 .8 .8]};

order = [find(~longcnx)  find(longcnx)];
set(gca,'Children',h(order))
set(h,{'LineWidth'},strength)
set(h,{'Color'},colors)
set(h,'MarkerEdgeColor','k','MarkerSize',4)

% Plot training set in red
hold on; plot(x(1:k),y(1:k),'ro','MarkerFaceColor','r','MarkerSize',5)
xlim([.9 trainint+.1]); 
ylim([-k/2-3 k/2+3]); 
axis off; box off
set(findall(gca,'-property','FontSize'),'FontSize',2)
