function initial_path = PlatformPicker(feebox, share, UseDialog)
% pathname = PlatformPicker(feebox, share, UseDialog)
% e.g. PlatformPicker(feebox1, shared, code)
% makes folder names consistent across mac and pc.  For now, you need to
% set the default mapped network drives on your pc.  If UseDialog is true,
% then you can pick manually.
% Emily Mackevicius Feb 14 2013
if nargin == 2
    UseDialog = 0;
end
if UseDialog
    pathname = uigetdir('', 'Choose the directory');
else
    if ismac
        initial_path = fullfile('~', share);
    end
    if ispc
        % change defaults for different pc
        if strmatch('emily', share)
            initial_path = 'Y:';
        end
        if strmatch('emackev', share)
            initial_path  = 'Z:';
        end
        if strmatch('shared', share)
            initial_path  = 'X:';
        end
    end
end
