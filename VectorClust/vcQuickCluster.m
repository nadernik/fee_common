function bSuccess = vcQuickCluster(birdname,datestr,polygonfile,displayCluster, varargin)

P.prefix = 'all';
P.root = 'Z:\Data\CAF';
P = parseargs(P, varargin{:});

%Get all the relevant files.
fileSearch = [P.root, filesep, birdname, filesep, birdname, '_',P.prefix,'_misc_', datestr, '*'];
dFiles = dir(fileSearch);

for nFile = 1:length(dFiles)
    searchString = [P.root, filesep, birdname, filesep, strrep(dFiles(nFile).name, '_misc_', '_*_')];

    handles.vcdb.fileName = dFiles(nFile).name; %%% TO
    handles.vcdb.pathName = [P.root, filesep, birdname, filesep];%%% TO

    %load data.
    [v, sf, vf, icn, t, i, sfname, vfname] = vc_imp_ProcessedAnnotationFiles('batch', searchString, false, false, false);

    %add basic features to the scalar feature list.
    sf(:,end+1) = cellfun(@length,v);
    sfname{end+1} = 'length';
    sf(:,end+1) = t;
    sfname{end+1} = 'time';
    sf(:,end+1) = (t - floor(t))*24;
    sfname{end+1} = 'hourOfDay';
    sf(:,end+1) = icn;
    sfname{end+1} = 'imported cluster';

    %Construct data struction
    handles.vcdb.d.v = v;
    handles.vcdb.d.sf = sf;
    handles.vcdb.d.vf = vf;
    handles.vcdb.d.cn = nan(length(v),1);
    handles.vcdb.d.icn = icn;
    handles.vcdb.d.t = t;
    handles.vcdb.d.i = i;
    handles.vcdb.f.sfname = sfname;
    handles.vcdb.f.sffcn = repmat({func2str(@vc_imp_ProcessedAnnotationFiles)}, length(sfname), 1);
    handles.vcdb.f.sfparam = cell(length(sfname),1);
    handles.vcdb.f.vfname = vfname;
    handles.vcdb.f.vffcn = repmat({func2str(@vc_imp_ProcessedAnnotationFiles)}, length(vfname), 1);
    handles.vcdb.f.vfparam = cell(length(vfname),1);
    handles.vcdb.c = [];

    %load polygons
    load([P.root, filesep, birdname, filesep, polygonfile]);
    if ~exist('c','var')
        error('Specifed file is not a cluster polygon data file.');
    end

    %Map feature names to feature numbers
    bPerfect = true;
    for nc = 1:length(c)
        toDel = [];
        for np = 1:length(c(nc).polys)
            temp = mapFeatureName2Number(getAllSFNames(handles.vcdb),c(nc).polys{np}.xfeatName, feature2ndx(c(nc).polys{np}.xfeat, size(handles.vcdb.d.sf,2)));
            if isempty(temp) % If we could not find a match for this feature,
                % call the function to calculate this feature now.
                nf = c(nc).polys{np}.xfeat;
                if nf > 0
                    % negative feature numbers are special. They cannot be
                    % calculated until we have clustered syllables
                    % (PrevClusterNum for example). Skip this and we will
                    % deal with it later.
                    handles.vcdb = feval(f.sffcn{nf}, handles.vcdb, f.sfparam{nf}{:});
                else
                    temp = nf;
                end
            end
            c(nc).polys{np}.xfeat = mapFeatureName2Number(getAllSFNames(handles.vcdb), c(nc).polys{np}.xfeatName);%ndx2feature(temp, size(handles.vcdb.d.sf,2));
            temp = mapFeatureName2Number(getAllSFNames(handles.vcdb),c(nc).polys{np}.yfeatName, feature2ndx(c(nc).polys{np}.yfeat, size(handles.vcdb.d.sf,2)));
            if isempty(temp) % If we could not find a match for this feature,
                % call the function to calculate this feature now.
                nf = c(nc).polys{np}.yfeat;
                if nf > 0
                    % negative feature numbers are special. They cannot be
                    % calculated until we have clustered syllables
                    % (PrevClusterNum for example). Skip this and we will
                    % deal with it later.
                    handles.vcdb = feval(f.sffcn{nf}, handles.vcdb, f.sfparam{nf}{:});
                else
                    temp = nf;
                end
            end
            c(nc).polys{np}.yfeat = mapFeatureName2Number(getAllSFNames(handles.vcdb), c(nc).polys{np}.yfeatName);%ndx2feature(temp, size(handles.vcdb.d.sf,2));
            if(isempty(c(nc).polys{np}.xfeat) || isempty(c(nc).polys{np}.yfeat))
                toDel = [toDel, np];
                bPerfect = false;
            end
        end
        c(nc).polys(toDel) = [];
    end
    if(~bPerfect)
        error('Imperfect cluster to feature mapping');
    end
    handles.vcdb.c = c;

    %cluster the syllables...
    d = handles.vcdb.d;
    c = handles.vcdb.c;

    %Assign vectors to clusters
    cn_old = handles.vcdb.d.cn;
    hasCluster = false(size(handles.vcdb.d.cn));
    for i = 1:10
        for(nc = 1:length(c))
            %Overide with manual modifications.
            for(nInc = 1:length(c(nc).incs))
                bIN(c(nc).incs{nInc}) = true;
            end
            for(nExc = 1:length(c(nc).excs))
                bIN(c(nc).excs{nExc}) = false;
            end
            %Find vectors in all polygons.
            if(length(c(nc).polys)>0) 
