function bSuccess = vcQuickCluster(birdname,datestr,polygonfile,displayCluster, varargin)

P.prefix = 'all';
P.root = 'c:\stetner\data';
P = parseargs(P, varargin{:});

if ~exist(polygonfile, 'file')
    polygonfile = [P.root, filesep, birdname, filesep, polygonfile];
end

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
    handles.vcdb = vcdbloadpolys(handles.vcdb, polygonfile);
    
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
            scatter(getsf(handles.vcdb,xfeat), getsf(handles.vcdb,yfeat),'.');
            title(['file:', num2str(nFile), ' poly:', num2str(nPoly)]);

            %draw any polygon in view
            patch(poly.xverts,poly.yverts,'black','FaceColor','none','EdgeColor',handles.vcdb.c(cndx).color);
        end
    end
end
bSuccess = true;