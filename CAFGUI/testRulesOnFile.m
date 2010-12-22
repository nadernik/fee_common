function [bNoise, varargout] = testRulesOnFile(handles, audio)
Fs = 24414; %Hz, TDT sampling rate
% get list of rules to test
toTest = handles.list2rule;%(get(handles.listRules,'Value'));
tested = zeros(size(toTest));
% evaluate each rule
bRuleMet = [];
while ~all(tested)
    evalFlag = 0;
    for r = toTest(~tested)
        rTested = toTest(logical(tested));
        dep = handles.rules(r).params.dependencies;
        if isempty(dep) || ... % if no dependencies
            all(ismember(dep, rTested)) % if all dependencies met
        bRuleMet(:,r) = feval(handles.rules(r).params.filterFunc, audio, handles.rules(r).params, bRuleMet);
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
    if handles.rules(r).actionNoise
        bNoise(logical(bRuleMet(:,r))) = 1;
    end
end
