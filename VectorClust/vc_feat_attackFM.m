function [b,bint,r,rint,stats] = vc_feat_attackFM(p,Fs)
% ATTACKFM finds the frequency modulation at the beginning of syllables

try
    
    % in p each column is a time point and each row is a frequency band
    
    % threshold power. when power in a particular frequency band crosses this
    % threhold, then it has "attacked". It should be low enough so that most
    % frequency bands start out below it but cross it before t_max (see below)
    pthresh = -100;
    
    % time window to look for attacks, in seconds. This will be the upper bound
    % of times of attack. If an attack is not found within this window, the
    % attack time for that frequency band will be set to NaN.
    t_max = 0.06;% seconds
    
    % convert sampling frequency to sample period
    dt = 1/Fs;
    
    % make sure that the max attack time is not longer than the syllable
    syllableDuration = dt * size(p,2);
    t_max = min(t_max, syllableDuration);
    
    % convert max attack time to number of points
    N_max = floor(t_max/dt);
    
    % number of frequency bands
    Np = size(p,1);
    
    t_attack = nan(Np,1);
    for n = 1:Np
        % for each frequency band
        
        % find the attack time (threshold crossing)
        temp = find(p(n,1:N_max) > pthresh, 1,'first');
        if ~isempty(temp)
            t_attack(n) = temp;
        end
        
        
    end
    
    
    % fit a line to attack times as a function of frequency band and return the
    % slope. include a constant term.
    X = [ones(Np,1) (1:Np)'];
    [b,bint,r,rint,stats] = regress(t_attack, X);
%     scatter(1:Np,t_attack)
catch
    debugdisp('Error in attackFM:')
    debugdisp(lasterr)
    b = [0 0];
    bint = [0 0; 0 0];
    r = zeros(size(t_attack));
    rint = [r r];
    stats = [0 0 0 0];
end
