function aSAP_zPrivate_FileBrowserTimerFcn(obj, event, callbackFcnName, varargin)
%Trick to allow a timer callback function to be a subfunction in the gui.m
%file.

%Notes this trick might not be necessary if you use a function handle
%during timer initialization instead of a string.


fb = findobj('Tag','aSAP_FileBrowser');
aSAP_FileBrowser(callbackFcnName, fb, varargin{:});