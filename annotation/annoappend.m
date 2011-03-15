function add_to_annotation_files(exper, newanno, newpitch, newmisc)
files_to_add = length(anno);
newkeys = newanno.keys;
newelements = newanno.elements;
maxFilesPerAnnotation = 300; %FIXME
startfile = 1;
% find the latest annotation file and load it
part = 1;
while true
    annofile = get_annotation_filename(exper.birdname, exper.expername, 'part', part);
    if ~exist(annofile, 'file')
        part = part - 1;
        break
    else
        part = part + 1;
    end
end
annofile = get_annotation_filename(exper.birdname, exper.expername, 'part', part);
pitchfile = get_annotation_filename(exper.birdname, exper.expername, 'part', part, 'type', 'pitch');
miscfile = get_annotation_filename(exper.birdname, exper.expername, 'part', part, 'type', 'misc');


% while we have more files to add
while files_to_add > 0

	% load annotation
	if exist(annofile,'file')
		load(annofile); % load varaibles 'keys' and 'elements'
		load(pitchfile) % loads variable 'pitch'
		load(miscfile) % loads variable 'misc'
	else % need to create a new annotation file
		keys = [];
		elements = [];
		pitch = [];
		misc = [];
	end
	
	% Add files to annotation.
	endfile = min(length(newkeys), startfile + maxFilesPerAnnotation);
	segndx = segs_with_keys(newpitch.segs, newkeys(startfile:endfile));
	keys     = [keys     newkeys(startfile:endfile)    ];
	elements = [elements newelements(startfile:endfile)];
	pitch    = [pitch    newpitch(segndx)              ];
	misc     = [misc     newmisc(segndx)               ]; % assumes pitch and misc segs are in same order
	
	% save files
	save(annofile, 'keys', 'elements')
	save(pitchfile, 'pitch')
	save(miscfile,  'misc')
	
	% housekeeping for next iteration
	files_to_add = files_to_add - (endfile - startfile);
	startfile = endfile + 1;
	part = part + 1;	
    annofile = get_annotation_filename(exper.birdname, exper.expername, 'part', part);
    pitchfile = get_annotation_filename(exper.birdname, exper.expername, 'part', part, 'type', 'pitch');
    miscfile = get_annotation_filename(exper.birdname, exper.expername, 'part', part, 'type', 'misc');
end

function ndx = segs_with_keys(segs, keys)
ndx = false(size(segs));
for ii = 1:length(keys)
	ndx = ndx | strcmp({segs.key}, keys(ii));
end