function propvalue = eg_GetProperty(handles, filenum, propname)
% Get value of electro_gui property

ndx = strcmp(handles.Properties.Names{filenum}, propname);
if ~any(ndx)
    error('No property named ''%s'' for file %g.', propname, filenum)
end
propvalue = handles.Properties.Values{filenum}{ndx};

