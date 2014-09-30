%%
annotate_exper('3989', '2014-04-25', 'edgeSyllThreshold', -6, ...
    'triggerSyllThreshold', -5, 'bDebug', true, 'filenum', 18)

%%
annotate_exper('3989', '2014-04-25', 'edgeSyllThreshold', -6, ...
    'triggerSyllThreshold', -5, 'bDebug', false, 'filenum', 1:250)

%%
labeledspecgram('3989', '2014-04-25')

%%
rules