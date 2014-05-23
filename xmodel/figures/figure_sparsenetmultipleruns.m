close all
clear all

yes_inhib = SparseNetMultipleRunsFig;
yes_inhib.filepattern = 'SparseNetFigureCandidate_inhib_*.mat';
yes_inhib.filename = 'SparseNetMultipleRuns_inhib.mat';
%yes_inhib.compute
yes_inhib.draw

no_inhib = SparseNetMultipleRunsFig;
no_inhib.filepattern = 'SparseNetFigureCandidate_slow_*.mat';
no_inhib.filename = 'SparseNetMultipleRuns_slow.mat';
%no_inhib.compute
no_inhib.draw