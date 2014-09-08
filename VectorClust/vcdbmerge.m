function vcdb = vcdbmerge(vcdb1, vcdb2, varargin)
P.mode = {'omit', 'nan', 'compute'}; % how to deal with missing scalar features
P = parseargs(P, varargin{:});
% Assumes that if two features have the same name then they are the same.
% Does NOT check to make sure computed features were computed the same way.
% vcdb.f takes values from vcdb1. It will only use values from vcdb2 for
% features that do not exist in vcdb1. Inherits fileName and pathName from
% vcdb1

N1 = length(vcdb1.d.v);
N2 = length(vcdb2.d.v);

% easy stuff
vcdb.d.v   = [vcdb1.d.v;  vcdb2.d.v];
vcdb.d.cn  = [vcdb1.d.cn; vcdb2.d.cn];
vcdb.d.t   = [vcdb1.d.t;  vcdb2.d.t];
vcdb.d.i   = [vcdb1.d.i;  vcdb2.d.i];

% icn
if isfield(vcdb1.d, 'icn') && isfield(vcdb2.d, 'icn')
    vcdb.d.icn = [vcdb1.d.icn; vcdb2.d.icn];
elseif isfield(vcdb1.d, 'icn') && ~isfield(vcdb2.d, 'icn')
    vcdb.d.icn = [vcdb1.d.icn; nan(N2,1)];
elseif ~isfield(vcdb1.d, 'icn') && isfield(vcdb2.d, 'icn')
    vcdb.d.icn = [nan(N1,1); vcdb2.d.icn];
end

% vector features
all_vfname = unique([vcdb1.f.vfname; vcdb2.f.vfname]);
vcdb.f.vfname  = cell(length(all_vfname), 1);
vcdb.f.vffcn   = cell(length(all_vfname), 1);
vcdb.f.vfparam = cell(length(all_vfname), 1);
vcdb.d.vf      = cell(length(all_vfname), 1);
for vf = 1:length(all_vfname) % for each vf
    vfname = all_vfname{vf};
    vf1 = getvfnum(vcdb1, vfname);
    vf2 = getvfnum(vcdb2, vfname);
    vcdb.f.vfname{vf,1} = vfname;
    if ~isempty(vf1) && ~isempty(vf2)
        % if vf is in both, just concatenate
        vcdb.f.vffcn{vf,1} = vcdb1.f.vffcn{vf1};
        vcdb.f.vfparam{vf,1} = vcdb1.f.vfparam{vf1};
        vcdb.d.vf{vf,1} = [vcdb1.d.vf{vf1}; vcdb2.d.vf{vf2}];
    elseif ~isempty(vf1) && isempty(vf2)
        % if sf is in 1 but not 2
        switch P.mode
            case 'omit'
                % do nothing
            case 'nan'
                vcdb.f.vffcn{vf} = vcdb1.f.vffcn{vf1};
                vcdb.f.vfparam{vf} = vcdb1.f.vfparam{vf1};
                vcdb.d.vf{vf} = [vcdb1.d.vf{vf1}; repmat({[]},N2,1)];
            case 'compute'
                vcdb.f.vffcn{vf} = vcdb1.f.vffcn{vf1};
                vcdb.f.vfparam{vf} = vcdb1.f.vfparam{vf1};
                try
                    vcdb.d.vf{vf} = [vcdb1.d.vf{vf1}; ...
                        feval(vcdb1.f.vffcn{vf1}, vcdb, vcdb2.f.vfparam{vf1}{:})];
                catch
                    vcdb.d.vf{vf} = [vcdb1.d.vf{vf1}; repmat({[]},N2,1)];
                end
        end
    elseif isempty(vf1) && ~isempty(vf2)
        % if sf is in 2 but not 1
        switch P.mode
            case 'omit'
                % do nothing
            case 'nan'
                vcdb.f.vffcn{vf} = vcdb2.f.vffcn{vf2};
                vcdb.f.vfparam{vf} = vcdb2.f.vfparam{vf2};
                vcdb.d.vf{vf} = [repmat({[]},N1,1); vcdb2.d.vf{vf2}];
            case 'compute'
                vcdb.f.vffcn{vf} = vcdb2.f.vffcn{vf2};
                vcdb.f.vfparam{vf} = vcdb2.f.vfparam{vf2};
                try
                    vcdb.d.vf{vf} = [ ...
                        feval(vcdb2.f.vffcn{vf2}, vcdb, vcdb2.f.vfparam{vf2}{:}); ...
                        vcdb2.d.vf{vf2}];
                catch
                    vcdb.d.vf{vf} = [repmat({[]},N1,1); vcdb2.d.vf{vf2}];
                end
        end
    end
