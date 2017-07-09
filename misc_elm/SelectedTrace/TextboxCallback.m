function TextboxCallback(source,callbackdata)
    global istart w pressed patches h SpecIm ExtraIm Tit npat ...
        slines1 slines2 dbase FnumBnum Timestamps; 
istart = str2num(callbackdata.Source.String);
UpdatePlot()
end