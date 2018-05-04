function [data, fs, dateandtime, label, props] = dbaseGetData(dbase, filenum, src)
%DBASEGETDATA Loads data from dbase
%
%Syntax:
%  [data, fs, dateandtime, label, props] = ...
%                                         dbaseGetData(dbase, filenum, src)
%
%Inputs:
%  dbase
%    dbase struct, from electro_gui
%  filenum
%    File number
%  src
%    Source for the data. One of the following options:
%      '(None)'
%      'Sound'
%      'Channel 1'
%      'Channel 2'
%      'Channel 3'
%      'Channel 4'
%      'Channel 5'
%      'Channel 6'
%      'Channel 7'
%      'Channel 8'
%
%Outputs:
%  data   data vector
%  fs     sampling rate in Hz
%  dateandtime
%  label
%  props

switch src
    case '(None)'
        data = [];
        fs = dbase.Fs;
        dateandtime = [];
        label = '';
        props.Names = {};
        props.Types = {};
        props.Values = {};
        return
    case 'Sound'
        fcn = ['egl_' dbase.SoundLoader];
        fname = fullfile(dbase.PathName, dbase.SoundFiles(filenum).name);
        [data, fs, dateandtime, label, props] = feval(fcn, fname, 1);
    case {'Channel 1', 'Channel 2', 'Channel 3', 'Channel 4', ...
          'Channel 5', 'Channel 6', 'Channel 7', 'Channel 8'}
        ch = str2double(src(9));
        fcn = ['egl_' dbase.ChannelLoader{ch}];
        fname = fullfile(dbase.PathName, dbase.ChannelFiles{ch}(filenum).name);
        [data, fs, dateandtime, label, props] = feval(fcn, fname, 1);
    otherwise
        error('Unknown source');
end
        
        
