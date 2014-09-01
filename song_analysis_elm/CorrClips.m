function C = CorrClips(tutor, pupil)
% CorrClips first converts tutor and pupil to spectrograms, then creates a 
% matrix M of the dotproducts between each pair of timepoints.  C is the 
% normalized sum of the diagonals of M, normalized so that the maximum of C
% is 1 iff pupil contains an exact (though maybe scaled in magnitude) copy 
% of tutor
%
% Emily Mackevicius July 26, 2012

    SpecTutor = abs(spectrogram(tutor, 512, 500, 1024));
    T = size(SpecTutor);
    SpecPupil = abs(spectrogram(pupil, 512, 500, 1024));
    P = size(SpecPupil);
    ZPP = SpecPupil; %[zeros(T) SpecPupil zeros(T)];
    M = ZPP'*SpecTutor;
    [y,x] = size(M);
    Tdot = sum(sum(SpecTutor.*SpecTutor));
    Pdot = sum(ZPP.*ZPP);
    for i = 1:y
        pd = sum(Pdot(:,i:min([(i+x-1) y])));
        C(i) = sum(M(i:(y+1):min([(x*y) (y-i)*x])))/sqrt(Tdot*pd);
    end

    
%     T = size(tutor);
%     P = size(pupil);
%     zpadpupil = [zeros(T); pupil; zeros(T)];
%     ZP = size(zpadpupil);
%     indices = repmat((1:T)', 1, ZP(1)-T(1)+1)+repmat((0:(ZP(1)-T(1))), T, 1);
%     M = zpadpupil(indices);
%     S = sum(M.*M);
%     S(S==0) = 1; 
%     N = sqrt(sum(tutor.*tutor).*S);
%     C = sum(M.*repmat(tutor, 1, ZP(1)-T(1)+1))./N;


%    for i = 1:(numel(zpadpupil)-numel(tutor)+1)
%        C(i) = sum(zpadpupil(i:(i+numel(tutor)-1)).*tutor)/sum(tutor.*tutor);
%    end
end