end

% scalar features
all_sfname = unique([vcdb1.f.sfname; vcdb2.f.sfname]);
for sf = 1:length(all_sfname) % for each sf
    sfname = all_sfname{sf};
    sf1 = getsfnum(vcdb1, sfname);
    sf2 = getsfnum(vcdb2, sfname);
    vcdb.f.sfname{sf} = sfname;
    if ~isempty(sf1) && ~isempty(sf2)
        % if sf is in both, just concatenate
        vcdb.f.sffcn{sf} = vcdb1.f.sffcn{sf1};
        vcdb.f.sfparam{sf} = vcdb1.f.sfparam{sf1};
        vcdb.d.sf(:,sf) = [vcdb1.d.sf(:,sf1); vcdb2.d.sf(:,sf2)];
    elseif ~isempty(sf1) && isempty(sf2)
        % if sf is in 1 but not 2
        switch P.mode
            case 'omit'
                % do nothing
            case 'nan'
                vcdb.f.sffcn{sf} = vcdb1.f.sffcn{sf1};
                vcdb.f.sfparam{sf} = vcdb1.f.sfparam{sf1};
                vcdb.d.sf(:,sf) = [vcdb1.d.sf(:,sf1); nan(N2,1)];
            case 'compute'
                vcdb.f.sffcn{sf} = vcdb1.f.sffcn{sf1};
                vcdb.f.sfparam{sf} = vcdb1.f.sfparam{sf1};
                try
                    vcdb.d.sf(:,sf) = [vcdb1.d.sf(:,sf1); ...
                        feval(vcdb1.f.sffcn{sf1}, vcdb, vcdb2.f.sfparam{sf1}{:})];
                catch
                    vcdb.d.sf(:,sf) = [vcdb1.d.sf(:,sf1); nan(N2,1)];
                end
        end
    elseif isempty(sf1) && ~isempty(sf2)
        % if sf is in 2 but not 1
        switch P.mode
            case 'omit'
                % do nothing
            case 'nan'
                vcdb.f.sffcn{sf} = vcdb2.f.sffcn{sf2};
                vcdb.f.sfparam{sf} = vcdb2.f.sfparam{sf2};
                vcdb.d.sf(:,sf) = [nan(N1,1); vcdb2.d.sf(:,sf2)];
            case 'compute'
                vcdb.f.sffcn{sf} = vcdb2.f.sffcn{sf2};
                vcdb.f.sfparam{sf} = vcdb2.f.sfparam{sf2};
                try
                    vcdb.d.sf(:,sf) = [ ...
                        feval(vcdb2.f.sffcn{sf2}, vcdb, vcdb2.f.sfparam{sf2}{:}); ...
                        vcdb2.d.sf(:,sf2)];
                catch
                    vcdb.d.sf(:,sf) = [nan(N1,1); vcdb2.d.sf(:,sf2)];
                end
        end
    end
end

if isfield(vcdb.f, 'sfname')
    vcdb.f.sfname = vcdb.f.sfname';
end
if isfield(vcdb.f, 'vfname')
    vcdb.f.vfname = vcdb.f.vfname';
end