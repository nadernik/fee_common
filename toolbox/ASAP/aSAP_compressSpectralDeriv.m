function aSAP_compressSpectralDeriv(m_spec_deriv, filename, fScalePrctile, nQuality, bHighRes)
%Author: Aaron Andalman  2006.01.31
%This function provides lossy compresion of a spectral derivitive matrix. 
%This allows the sd to be computed once and stored without using large
%amounts of harddisk space.

%m_spec_deriv: the spectral derivative matrix
%filename, the name you would like the file stored in (no suffix)
%(optional) fScalePrctile: default 90th percentile, lower percentile yield
%           better image quality at higher gains.
%(optional) nQuality: default 85, the quality of stored jpeg, number closer
%           to 100 yield fewer jpeg artifacts.  Ignored if highres
%(optional) bHighRes: turns on lossless 16bit jpeg storage.  Great quality,
%           but lots of space.

%Version 1.1 Does not include the jpeg file in the zip file.
%            This allows the jpegs to be viewed more easily my non-matlab
%            software.

%nVer, fScale: values needed to uncompress the m_spec_deriv.

%IMPORTANT: IF YOU MODIFY THIS FUNCTION BE SURE TO CHANGE THE VER#!!!!

nVer = 1.1;

if(~exist('bHighRes'))
    bHighRes = false;
end

if(~exist('fScalePrctile'))
    fScalePrctile = 90;
end

if(~exist('nQuality'))
    nQuality = 85;
end

bitDepth = 8;
if(bHighRes)
    bitDepth = 16;
end

%Scale factor pre-sigmoid.
fScale = prctile(abs(m_spec_deriv(1:end)), fScalePrctile);

%Run the spectral info through the sigmoid function:
m_sd_sc = 1./(1+exp(-m_spec_deriv/fScale));

%Quantize and write as jpeg
[path, name, ext] = fileparts(filename);
m_sd_sc = m_sd_sc * double(2^bitDepth-1);
if(bitDepth == 8)
    %lossy 8 bit
    m_sd_sc = uint8(m_sd_sc);
    imwrite(m_sd_sc, [filename,'.jpg'], 'jpg', 'Mode', 'lossy', 'BitDepth', bitDepth, 'Quality', nQuality);
else
    %lossless 16 bit
    m_sd_sc = uint16(m_sd_sc); 
    imwrite(m_sd_sc, [filename,'.jpg'], 'jpg', 'Mode', 'lossless', 'BitDepth', bitDepth);
end

%Write .mat with uncompress info
save([name,'.mat'], 'nVer', 'fScale', 'bitDepth');

%zip the files together, and delete the originals.
zip([filename,'.zip'], {[name,'.mat']});
delete([name,'.mat']);




