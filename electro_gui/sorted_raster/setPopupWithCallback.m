function setPopupWithCallback(obj, cbname, str)
options = get(obj, 'String');
val = find(strcmp(str, options));
if isempty(val)
    error('Invalid choice for %s: %s\nValid choices are: %s', ...
        get(obj, 'Tag'), str, strjoin(options, ', '))
end
setIfEnabled(obj, 'Value', val)
callbackIfEnabled(cbname, obj, [], guidata(obj))