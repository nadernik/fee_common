function [data, fs, dateandtime, label, Props] = egl_SpikeGLX_NIDAQ(filename, loadData)
% Requires 'SpikeGLX_Datafile_Tools' repo from Jennifer Colonell to work
    
    [path, binName, ext] = fileparts(filename);
    meta = SGLX_readMeta.ReadMeta(strcat(binName, ext), path);

    fs = str2num(meta.niSampRate);
    dateandtime = datenum(datetime(meta.fileCreateTime, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss'));
    label = 'Voltage (V)';
    Props.Names = {'Comment'};%made up properties because I don't understand what they should be
    Props.Types = 1;
    Props.Values = {''};

    if loadData ~= 1
        data = [];
    else
        iAudio = 3;
        rawdata = SGLX_readMeta.ReadBin(0, Inf, meta, strcat(binName, ext), path);
        corrdata = SGLX_readMeta.GainCorrectNI(rawdata, [iAudio], meta);
        data = corrdata(iAudio, :);
    end
end
