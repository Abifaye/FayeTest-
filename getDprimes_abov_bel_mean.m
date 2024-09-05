function [leftIdx,rightIdx] = getDprimes_abov_bel_mean(T)
% Summary: Grabs stimulated d' master table, computes its z-score using sigma
% and mu from curve fitting, and sorts them between above and below mean 
% using matrices to place them.

%allocate the variables
stimDPrimes = [T.stimDPrime];

%% Curve Fitting stim d-primes
d_histcounts = histcounts(stimDPrimes,-5:0.17:5); 
d_range = -4.9:0.17:4.9;

%create table for archiving parameters for each task and brain area from
%curvefitting
paramT = table();
paramT.Parameters(1:3,1) = ["amp"; "mu"; "sigma";];
paramT.SCGab = [23.5903;2.1334;0.7888];
paramT.SCLum = [41.6634;2.1167;0.9985];
paramT.V1Gab = [26.7029;2.4870;0.7862];
paramT.V1Lum = [23.0186;2.6580;0.6698];

%create a list dialogue prompt to choose which brain are and task type to
%run for calculating z-scores
selection = listdlg('PromptString',{'Select Brain area and task type'},'ListString',paramT.Properties.VariableNames,'SelectionMode','single');

% Z-scores
dprime_zScore = (stimDPrimes - paramT.(selection)(2)) / paramT.(selection)(3);

%% Variables Initiation
%Indices
leftIdx = dprime_zScore < 0;
rightIdx = dprime_zScore > 0;

end