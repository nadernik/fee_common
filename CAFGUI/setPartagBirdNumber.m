function tags = setPartagBirdNumber(tags, birdnum)
%SETPARTAGBIRDNUMBER 
% 
% Usage:
%   tags = setPartagBirdNumber(tags, birdnum)
% 
%   tags is a struct array containing a field called 'name'. This should be
%      from rules(i).tdtTags
%   birdnum is an integer
%
% This is a utility function for rules.m and rules_multiple_birds.m that
% changes the name of TDT ParTags. 
%
% ParTags are named parameters of software running on the TDT that can be
% set dynamically by a connected PC. The rules GUIs use them to load the
% parameters for the filters designed in the GUI. Each ParTag in each rule
% must be given a unique name. To make names unique, we append two numbers
% on the end: the number of the bird and the number of the rule. The name
% of ParTags is like 'basename_birdnum_rulenum'. This function replaces the
% birdnum.
% 
%
% See also: SETPARTAGRULENUMBER, RULES, RULES_MULTIPLE_BIRDS

for ii = 1:length(tags)
    tags(ii).name = setBirdnumHelper(tags(ii).name, int2str(birdnum));
end

function nameNew = setBirdnumHelper(nameOld, birdnumNew)
% Regular expression patterns
patternBirdnumRulenum = '^(.+)_(\d+)_(\d+)$'; % like 'basename_##_##' (note that anything that matches this pattern will also match the less stringent pattern below)
patternRulenumOnly = '^(.+)(\d+)$'; % like 'basename##'

tokensBirdnumRulenum = regexp(nameOld, patternBirdnumRulenum, 'tokens');
tokensRulenumOnly = regexp(nameOld, patternRulenumOnly, 'tokens');

if ~isempty(tokensBirdnumRulenum)
    % Has bird number and rule number. Just replace the bird number
    basename   = tokensBirdnumRulenum{1}{1};
    birdnumOld = tokensBirdnumRulenum{1}{2};
    rulenum    = tokensBirdnumRulenum{1}{3};
elseif ~isempty(tokensRulenumOnly);
    % Has only one number. Assume it is a rule number and add a bird number
    % before it.
    basename = tokensRulenumOnly{1}{1};
    rulenum  = tokensRulenumOnly{1}{2};
else
    % Has no numbers. Use the whole name as a base name and add the
    % specified bird number as well as a rule number (set to 1)
    basename = nameOld;
    rulenum = 1;
end
nameNew = [basename '_' birdnumNew '_' rulenum];