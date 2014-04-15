function GOF = judge_bird_TO(durs)
%%% list of duration in [ms]
% just 4 lines. sdur is the list of syllable durations and cuts is a 1x2 vector of the interval on which you want to fit the distribution ([0.025 0.4])
%%% original by Dmitriy Aronov
%%% Tatsuo Okubo
%%% 2011/02/07

cuts = [25 400]; % ms
 
% exponential fit
tau = exp_cutoff(durs,cuts);
% sort durations to calculate cdf of the data
nd = sort(durs(durs>cuts(1) & durs<cuts(2)));
% calculate cdf of the fit
expfitcdf = (expcdf(nd,tau)-expcdf(cuts(1),tau))/(expcdf(cuts(2),tau)-expcdf(cuts(1),tau));
% calculate and normalize the deviation
GOF = max(abs((1:length(nd))/length(nd)-expfitcdf'))*sqrt(length(nd));