function [pitchTraj, absTime, syllType, dura] = getProcessedPitchTrajectories(birdName, varargin)

	%Default Parameters
	%To get files
	P.experNames = []; %pass single or cell of experNames
	P.prefix = 'all';
	P.rootdir = 'c:\stetner\data\';
	%To select syllables
	P.targetSyll = [];
	P.timeRanges = [];
	P.selMode = {'none','randFrac'};
	P.selParam = [];
	%Other
	P.targetRegion = [];
	P.targetMethod = {'percent', 'time'};
	P = parseargs(P, varargin{:});


	[dMisc, folder] = getProcessedDataFiles(birdName, 'dataType', 'misc', 'experNames', P.experNames, 'prefix', P.prefix, 'rootdir', P.rootdir);
	dPitch = getProcessedDataFiles(birdName, 'dataType', 'pitch', 'experNames', P.experNames, 'prefix', P.prefix, 'rootdir', P.rootdir);
	bSel = getProcessedSyllableSelection(dMisc, folder, 'targetSyll', P.targetSyll, 'timeRanges', P.timeRanges, 'selMode', P.selMode, 'selParam', P.selParam);
	numSylls = sum(cellfun(@sum, bSel));

	%load the data
	pitchTraj = cell(numSylls,1);
	absTime = nan(numSylls,1);
	syllType = nan(numSylls,1);
	dura = nan(numSylls,1);
	currNdx = 0;
	for nFile = 1:length(dMisc)
		if(sum(bSel{nFile})>0)       
			load([folder, dMisc(nFile).name]);
			load([folder, dPitch(nFile).name]);
			absTime(currNdx+1:currNdx+sum(bSel{nFile})) = [misc.segs(bSel{nFile}).absStart];
			syllType(currNdx+1:currNdx+sum(bSel{nFile})) = [misc.segs(bSel{nFile}).segType];
			dura(currNdx+1:currNdx+sum(bSel{nFile})) = [misc.segs(bSel{nFile}).duration];
			pitchTraj(currNdx+1:currNdx+sum(bSel{nFile})) = {pitch.segs(bSel{nFile}).pitch};
			currNdx = currNdx + sum(bSel{nFile});
		end
	end

	%sort the data
	[absTime, sndx] = sort(absTime);
	syllType = syllType(sndx);
	dura = dura(sndx);
	pitchTraj = pitchTraj(sndx);

	%extract the targetRegion
	if(~isempty(P.targetRegion))
		if strcmp(P.targetMethod,'percent')
			pitchTraj = cellfun(@extractFragment_percent, pitchTraj, repmat({P.targetRegion},length(pitchTraj),1), 'UniformOutput', false);
		elseif strcmp(P.targetMethod,'time')
            error('not implemented yet')
 			%pitchTraj = cellfun(@extractFragment_time, pitchTraj, repmat({fs},length(pitchTraj),1), repmat({P.},length(pitchTraj),1),repmat({P.targetRegion},length(pitchTraj),1)
        end
	end
end

function ts = extractFragment_percent(ts, syllFragment)
	if(isempty(ts))
		return;
	end
	ndxStart = ceil((length(ts)-1) * syllFragment(1)) + 1;
	ndxEnd = floor((length(ts)-1) * syllFragment(2)) + 1;
	ts = ts(ndxStart:ndxEnd);
end

function fragment = extractFragment_time(y, t_or_fs, t0, tlim)
	% tlim in seconds
	if isscalar(t_or_fs)
		% if we are given a single number, it must be sampling rate
		fs = t_or_fs;
		t = 0:length(y)-1 * fs;
	else
		t = t_or_fs;
	end

	if t0 == 'end'
		t0 = t(end);
	end

	tlim = tlim + t0;
	fragment = y(t >= tlim(1) & t < tlim(end));
end