function pathname = PlatformPicker(feebox, folder, UseDialog)
% pathname = PlatformPicker(feebox, folder, UseDialog)
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
        initial_path = '~/../../Volumes';
    end
    if ispc
        % change defaults for different pc
        if strmatch('emily', folder)
            initial_path = 'Y:';
        end
        if strmatch('emackev', folder)
            initial_path  = 'Z:';
        end
        if strmatch('shared', folder)
            initial_path  = 'X:';
        end
    end
    pathname = fullfile(initial_path, folder);
end
