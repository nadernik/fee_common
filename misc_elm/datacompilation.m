%% compiling data recorded During tutoring
clear all; close all; 
XLS = importdata('C:/Users/emackev/Documents/NIfDuringTutoring.xlsx');
Fls = XLS.textdata.Sheet1; 

%XLS.data.Sheet1 = XLS.data.Sheet1(1:46,:); 

artSub = XLS.data.Sheet1(:,1); 
putProj = XLS.data.Sheet1(:,2); 
upProj = XLS.data.Sheet1(:,3); 
downProj = XLS.data.Sheet1(:,4); 
Leftovers = (sum(XLS.data.Sheet1(:,2:end),2)==0);
Cats = {upProj downProj Leftovers}; 
CatNames = {'up proj', 'down proj', 'Leftovers'}; 
indArtSub = zeros(1,length(putProj)); 
for coni = 1:2 % 1 for tutoring 2 for art subsong
    c = 1;
    n{coni} = []; 
    x{coni} = []; 
    dt = .001;
    timepts = -.2:dt:.3; 
    if coni == 1 % tutoring plot
        ind = 2:numel(artSub)+1; % all neurons
    else % artificial subsong plot
        ind = find(artSub)+1; % just neurons where I have art subsong
    end
    for fi = 1:length(ind)
        fi = ind(fi);
        bird = Fls{fi,1}; 
        bird = bird(2:end);
        day = Fls{fi,2};
        depth = Fls{fi,3}; 
        if coni == 1 % tutoring plot
            load(fullfile('Z:\emackev\AcqGui\', bird, day, depth, 'raster'));
        else % artificial subsong plot
            load(fullfile('Z:\emackev\AcqGui\', bird, day, depth, 'rasteras'));
        end
        times = [];
        for i = 1:numel(trigInfo.eventOnsets{1});
            times = [times; trigInfo.eventOnsets{1}{i}];
        end
        [n1,x1] = hist(times, timepts); 
        n1 = n1/numel(trigInfo.eventOnsets{1});
        %n1 = n1/mean(n1); % normalize
        n1 = smooth(n1,10); x1 = smooth(x1,10); %smooth in dt*10 windows
        n{coni}(:,c) = n1; 
        x{coni}(:,c) = x1; 
        c = c+1;
        if coni == 2
            indArtSub(fi) = c; 
        end
    end
    n{coni} = n{coni}/dt; 
end

data.time = mean(x{1},2); 
data.matrix_tutoring = n{1}; 
data.matrix_artSubsong = n{2}; 
data.putProj = putProj; 
data.indArtSub = indArtSub; % tmp = indArtSub(putProj); ind = tmp(find(tmp)); % gives indices of eg put Proj in art subs matrix
data.CatNames = CatNames;
data.Categories = Cats; 
save C:\Users\emackev\Documents\CompiledTutoring.mat data
%% compiling data recorded during singing
clear all; close all; clc
XLS = importdata('C:/Users/emackev/Documents/NIfDuringSingingPutProj.xlsx');
Fls = XLS.textdata.Sheet1; 
PutProj = XLS.data.Sheet1(:,1); 
L1 = XLS.data.Sheet1(:,2); 
FastSpiking = XLS.data.Sheet1(:,3); 
T1Proj = XLS.data.Sheet1(:,4); 
T2Proj = XLS.data.Sheet1(:,5); 
T3Proj = XLS.data.Sheet1(:,6); 
T4Proj = XLS.data.Sheet1(:,7); 
Leftovers = (sum(XLS.data.Sheet1,2)==0);
Cats = {L1 FastSpiking T1Proj T2Proj T3Proj T4Proj Leftovers}; 
CatNames = {'L1', 'Fast Spiking', 'T1 Proj', 'T2 Proj', 'T3 Proj', 'T4 Proj', 'Leftovers'}
h = []; 
n = []; 
x = []; 
dt = .001;
timepts = -.2:dt:.3; 
c = 1; 
ind = 2:size(Fls,1);
for fi = 1:length(ind)
    fi = ind(fi);
    bird = Fls{fi,1}; 
    bird = bird(2:end);
    day = Fls{fi,2};
    depth = Fls{fi,3}; 
    load(fullfile('Z:\emackev\AcqGui\', bird, day, depth, 'raster'));
    times = [];
    for i = 1:numel(trigInfo.eventOnsets{1});
        times = [times; trigInfo.eventOnsets{1}{i}];
    end
    [n1,x1] = hist(times, timepts); 
    n1 = n1/numel(trigInfo.eventOnsets{1});
    %n1 = n1/mean(n1); % normalize
    %n1 = smooth(n1,10); x1 = smooth(x1,10); %smooth in dt*10 windows
    n(:,c) = n1; 
    x(:,c) = x1; 
    c = c+1;
end
n = n/dt; 
data.time = mean(x,2); 
data.matrix = n; 
data.putProj = PutProj; 
data.CatNames = CatNames;
data.Categories = Cats; 

save C:\Users\emackev\Documents\CompiledSinging.mat data
%%
clear all; close all; clc
XLS = importdata('C:/Users/emackev/Documents/NIfHVClesion.xlsx');
Fls = XLS.Sheet1; 
h = []; 
n = []; 
x = []; 
dt = .001;
timepts = -.2:dt:.3; 
c = 1; 
ind = 2:size(Fls,1);
for fi = 1:length(ind)
    fi = ind(fi);
    bird = Fls{fi,1}; 
    bird = bird(2:end);
    day = Fls{fi,2};
    depth = Fls{fi,3}; 
    load(fullfile('Z:\emackev\AcqGui\', bird, day, depth, 'raster'));
    times = [];
    for i = 1:numel(trigInfo.eventOnsets{1});
        times = [times; trigInfo.eventOnsets{1}{i}];
    end
    [n1,x1] = hist(times, timepts); 
    n1 = n1/numel(trigInfo.eventOnsets{1});
    %n1 = n1/mean(n1); % normalize
    %n1 = smooth(n1,10); x1 = smooth(x1,10); %smooth in dt*10 windows
    n(:,c) = n1; 
    x(:,c) = x1; 
    c = c+1;
end
n = n/dt; 
data.time = mean(x,2); 
data.matrix = n; 


save C:\Users\emackev\Documents\CompiledHVClesion.mat data