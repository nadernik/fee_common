function annoappend(exper, newanno, newpitch, newmisc, newrawaudio)
% ANNOAPPEND 

files_to_add = length(newanno);
newkeys = newanno.keys;
newelements = newanno.elements;
maxFilesPerAnnotation = 300; %FIXME
startfile = 1;
% find the latest annotation file and load it
part = 1;
while true
    annofile = annofilename(exper.birdname, exper.expername, 'Part', part);
    if ~exist(annofile, 'file')
        part = part - 1;
        break
    else
        part = part + 1;
    end
end
annofile   = annofilename(exper.birdname, exper.expername, 'Part', part, 'Type', 'annotation');
pitchfile  = annofilename(exper.birdname, exper.expername, 'Part', part, 'Type', 'pitch');
miscfile   = annofilename(exper.birdname, exper.expername, 'Part', part, 'Type', 'misc');
audiofile  = annofilename(exper.birdname, exper.expername, 'Part', part, 'Type', 'audio');


% while we have more files to add
while files_to_add > 0

	% load annotation
	if exist(annofile,'file')
		load(annofile); % load varaibles 'keys' and 'elements'
		load(pitchfile) % loads variable 'pitch'
		load(miscfile) % loads variable 'misc'
        load(audiofile)
	else % need to create a new annotation file
		keys = [];
		elements = [];
		pitch.segs = [];
        pitch.bRand = [];
        misc.segs = [];
		misc.bRand = [];
	end
	
	% Add files to annotation.
	endfile = min(length(newkeys), startfile + maxFilesPerAnnotation - length(keys) - 1);
	segndx = segs_with_keys(newpitch.segs, newkeys(startfile:endfile));
	keys     = [keys     newkeys(startfile:endfile)    ];
	elements = [elements newelements(startfile:endfile)];
    pitch.segs = [pitch.segs, newpitch.segs(segndx)];
    pitch.bRand = [pitch.bRand; newpitch.bRand(segndx)];
    misc.segs = [misc.segs, newmisc.segs(segndx)];
    misc.bRand = [misc.bRand; newmisc.bRand(segndx)];
    rawaudio.segs = [rawaudio.segs, newrawaudio.segs(segndx)];
    rawaudio.bRand = [rawaudio.bRand; newrawaudio.bRand(segndx)];
	
	% save files
	save(annofile, 'keys', 'elements')
	save(pitchfile, 'pitch')
	save(miscfile,  'misc')
    save(audiofile, 'rawaudio')
	
	% housekeeping for next iteration
	files_to_add = files_to_add - (endfile - startfile);
	startfile = endfile + 1;
	part = part + 1;	
    annofile   = annofilename(exper.birdname, exper.expername, 'Part', part, 'Type', 'annotation');
    pitchfile  = annofilename(exper.birdname, exper.expername, 'Part', part, 'Type', 'pitch');
    miscfile   = annofilename(exper.birdname, exper.expername, 'Part', part, 'Type', 'misc');
    audiofile  = annofilename(exper.birdname, exper.expername, 'Part', part, 'Type', 'audio');
end

function ndx = segs_with_keys(segs, keys)
ndx = false(size(segs));
for ii = 1:length(keys)
	ndx = ndx | strcmp({segs.key}, keys(ii));
end