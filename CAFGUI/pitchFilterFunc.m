function [bRuleMet, varargout] = pitchFilterFunc(sig, p, r)

% % make the filters if they have not been made
% if ~isfield(p,'bandFilters')
%     p.bandFilters = makeFilter(...
%         'tdt_fs',p.tdt_fs,...
%         'bUp',strcmp(p.push,'up'),...
%         'pitchTarget',p.pitchTarget,...
%         'nudge',p.nudge,...
%         'width',p.width,...
%         'filterOverlap',p.overlap,...
%         'bottomFreq',p.bottomFreq,...
%         'passIn',p.passIn,...
%         'dbDown',p.dBdown,...
%         'harmonics',1:p.harmonics...
%         );
%     p.lpBands = v3lp(1, p.tdt_fs, p.lpfCutoff, p.lpfdBdown); %% low-pass output of filters
%     p.lpBands.Numerator = p.lpBands.Numerator ./ sum(p.lpBands.Numerator); % normalize
% end

bandFilters = p.bandFilters;
lpBands = p.lpBands;
% lpBird = p.handles.lpBird;

%get in-band power
for nharm = 1:p.harmonics
    band = filter(bandFilters.in(nharm).Numerator, 1, sig.^2);
    band = band.^2;
    powBandHarm(nharm,:) = filter(lpBands.Numerator, 1, band);
end
powBand = sum(powBandHarm)'; % in-band power

%get out-band power
for(nharm = 1:length(bandFilters.out))
    band = filter(bandFilters.out(nharm).Numerator, 1, sig.^2);
    band = band.^2;
    powOutBandHarm(nharm,:) = filter(lpBands.Numerator, 1, band);
end
powOutBand = sum(powOutBandHarm)'; % out-band power

%Get pitch score:
pitchScore = (powBand ./ (powBand + powOutBand + eps)); % avoid dividing by zero!

bRuleMet = pitchScore>p.pitchThreshold;
if nargout > 1
    varargout{1} = pitchScore;
end