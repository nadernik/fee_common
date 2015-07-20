function sorted_rasters(dbase, varargin)

%eg = openfig('electro_gui');
eg = electro_gui;
egh = guidata(eg);
electro_gui('push_Open_Callback', egh.push_Open, [], egh)
egh = guidata(eg);
egh.dbase = electro_gui('GetDBase', egh);
[~, sr] = egm_Sorted_rasters(egh);
srcallback(sr, 'push_GenerateRaster_Callback', 'push_GenerateRaster')
% fcnname = 'push_GenerateRaster_Callback'; %%%FIXME
% objname = 'push_GenerateRaster'; %%%FIXME


function srcallback(sr, fcnname, objname)
%SRCALLBACK Call callback from egm_Sorted_rasters.m
%
%Usage:
%    SRCALLBACK(SR, FCNNAME, OBJNAME)
%
%SR is the handle to the sorted rasters figure
%FCNNAME is the name of the function to call
%OBJNAME is the name of the object to pass to the function

srh = guidata(sr);
hObject = srh.(objname);
egm_Sorted_rasters(fcnname, hObject, [], srh);




