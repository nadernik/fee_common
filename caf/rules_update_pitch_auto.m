function rules_update_pitch_auto(exper, rules_file, pitch_rule)

pitch_shift = get_pitch_shift(FIXME);

if isempty(pitch_shift) || pitch_shift == 0
    debugdisp('No pitch shift detected')
    return
end

% load rules
load(rules_file) % creates variable 'handles'
p = handles.rules(pitch_rule).params;
debugdisp('Old rules loaded')

% shift the pitch
handles.rules.pitchTarget = ... 
    handles.rules(pitch_rule).params.pitchTarget + pitch_shift;

% recalculate filters
p.bandFilters = makeFilter(...
    'tdt_fs',p.tdt_fs,...
    'bUp',strcmp(p.push,'up'),...
    'pitchTarget',p.pitchTarget,...
    'nudge',p.nudge,...
    'width',p.width,...
    'filterOverlap',p.overlap,...
    'bottomFreq',p.bottomFreq,...
    'passIn',p.passIn,...
    'dbDown',p.dBdown,...
    'harmonics',1:p.harmonics...
    );
p.lpBands = v3lp(1, p.tdt_fs, p.lpfCutoff, p.lpfdBdown); %% low-pass output of filters
p.lpBands.Numerator = p.lpBands.Numerator ./ sum(p.lpBands.Numerator); % normalize
p.coefIn1 = p.bandFilters.in(1).Numerator;
p.coefIn2 = p.bandFilters.in(2).Numerator;
p.coefIn3 = p.bandFilters.in(3).Numerator;
p.coefOut1 = p.bandFilters.out(1).Numerator;
p.coefOut2 = p.bandFilters.out(2).Numerator;
p.coefOut3 = p.bandFilters.out(3).Numerator;
p.coefLP = p.lpBands.Numerator;
debugdisp('New filters calculated')

% save rules
handles.rules(pitch_rule).params = p;
timestr = datestr(now, 'HHMMSS');
new_rules_file = [exper.dir '_updated_' timestr];
save(new_rules_file, handles);
debugdisp('New rules saved')

% send filters to TDT
RP = actxcontrol('RPco.x',[5 5 26 26]);
RP.ConnectRX8('USB', 1);
status=double(handles.RP.GetStatus); % Get status
if bitget(status, 1) == 0; % Checks for connection
    disp('Error connecting to RX8');
end
exportRule2tdt(handles.rules(pitch_rule), RP)
debugdisp('New filters loaded on TDT')
