function [outputArg1,outputArg2] = getdeltaC_abov_bel_mean(T)
% Summary: Grabs stimulated a master table, computes its z-score using sigma
% and mu from curve fitting, and sorts them between above and below mean 
% using matrices to place them.

%cd to folder containing function to get delta C
cd(uigetdir('', 'Choose folder containing getdelta_C function'))

%allocate the variables
delta_C = getdelta_C(T);

%% Curve Fitting delta C
C_histcounts = histcounts(delta_C,-5:0.15:5);
C_range = -4.9:0.15:4.9;

%create table for archiving parameters for each task and brain area from
%curvefitting
paramT = table();
paramT.Parameters(1:3,1) = ["amp"; "mu"; "sigma";];
paramT.SCGab = [103.9309;0.0505;0.1558];
paramT.SCLum = [236.3302;0.0698;0.1470];
paramT.V1Gab = [123.5300;0.0582;0.1502]; 
paramT.V1Lum = [96.9324;0.0522;0.1389];

%create a list dialogue prompt to choose which brain are and task type to
%run for calculating z-scores
selection = listdlg('PromptString',{'Select Brain area and task type'},'ListString',paramT.Properties.VariableNames,'SelectionMode','single');

% Z-scores
deltaC_zScore = (delta_C - paramT.(selection)(2)) / paramT.(selection)(3);

%% Variables Initiation
%Indices
leftIdx = deltaC_zScore < 0;
rightIdx = deltaC_zScore > 0;

end