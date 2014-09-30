function [bNoise, varargout] = testRulesOnFile(rules, audio)
toTest = find([rules.visible] == 1); % only test visible rules
tested = zeros(size(toTest));
% evaluate each rule
bRuleMet = [];
while ~all(tested)
    evalFlag = 0;
    for r = toTest(~tested)
        rTested = toTest(logical(tested));
        dep = rules(r).params.dependencies;
        if isempty(dep) || ... % if no dependencies
            all(ismember(dep, rTested)) % if all dependencies met
        bRuleMet(:,r) = feval(rules(r).params.filterFunc, audio, rules(r).params, bRuleMet);
        tested(toTest==r) = 1;
        evalFlag = 1;
        end
    end
    if ~evalFlag
        % if there are some rules that can't be evaluated, error
        errordlg('Cannot evaluate rules because dependencies cannot be met.')
        return
    end
end

% use noise-determining rule(s)
bNoise = zeros(size(audio));
for r = toTest
    if rules(r).actionNoise
        bNoise(logical(bRuleMet(:,r))) = 1;
    end
end
