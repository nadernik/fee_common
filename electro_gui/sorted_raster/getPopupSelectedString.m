function str = getPopupSelectedString(obj)
options = get(obj, 'String');
str = options{get(obj, 'Value')};