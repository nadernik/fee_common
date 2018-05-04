function DFFmedFil = DeltaFOF_elm(F,VIDEOfs)
% parameters
tau0 = .05; % changed from .2 for 6s
tau1 = .25; % changed from .75 for 6s
tau2 = 1; % changed from 3 for 6s

% initialize 
F0 = F;
DFFmedFil = F;

nFrames = size(F,2); 
nSigs = size(F,1); 

% Calculate the time-dependent baseline F0(t) for each signal
smwin = round(tau1*VIDEOfs)-1; 
Fbar = conv2(F,[0 ones(1,smwin)/(smwin) 0] , 'valid');
Fbar = [F(:,1:floor((smwin+1)/2)) Fbar F(:,(end+1-ceil((smwin+1)/2)):end)]; % dealing with edges
for fi = 2:nFrames
    win = max(1, (fi-tau2*VIDEOfs)):(fi-1); 
    F0(:,fi) = min(Fbar(:,win),[],2); 
end


% Calculate the relative change of fluorescence signal R(t) from F and F0
R = (F - F0)./F0; 

% Apply noise filtering 
wind = floor(-tau0*VIDEOfs):ceil(tau0*VIDEOfs);
for fi = 1:nFrames
%     w = exp(-(1:fi)/(tau0*VIDEOfs)); 
%     w = repmat(w(:)', size(F,1),1); 
%     DFF(:,fi) = sum(R(:,fi:-1:1).*w,2)./sum(w,2); 
    indwin = fi + wind; indwin(indwin<=0) = []; indwin(indwin>nFrames) = []; 
    DFFmedFil(:,fi) = median(R(:,indwin),2);
end
