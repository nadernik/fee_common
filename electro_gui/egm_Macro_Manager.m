function handles = egm_Macro_Manager(handles)
%egm_Macro_Manager electro_gui macro that shows/hides other macros
%
% This macro opens a list dialog that asks you to select which macros are
% displayed. Only the selected macros are shown when you click the macros
% button. 
% 
% When a macro is de-selected in this list, it is added to the list of
% excluded macros (handles.MacrosExcluded). This list is stored in your
% defaults file (handles.userfile).
%
% In electro_gui, only macros that are NOT in handles.MacrosExcluded are
% shown when you click the macros button. Therefore, new macros are
% included by default.
%
% The Macro Manager gets special treatment. It can never be excluded from
% your list of macros, and it is always at the top of the macros list.

[egpath, ~, ~] = fileparts(mfilename('fullpath'));
macrofiles = dir(fullfile(egpath, 'egm_*.m'));
macronames = cell(length(macrofiles), 1);
for ii = 1:length(macrofiles)
    % extract 'Macro_name' from 'egm_Macro_name.m'
    tkn = regexp(macrofiles(ii).name, '^egm_(.+)\.m$', 'tokens');
    macronames{ii} = tkn{1}{1};
end

% This macro manager is not included in the list of macros because it can
% never be excluded!
macronames = macronames(~strcmp('Macro_Manager', macronames));

if ~isfield(handles, 'MacrosExcluded')
    handles.MacrosExcluded = {};
end

[selection, ok] = listdlg(...
    'ListString', macronames, ...
    'SelectionMode', 'multiple', ...
    'ListSize', [160 300], ...
    'InitialValue', find(~ismember(macronames, handles.MacrosExcluded)), ...
    'Name', 'Macro Manager for electro_gui', ...
    'PromptString', 'Choose the macros to appear in electro_gui:');

if ok == 1
    % Anything not selected is excluded
    isSelected = ismember(1:length(macronames), selection);
    handles.MacrosExcluded = macronames(~isSelected);
    
    % Redo the macros menu
    macrosmenu = findobj('Type', 'uicontextmenu', 'Tag', 'context_Macros');
    thisitem = findobj('Parent', macrosmenu, 'Label', 'Macro_Manager');
    otheritems = findobj('Parent', macrosmenu, ...
        '-not', 'Label', 'Macro_Manager');
    delete(otheritems)
    % Put macro manager at the top!
    handles.menu_Macros = thisitem;
    jj = 1;
    for ii = 1:length(macronames)
        % If macro is not excluded, add it to the macros menu
        if ~strcmp(macronames{ii}, handles.MacrosExcluded)
            jj = jj + 1;
            handles.menu_Macros(jj) = uimenu(handles.context_Macros, ...
                'Label', macronames{ii}, ...
                'Callback', 'electro_gui(''MacrosMenuclick'',gcbo,[],guidata(gcbo))');
        end
    end
    
    % Write the excluded macros to the defaults file
    oldfile = fopen(handles.userfile, 'r');
    tempfilename = fullfile(tempdir, 'defaultstemp.m');
    newfile = fopen(tempfilename, 'wt');
    while 1
        str = fgetl(oldfile);
        if ~ischar(str) % end of file
            break
        end
        if isempty(regexp(str, 'handles\.MacrosExcluded\s*=', 'once'))
            fwrite(newfile, str);
            fprintf(newfile, '\n');
        end
    end
    str = 'handles.MacrosExcluded = {';
    for ii = 1:length(handles.MacrosExcluded)
        if ii > 1
            str = [str ','];
        end
        str = [str '''' handles.MacrosExcluded{ii} ''''];
    end
    fprintf(newfile, str);
    fprintf(newfile, '};\n');
    fclose(oldfile);
    fclose(newfile);
    movefile(tempfilename, handles.userfile);
end
