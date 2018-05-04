function annomove(birdname1, expername1, rootdir1, birdname2, expername2, rootdir2)
% Move annotation files
filestodelete = {};
for p = 1:1000
    pitchfileold = annofilename(birdname1, expername1, 'Part', p, 'RootDir', rootdir1, 'Type', 'pitch');
    pitchfilenew = annofilename(birdname2, expername2, 'Part', p, 'RootDir', rootdir2, 'Type', 'pitch');
    annofileold  = annofilename(birdname1, expername1, 'Part', p, 'RootDir', rootdir1, 'Type', 'annotation');
    annofilenew  = annofilename(birdname2, expername2, 'Part', p, 'RootDir', rootdir2, 'Type', 'annotation');
    audiofileold = annofilename(birdname1, expername1, 'Part', p, 'RootDir', rootdir1, 'Type', 'audio');
    audiofilenew = annofilename(birdname2, expername2, 'Part', p, 'RootDir', rootdir2, 'Type', 'audio');
    miscfileold  = annofilename(birdname1, expername1, 'Part', p, 'RootDir', rootdir1, 'Type', 'misc');
    miscfilenew  = annofilename(birdname2, expername2, 'Part', p, 'RootDir', rootdir2, 'Type', 'misc');
    
    if ~exist(annofileold, 'file')
        break
    end
    
    load(annofileold, 'keys', 'elements')
    h = aaLoadHashtable(annofileold);
    newkeys = regexprep(keys, '.+(_d\d{6}_\d{8}T\d{6}chan\d\.dat)', [birdname2 '$1']);
    for ii = 1:length(keys)
        elem.newkey = newkeys{ii};
        h.put(keys{ii}, elem);
    end
    
    if exist(pitchfileold, 'file')
        load(pitchfileold, 'pitch')
        pitch.annotationName = annofilenew;
        pitch = updateSegKeys(pitch, h);
        save(pitchfilenew, 'pitch')
        filestodelete{end+1} = pitchfileold;
    end
    
    if exist(miscfileold, 'file')
        load(miscfileold, 'misc')
        misc.annotationName = annofilenew;
        misc = updateSegKeys(misc, h);
        save(miscfilenew, 'misc')
        filestodelete{end+1} = miscfileold;
    end
    
    if exist(audiofileold, 'file')
        load(audiofileold, 'rawaudio')
        rawaudio.annotationName = annofilenew;
        rawaudio = updateSegKeys(rawaudio, h);
        save(audiofilenew, 'rawaudio')
        filestodelete{end+1} = audiofileold;
    end
    
    keys = newkeys;
    newexper = elements{1}.exper;
    newexper.birdname = birdname2;
    newexper.expername = expername2;
    newexper.dir = [fullfile(rootdir2, birdname2, expername2) filesep];
    for ii = 1:length(elements)
        elements{ii}.exper = newexper;
    end
    save(annofilenew, 'keys', 'elements')
    filestodelete{end+1} = annofileold;
end

for ii = 1:length(filestodelete)
    delete(filestodelete{ii})
end
end

function a = updateSegKeys(a, h)
for s = 1:length(a.segs)
    elem = h.get(a.segs(s).key);
    a.segs(s).key = elem.newkey;
end
end