% cannot do OR between polygons because this info is not stored in polygons
% file.
                    bIN = true(size(d.v)); % set all values to true
                    for(nPoly = 1:length(c(nc).polys)) % all the polygons
                        poly = c(nc).polys{nPoly};
                        bIN = bIN & inpolygon(getSF(handles.vcdb,poly.xfeat),getSF(handles.vcdb,poly.yfeat), poly.xverts, poly.yverts);
                    end
                
            else % no polygon
                bIN = false(size(d.v));
            end
            %Overide with manual modifications.
            for(nInc = 1:length(c(nc).incs))
                bIN(c(nc).incs{nInc}) = true;
            end
            for(nExc = 1:length(c(nc).excs))
                bIN(c(nc).excs{nExc}) = false;
            end
            %Set the cluster number
            handles.vcdb.d.cn(bIN) = c(nc).number;
            hasCluster = hasCluster | bIN;
        end
        if all(handles.vcdb.d.cn == cn_old)
            break
        end
        cn_old = handles.vcdb.d.cn;
    end
    handles.vcdb.d.cn(~hasCluster) = NaN;
    %export the clusters to files.
    vc_exp_ToProcessedAnnotationFile('batch', handles.vcdb, [P.root, filesep, birdname, filesep, dFiles(nFile).name]);

    %display clusters
    if(exist('displayCluster', 'var') && ~isempty(displayCluster)) %% TO
        c = handles.vcdb.c;
        %find matching cluster.
        cndx = [];
        for nc = 1:length(c)
            if(c(nc).number == displayCluster)
                cndx = nc;
            end
        end
        %Display each polygon plane
        for nPoly = 1:length(c(cndx).polys)
            poly = c(cndx).polys{nPoly};
            xfeat = poly.xfeat;
            yfeat = poly.yfeat;

            %draw the markers
            figure;
            scatter(getSF(handles.vcdb,xfeat), getSF(handles.vcdb,yfeat),'.');
            title(['file:', num2str(nFile), ' poly:', num2str(nPoly)]);

            %draw any polygon in view
            patch(poly.xverts,poly.yverts,'black','FaceColor','none','EdgeColor',handles.vcdb.c(cndx).color);
        end
    end
end
bSuccess = true;

% --------------------------------------------------------------------
function f = getSF(vcdb, nFeat, bndx)
if(nFeat>0)
    f = vcdb.d.sf(:,nFeat);
elseif(nFeat == -1)
    f = [nan; vcdb.d.cn(1:end-1)];
    f = f+0.2*rand(size(f))-0.1; % add noise for better visibility, TO
elseif(nFeat == -2)
    f = [vcdb.d.cn(2:end); nan];
    f = f+0.2*rand(size(f))-0.1; % add noise for better visibility, TO
elseif(nFeat == -3)
    f = [nan; nan; vcdb.d.cn(1:end-2)];
    f = f+0.2*rand(size(f))-0.1; % add noise for better visibility, TO
elseif(nFeat == -4)
    f = [vcdb.d.cn(3:end); nan; nan];
    f = f+0.2*rand(size(f))-0.1; % add noise for better visibility, TO
else
    error(['getSF: requested feature does not exist: ', num2str(nFeat)]);
end
if(exist('bndx'))
    f = f(bndx);
end

% --------------------------------------------------------------------
function name = getSFName(vcdb, nFeat)
if(nFeat == -1)
    name = 'PrevClusterNum';
elseif(nFeat == -2)
    name = 'NextClusterNum';
elseif(nFeat == -3)
    name = 'PrevPrevClusterNum';
elseif(nFeat == -4)
    name = 'NextNextClusterNum';
else
    name = vcdb.f.sfname{nFeat};
end
%----------------------------------------------------------------------
function ndx = feature2ndx(nFeat, numFeats)
ndx = nFeat;
if(isempty(nFeat)), ndx = []; return; end;
if(nFeat < 1)
    ndx = numFeats - nFeat;
end

% --------------------------------------------------------------------
function nFeat = ndx2feature(ndx, numFeats)
nFeat = ndx;
if(isempty(ndx)), nFeat = []; return; end;
if(ndx > numFeats)
    nFeat = numFeats - ndx;
end

% --------------------------------------------------------------------
function names = getAllSFNames(vcdb)
names = [vcdb.f.sfname; {'PrevClusterNum'}; {'NextClusterNum'}; {'PrevPrevClusterNum'}; {'NextNextClusterNum'}];

% --- Used to map an imported feature to a current feature.
function featNum = mapFeatureName2Number(featNames, importName, importNum)
switch importName
    case 'PrevClusterNum'
        featNum = -1;
    case 'NextClusterNum'
        featNum = -2;
    case 'PrevPrevClusterNum'
        featNum = -3;
    case 'NextNextClusterNum'
        featNum = -4;
    otherwise
        bMatch = cellfun(@strcmp, featNames, repmat({importName},size(featNames)));
        if sum(bMatch) == 1
            featNum = find(bMatch);
        else
            featNum = [];
        end
end