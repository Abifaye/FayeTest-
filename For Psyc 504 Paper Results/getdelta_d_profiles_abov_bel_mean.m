function [leftIdx, rightIdx] = getdelta_d_profiles_abov_bel_mean(T)
%gets the function to grab delta dprimes, computes its z-score using sigma
%and mu from curve fitting, and sorts them between above and below mean 
%using matrices to place them.

%get delta_d
delta_d = getdelta_d(T);

%% Curve Fitting delta d'
d_histcounts = histcounts(delta_d,-5:0.15:5);
d_range = -4.9:0.15:4.9;

% Z-score
amp =  171.2944;
mu = -0.04869;
sigma = 0.2824;

%create table for archiving parameters for each task and brain area from
%curvefitting
paramT = table();
paramT.Parameters(1:3,1) = ["amp"; "mu"; "sigma";];
paramT.SCGab = [55.2642;-0.0221;0.2926];
paramT.SCLum = [123.8827;-0.0643;0.2788];
paramT.V1Gab = [65.8834;-0.0340;0.2805]; 
paramT.V1Lum = [53.6384;-0.0498;0.2462];

%create a list dialogue prompt to choose which brain are and task type to
%run for calculating z-scores
selection = listdlg('PromptString',{'Select Brain area and task type'},'ListString',paramT.Properties.VariableNames,'SelectionMode','single');

% Z-scores
deltaC_zScore = (delta_C - paramT.(selection)(2)) / paramT.(selection)(3);
deltaD_zScore = (delta_d - mu) / sigma;

%% Variables Initiation
%Indices
leftIdx = deltaD_zScore < 0;
rightIdx = deltaD_zScore > 0;

end