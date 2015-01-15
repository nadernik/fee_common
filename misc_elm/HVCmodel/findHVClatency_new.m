function Latency = findHVClatency_new(xsort, trainingNeurons)
% Calculates the mode latency of each neuron
% w: weight matrix
% xdyn: activity of network
% m: duration of one syllable, in timesteps
% trainingNeurons: cell array of structures containing neuron and time indices for each syllable type
% PlottingParams: sets linewidth, etc.  See RunHVC_split
%
% Emily Mackevicius 12/10/2014, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 
%%
nsteps = size(xsort,2); 
n = size(xsort,1); 

% iterate over candidate latencies
for syli = 1:length(trainingNeurons)
    nFired = zeros(n,length(trainingNeurons{syli}.candLat));
    for lati = 1:length(trainingNeurons{syli}.candLat); 
        tInds = zeros(1,nsteps); 
        tInds(min(nsteps, trainingNeurons{syli}.tind + trainingNeurons{syli}.candLat(lati))-1) = 1; 
        nFired(:,lati) = sum(bsxfun(@times, xsort, tInds),2); % number of times each neuron fired at this latency
    end
    for ni = 1:n
        [~, Latency{syli}.mode(ni)] = max(nFired(ni,:)); 
        Latency{syli}.mode(ni) = trainingNeurons{syli}.candLat(Latency{syli}.mode(ni)); 
        Latency{syli}.FireDur(ni) = max(nFired(ni,:))>trainingNeurons{1}.thres*(syli==1)+trainingNeurons{2}.thres*(syli==2); %.25*length(trainingNeurons{syli}.tind);  % count if it fired at that latency in more than 1/4 of the syllables
    end
end