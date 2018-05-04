function str = summarizeRule(r)
%SUMMARIZERULE Short text summary of CAF rules
%
% str = SUMMARIZERULE(r)
%
% r is a struct array containing rules for CAF created by rules.m or
% CAFrules.m
%
% str is a cell array of strings the same length as r, where each element
% is the text summary of the corresponding rule in r. If length(r) == 1,
% then str is just a string (not a cell array).
%
% The text contents of each rule is set in ruleConditions.m


str = cell(size(r));
c = ruleConditions;

for nr = 1:length(r)
    nc = r(nr).condition;
    params = cell(size(c(nc).summaryParams));
    for np = 1:length(c(nc).summaryParams)
        pname = c(nc).summaryParams{np};
        params{np} = r(nr).params.(pname);
    end
    str{nr} = sprintf(c(nc).summaryFormat, params{:});
end

if length(str) == 1;
    str = str{1};
end