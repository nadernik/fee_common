clear all; close all
%% case where A and B can run together...
nSyl =3; 
N = 100;
T = 10000; % 1 motif = N timesteps. 
nkeep = 50; 
pspk = .7;
pshared = 0;
ColorBySyl = 1; 

sylStart = 1:floor(N/nSyl):N; 
if sylStart(end) ~=N
    sylStart(end+1) = N; 
end

n = 1; 
n1 = 1; 
rnd = 0; 
Firing = zeros(N,T); 
syl = [];
btime = cell(1,N);
for t = 1:T
    if intersect(n, [sylStart N+1])
        seed = randperm(nSyl); 
        n = sylStart(seed(1)); 
        n1 = sylStart(1)*(seed(1)==2) + sylStart(2)*(seed(1)==1);
        rnd = rand; 
    end
    if (seed(1) == 1 | seed(1) == 2) & rnd>(1-pshared)
        %n = sylStart(1);
        %n1 = sylStart(2); 
        Firing(n,t) = rand>(1-pspk);
        Firing(n1,t) = rand>(1-pspk);
        if Firing(n,t)
            btime{n} = [btime{n} t]; 
        end 
        if Firing(n1,t)
            btime{n1} = [btime{n1} t]; 
        end
        n = n+1;
        n1 = n1+1;
    else
        syl(t) = seed(1); 
        Firing(n,t) = rand>(1-pspk);
        if Firing(n,t)
            btime{n} = [btime{n} t]; 
        end
        n = n+1;
    end
end

% jittering burst times...
jstd = 1; 
Firingj = zeros(N,T); 
for n = 1:N
    if length(btime{n})>0
        btime{n} = btime{n} + round(jstd*rand(1,size(btime{n},1)));
        Firingj(n,btime{n}) = 1; 
    end
end

%

keepneurons = randperm(N);
keepneurons = keepneurons(1:nkeep); 
keepneurons = sort(keepneurons,'ascend');
Firingj = Firingj(keepneurons,:); 
Firingorig = Firing(keepneurons,:); 
clear Firing
%figure(1); imagesc(Firingorig);shg
%%
SimData = {Firingorig Firingj}; 
tmp = jet(nSyl);
ColorInOrder = zeros(nkeep,3); 
for i = 1:1%nSyl
    ind = zeros(1,N); 
    ind(sylStart(i):sylStart(i+1)) = 1; 
    ind = ind(keepneurons); 
    lind = ind==1; 
    ColorInOrder(lind,:) = repmat(tmp(i,:),length(find(lind)),1); 
end
%ColorInOrder = jet(nkeep); 
for fi = 1:2
    Firing = SimData{fi}; 
    figure(fi); clf
    for t = 1:T+(sum(Firing)-T)
        if sum(Firing(:,t))>1
            ind = find(Firing(:,t)); 
            mixind = ind(randperm(length(ind))); 
            insert = zeros(nkeep, length(ind)); 
            for j = 1:length(ind)
                insert(mixind(j),j) = 1; 
            end
            Firing = [Firing(:,1:(t-1)) insert Firing(:,(t+1):end)];
        end
    end
    A = bsxfun(@(X,Y)(X.*Y), Firing, (1:size(Firing,1))');
    A = sum(A);
    A = A(find(A));
    sylA = syl(find(A)); 
    TRANS = mmELM(A); %[TRANS,EMIS] = hmmestimate(A,A);
    subplot(2,2,1:2)
    imagesc(Firing(:,1:400)); colormap gray
    subplot(2,2,3)
    imagesc(TRANS'); colormap gray; shg
    subplot(2,2,4); hold off;  hold all
%     TRANS1 = TRANS; 
%     DB = zeros(size(TRANS,1));
%     for i = 1:size(TRANS,1)
%         for j = 1:size(TRANS,1)
%             DB(i,j) = entropy(TRANS(i,:))+entropy(TRANS(:,j)); 
%         end
%     end
%     DB = DB/max(DB(:))/2; DB = 1-DB;
    S = ((TRANS)+(TRANS)'); 
    D = (1-S); 
    D = D-min(D(:)); 
    D = D.*~eye(size(TRANS,1)); 
    D = D/max(D(:));
    [Y,e] = cmdscale(D);
    Y = mdscale(D,3, 'Criterion', 'strain');%, 'Weights', DB); 
    msize = 500; 
    lwidth = 1; 
    %plot3(Y(:,1),Y(:,2),Y(:,3),'k.', 'Markersize', msize);shg
    MeasureSpread = @(X)(entropy(X)); 
    %thesinoutdeg = MeasureSpread(TRANS(:))*.7;
    ColorByInOutDeg = zeros(size(TRANS,1),3);
    for i = 1:size(TRANS,1)
        for j = i:size(TRANS,2)
            ind = [i j];
            if D(i,j)~=1
                plot3(Y(ind,1), Y(ind,2),Y(ind,3),'k', 'color', D(i,j)*ones(1,3), 'linewidth', lwidth, 'Markersize', msize);shg
            end
        end
        ColorByInOutDeg(i,:) = [MeasureSpread(TRANS(i,:)) MeasureSpread(TRANS(:,i)) 0];
    end
    tmp = ColorByInOutDeg(:,[1 2]); 
    tmp = exp(tmp);
    tmp = zscore(tmp); 

    tmp = bsxfun(@(X,Y)(X/Y/2), tmp, max(abs(tmp))); 
    tmp = tmp + .5; 
    tmp = bsxfun(@(X,Y)(X/Y), tmp, max(abs(tmp))); 
    ColorByInOutDeg(:,[1 2]) = tmp;
    hold on
    %bsxfun(@(X,Y)(X/Y), ColorByInOutDeg(:,[1 2]), max(ColorByInOutDeg(:,[1 2]))); 
    if ColorBySyl
        scatter3(Y(:,1), Y(:,2), Y(:,3), '.','SizeData', msize*ones(1,size(Y,1)), ...
            'cdata', ColorInOrder(1:size(Y,1),:));%ColorByInOutDeg);shg
    else
        scatter3(Y(:,1), Y(:,2), Y(:,3), '.','SizeData', msize*ones(1,size(Y,1)), ...
            'cdata', ColorByInOutDeg);%ColorByInOutDeg);shg
    end

    scatter3(Y(:,1), Y(:,2), Y(:,3), 'o', ...
        'cdata', ColorByInOutDeg);shg
end
