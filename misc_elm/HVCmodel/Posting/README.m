%% Supplemental code for model of HVC syllable differentiation in Okubo et al. manuscript

% Emily Mackevicius 1/14/2015, heavily copied from Hannah Payne's code
% which builds off Ila Fiete's model, with help from Michale Fee and Tatsuo
% Okubo. 


%% Alternating Differentiation
% Code to generate figure 5 a-f, which shows alternating seed neuron 
% differentiation, from subsong through protosyllable stage through 
% splitting.

AlternatingDifferentiation  % run this file

% relies on: 

% HVCIter                   % runs 1 iteration of the model.  See this file for 
                            % step-by-step model dynamics and learning.
                    
% plotSubsong               % plotting function for subsong network diagram and
                            % raster
                    
% plotHVCnet                % plot network diagram

% plotAlternating           % plot raster

% findLatency               % called by plotting functions, tests what neurons
                            % participate in each syllable, and at what latencies
                    
%% Bout onset differentiation
% Code to generate figure 5 j-m, which shows bout onset differentiation

BoutOnsetDifferentiation    % run this file

% relies on: 

% HVCIter                   % runs 1 iteration of the model.  See this file for 
                            % step-by-step model dynamics and learning.
                    
% plotHVCnet_boutOnset      % plotting function for bout onset network diagram 
                            % and raster
                    
% findLatency               % called by plotting functions, tests what neurons
                            % participate in each syllable, and at what latencies