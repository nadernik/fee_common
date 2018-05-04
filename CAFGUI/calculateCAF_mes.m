function [bRuleMet, varargout] = calculateCAF(sig, p, r) 

if ~isfield(p,'bandFilters')
    p = createPitchFilters(p);
end

bandFilters = P.handles.bandFilters;
lpBands = P.handles.lpBands;
lpBird = P.handles.lpBird;

%get in-band power
for(nharm = 1:length(p.harmonics))
    band = filter(bandFilters.in(nharm).Numerator, 1, sqSig);
    band = band.^2;
    powBandHarm(nharm,:) = filter(lpBands.Numerator, 1, band);
end
powBand = sum(powBandHarm)'; % in-band power

%get out-band power
for(nharm = 1:length(bandFilters.out))
    band = filter(bandFilters.out(nharm).Numerator, 1, sqSig);
    band = band.^2;
    powOutBandHarm(nharm,:) = filter(lpBands.Numerator, 1, band);
end
powOutBand = sum(powOutBandHarm)'; % out-band power

%Get pitch score:
pitchScore = (powBand ./ (powBand + powOutBand + eps)); % avoid dividing by zero!

bRuleMet = pitchScore>P.handles.thres;
if nargout > 1
    varargout{1} = pitchScore;
end