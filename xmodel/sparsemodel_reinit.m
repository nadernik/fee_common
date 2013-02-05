close all
clear all
filename = 'c:\stetner\code\ripples.mat';
load(filename, 'sn')
sn.reinit()

% Changes
% sn.wI(:) = 0; % Turn off lateral inhibition
% sn.LTDrate = 0; % Turn off LTD
% sn.LTPrate = sn.LTPrate/2;

% Continue simulation
sn.simulate()