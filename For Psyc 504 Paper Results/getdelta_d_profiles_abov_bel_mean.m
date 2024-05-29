function [leftIdx, rightIdx] = getdelta_d_profiles_abov_bel_mean(T)
%loads master table with profiles, gets the function to grab delta
%dprimes, computes its z-score using sigma and mu from curve fitting, and
%sorts them between above and below mean using matrices to place them.

%get delta_d
delta_d = getdelta_d(T);

%% Curve Fitting delta d'
d_histcounts = histcounts(delta_d,-5:0.15:5);
d_range = -4.9:0.15:4.9;

% Z-score
amp =  171.2944;
mu = -0.04869;
sigma = 0.2824;
deltaD_zScore = (delta_d - mu) / sigma;

%% Variables Initiation
%Indices
leftIdx = deltaD_zScore < 0;
rightIdx = deltaD_zScore > 0;

end