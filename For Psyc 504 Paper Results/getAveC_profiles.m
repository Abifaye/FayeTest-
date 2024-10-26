function [leftIdx, rightIdx] = getAveC_profiles(T)
%grabs stimulated and unstimulated criterion from master table, gets their
%average, and curve fit it using measurements below. Then they are split
%into 2 groups (above/below mean) using zscore and the corresponding
%opto stim profiles for each average C were put in separate matrices

%Get average criterion
aveC =  getAveC(T);

%% Get Profiles

%measurements for curve fitting 
aveC_histcounts = histcounts(aveC,-5:0.175:5);
aveC_range = -4.9:0.175:4.9;

%curvefitting variables

%create table for archiving parameters for each task and brain area from
%curvefitting
paramT = table();
paramT.Parameters(1:3,1) = ["amp"; "mu"; "sigma";];
paramT.SCGab = [48.1973;0.6916;0.3753];
paramT.SCLum = [103.4365;0.6667;0.4003];
paramT.V1Gab = [55.4991;0.7767;0.3883]; 
paramT.V1Lum = [45.3142;0.7585;0.3454];

%create a list dialogue prompt to choose which brain are and task type to
%run for calculating z-scores
selection = listdlg('PromptString',{'Select Brain area and task type'},'ListString',paramT.Properties.VariableNames,'SelectionMode','single');

% Z-scores
aveC_zScore = (aveC - paramT.(selection)(2)) / paramT.(selection)(3);

%Indices
leftIdx = aveC_zScore < 0;
rightIdx = aveC_zScore > 0;

end