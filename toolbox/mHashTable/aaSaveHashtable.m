function aaSaveHashtable(filename, hash)
if(~hash.isEmpty)
    keys = hash.keys;
    elements = hash.elements;
    save(filename, 'keys', 'elements','-v6');
else
    keys = {};
    elements = {};
    save(filename, 'keys', 'elements','-v6');
end