function Latency = findHVClatency(xsort, m, trainingNeurons)
% Emily Mackevicius 11/25/2014, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 

xplot = zeros(size(xsort,1),2*m);
for ni = 1:size(xsort,1) % finding the mode latency for each syll type
    tmp = find(xsort(ni,:)); 
    tmp1 = intersect(tmp,find(trainingNeurons{1}.tind))'; % times the neuron fired during syl 1
    tmp2 = intersect(tmp,find(trainingNeurons{2}.tind))'; % times the neuron fired during syl 2
    if issame(trainingNeurons{1}.tind,trainingNeurons{2}.tind) % if sylls are the same (protosyllables), split by halves for raster
        Latency{1}.FireDur(ni) = length(tmp1)>1;
        Latency{2}.FireDur(ni) = length(tmp2)>1;
        tmp1 = intersect(tmp,1:(size(xsort,2)/2));
        Latency{1}.mode(ni) = mode(mod(tmp1-1,m))+1;
        tmp2 = intersect(tmp,(size(xsort,2)/2+1):size(xsort,2));
        Latency{2}.mode(ni) = mode(mod(tmp2-1,m))+1;
    else
        if length(tmp1)>0 % if it fired in syllable 1
            Latency{1}.mode(ni) = mode(mod(tmp1-1,m))+1; % mode phase
            Latency{1}.num(ni) = sum(mod(tmp1-1,m)==mode(mod(tmp1-1,m))); % number of times it fired at that phase
        else
            Latency{1}.mode(ni) = NaN; % mode phase
            Latency{1}.num(ni) = NaN; % number of times it fired at that phase
        end
        if length(tmp2)>0 % if it fired in syllable 2
            Latency{2}.mode(ni) = mode(mod(tmp2-1,m))+1; % mode phase
            Latency{2}.num(ni) = sum(mod(tmp2-1,m)==mode(mod(tmp2-1,m))); % number of times it fired at that phase
        else
            Latency{2}.mode(ni) = NaN; % mode phase
            Latency{2}.num(ni) = NaN; % number of times it fired at that phase
        end
        Latency{1}.FireDur(ni) = (Latency{1}.num(ni) > 2); 
        Latency{2}.FireDur(ni) = (Latency{2}.num(ni) > 2);
    end
end