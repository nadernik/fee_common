function m_spec_deriv = aSAP_uncompressSpectralDeriv(filename)
%Author: Aaron Andalman 2006.01.31

%m_spec_deriv: the lossy recovery of the spectral derivative matrix
%filename, the name of the file you compressed to, w or w/o suffix.

%IMPORTANT: IF YOU MODIFY THIS FUNCTION BE SURE TO CHANGE THE VER#!!!!

%Unzip the files.
[path, name, ext] = fileparts(filename);
unzip([path,filesep,name,ext,'.zip'], path);

%Load the compression parameters.
load([path,filesep,name,'.mat']);

if(nVer == 1.0 | nVer == 1.1)
    %Load the jpg
    if(nVer == 1.0)
        m_sd_sc = imread([path,filesep,name,'.jpg']);
    else
        m_sd_sc = imread([path,filesep,name,'.sd.jpg']);
    end
    
    %Convert back to number between 0 and 1.
    m_sd_sc = double(m_sd_sc);
    m_sd_sc = m_sd_sc / (2^bitDepth-1);
    
    %Invert the sigmoid function, using the stored scale parameter
    m_sd_sc(find(m_sd_sc==0)) = eps;
    m_sd_sc = (1./m_sd_sc)-1;
    m_sd_sc(find(m_sd_sc==0)) = eps;
    m_spec_deriv = log(m_sd_sc) * -fScale;

    %Delete the unzipped jpg file.
    if(nVer == 1.0)
        delete([path,filesep,name,'.jpg']);
    end
end

%Delete the compression parameters.
delete([path,filesep,name,'.mat']);