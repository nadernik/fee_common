function [vcdb, status, sf, vf, sfn, vfn, sfp, vfp] = vc_cmf_VectorStatistics(vcdb)

status = '';
sf = [];
vf = {};
sfn = {};
vfn = {};
sfp = {};
vfp = {};

if(strcmp(vcdb,'parameters'))
    params.name = 'basicStatistics';
    vcdb = params;
    return;
end

sf(:,1) = cellfun(@mean, 


handles.vcdb.d.sf = [handles.vcdb.d.sf, sf];
handles.vcdb.d.vf = [handles.vcdb.d.vf, vf];
handles.vcdb.f.sfname = [handles.vcdb.f.sfname, sf_names];
handles.vcdb.f.sffcn = [handles.vcdb.f.sffcn; repmat({func2str(cmpFcn)},length(sf_names),1)];
handles.vcdb.f.sfparam = [handles.vcdb.f.sfparam, sf_params];
handles.vcdb.f.vfname = [handles.vcdb.f.vfname, vf_names];
handles.vcdb.f.vffcn = [handles.vcdb.f.vffcn; repmat({func2str(cmpFcn)},length(vf_names),1)];
handles.vcdb.f.vfparam = [handles.vcdb.f.vfparam, vf_params];
