close all
clear all
filename = 'c:\stetner\code\powerfulinhib.mat';
load(filename, 'sn')
sn.reinit(sn.niter)

% Changes
sn.wI(sn.wI ~= 0) = 0; % Turn off lateral inhibition
sn.wH(:,:,1) = max(0, sn.wH(:,:,1) - sn.msnthresh);
sn.LTDrate = 0.00; % Turn off LTD
sn.msnthresh = 0.1 * sn.winit;
% sn.LTPrate = sn.LTPrate/2; 

% Continue simulation
sn.simulate()