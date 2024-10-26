function [leftIdx,rightIdx] = getUnstimDprimes_abov_bel_mean(T)
% Summary: Grabs stimulated d' master table, computes its z-score using sigma
% and mu from curve fitting, and sorts them between above and below mean 
% using matrices to place them.

%allocate the variables
unstimDPrimes = [T.noStimDPrime];

%% Curve Fitting unstim d-primes
d_histcounts = histcounts(unstimDPrimes,-5:0.17:5); 
d_range = -4.9:0.17:4.9;

%create table for archiving parameters for each task and brain area from
%curvefitting
paramT = table();
paramT.Parameters(1:3,1) = ["amp"; "mu"; "sigma";];
paramT.SCGab = [26.3062;2.1873;0.6984];
paramT.SCLum = [45.7053;2.2328;0.9080];
paramT.V1Gab = [27.5017;2.5442;0.7469];
paramT.V1Lum = [23.4920;2.6521;0.6261];

%create a list dialogue prompt to choose which brain are and task type to
%run for calculating z-scores
selection = listdlg('PromptString',{'Select Brain area and task type'},'ListString',paramT.Properties.VariableNames,'SelectionMode','single');

% Z-scores
dprime_zScore = (unstimDPrimes - paramT.(selection)(2)) / paramT.(selection)(3);

%% Variables Initiation
%Indices
leftIdx = dprime_zScore < 0;
rightIdx = dprime_zScore > 0;

end