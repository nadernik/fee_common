function bSuccess = vcQuickCluster(birdname,datestr,polygonfile,displayCluster, varargin) 

P.prefix = 'all';
P.root = 'Z:\Data\CAF';
P = parseargs(P, varargin{:});

%Get all the relevant files.
fileSearch = [P.root, filesep, birdname, filesep, birdname, '_',P.prefix,'_misc_', datestr, '*'];
dFiles = dir(fileSearch);

for(nFile = 1:length(dFiles))
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
    if(~exist('c'))
        error('Specifed file is not a cluster polygon data file.');
    end

    %Map feature names to feature numbers
    f = handles.vcdb.f;
    bPerfect = true;
    for nc = 1:length(c)
        toDel = [];
        for np = 1:length(c(nc).polys)
            temp = mapFeatureName2Number(getAllSFNames(handles.vcdb),c(nc).polys{np}.xfeatName, feature2ndx(c(nc).polys{np}.xfeat, size(handles.vcdb.d.sf,2)));
            c(nc).polys{np}.xfeat = ndx2feature(temp, size(handles.vcdb.d.sf,2));
            temp = mapFeatureName2Number(getAllSFNames(handles.vcdb),c(nc).polys{np}.yfeatName, feature2ndx(c(nc).polys{np}.yfeat, size(handles.vcdb.d.sf,2)));
            c(nc).polys{np}.yfeat = ndx2feature(temp, size(handles.vcdb.d.sf,2));
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
    handles.vcdb.d.cn = nan(size(d.v));
    for(nc = 1:length(c))
        %Find vectors in all polygons.
        if(length(c(nc).polys)>0)
            bIN = true(size(d.v));
            for(nPoly = 1:length(c(nc).polys))
                poly = c(nc).polys{nPoly};
                bIN = bIN & inpolygon(getSF(handles.vcdb,poly.xfeat),getSF(handles.vcdb,poly.yfeat), poly.xverts, poly.yverts);
            end
        else
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
    end

    %export the clusters to files.
    varargout = vc_exp_ToProcessedAnnotationFile('batch', handles.vcdb, [P.root, filesep, birdname, filesep, dFiles(nFile).name])

    %display clusters
    if(exist('displayCluster') && ~isempty(displayCluster)) %% TO
        d = handles.vcdb.d;
        c = handles.vcdb.c;
        %find matching cluster.
        cndx = [];
        for(nc = 1:length(c))
            if(c(nc).number == displayCluster)
                cndx = nc;
            end
        end
        %Display each polygon plane
        for(nPoly = 1:length(c(cndx).polys))
            poly = c(cndx).polys{nPoly};
            xfeat = poly.xfeat;
            yfeat = poly.yfeat;

            %draw the markers
            figure;
            hScat = scatter(getSF(handles.vcdb,xfeat), getSF(handles.vcdb,yfeat),'.');     
            title(['file:', num2str(nFile), ' poly:', num2str(nPoly)]);

            %draw any polygon in view
            hp = patch(poly.xverts,poly.yverts,'black','FaceColor','none','EdgeColor',handles.vcdb.c(cndx).color); 
        end
    end
end
bSuccess = true;

% ------------------------------------------------------------------------
function f = getSF(vcdb, nFeat, bndx)
if(nFeat>0)
    f = vcdb.d.sf(:,nFeat);
elseif(nFeat == -1)
    f = [nan; vcdb.d.cn(1:end-1)];
elseif(nFeat == -2)
    f = [vcdb.d.cn(2:end); nan];    
else
    error(['getSF: requested feature does not exist: ', num2str(nFeat)]);
end
if(exist('bndx'))
    f = f(bndx);
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
names = [vcdb.f.sfname; {'PrevClusterNum'}; {'NextClusterNum'}];

% --- Used to map an imported feature to a current feature.
function featNum = mapFeatureName2Number(featNames, importName, importNum)
if(importNum<=length(featNames) && strcmp(importName, featNames{importNum}))
    featNum = importNum;
else
    bMatch = cellfun(@strcmp, featNames, repmat({importName},size(featNames)));
    if(sum(bMatch)==1)
        featNum = find(bMatch);
    else
        prompt = ['A feature named ',importName,' is being imported.  Please select its match:'];
        [sel,ok] = listdlg('PromptString',prompt ,...
                           'SelectionMode','single',...
                           'ListString',featNames, ...
                           'OKString', 'OK', ...
                           'CancelString', 'NO MATCH FOUND');
        if(ok)
            featNum = sel;
        else
            featNum = [];
        end
    end
end
