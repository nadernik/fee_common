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

% delay everything
% keyboard %%%DEBUG
delayed = [zeros(p.stepsDelay,1); timed];
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