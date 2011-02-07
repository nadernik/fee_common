function [bRuleMet, varargout] = booleanFilterFunc(sig, p, r)

% do ANDs and ORs
temp = true(size(r,1),1);
for q = 1:length(p.query)
    if p.query(q).invert
        temp = feval(p.query(q).func,temp,~r(:,p.query(q).rule));
    else
        temp = feval(p.query(q).func,temp,r(:,p.query(q).rule));
    end
end

% filter to find when it is true for the min time interval
kernel = ones(1,p.stepsAbove) / p.stepsAbove;
timed = filter(kernel,1,temp) >= (1-2/p.stepsAbove);

% delay
%   The TTLDelay outputs a 1 after the assigned delay, but stays high for
%   only one sample. It is like doing a rising edge detect and then
%   delaying the resulting signal.
edge = [false; diff(timed) == 1]; % detect rising edge
delayed = [zeros(p.stepsDelay,1); edge];
delayed = delayed(1:end-p.stepsDelay);

% schmitt trigger
if p.stepsHigh == 0
    bRuleMet = delayed;
else
    kernel = ones(1,p.stepsHigh);
    bRuleMet = filter(kernel,1,delayed) > 1/2;
end

if nargout > 1
    varargout{1} = temp;
end
% keyboard