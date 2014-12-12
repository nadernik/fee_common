% testing what is a 'significant peak' in the raster to count a simulated
% neuron as firing during a particular syllable; 
% Emily Mackevicius 12/10/2014

nSyl = 5; % number of syllables of that type in bout; 
m = 10; % number of timebins in that syllable; 
nBurst = 1; % number of bursts/syllable; 

for iter = 1:1000; 
    simShuff = zeros(nSyl,m); 
    for i = 1:nSyl;
        tmp = randperm(m); 
        simShuff(i,tmp(1)) = 1; 
    end

    raster = sum(simShuff);
    M(iter) = max(raster); 
end
figure; hist(M, 0:5)