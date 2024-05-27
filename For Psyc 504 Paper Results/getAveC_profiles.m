function [leftProfiles,rightProfiles] = getAveC_profiles
%grabs stimulated and unstimulated criterion from master table, gets their
%average, and curve fit it using measurements below. Then they are split
%into 2 groups (above/below mean) using zscore and the corresponding
%opto stim profiles for each average C were put in separate matrices

%load master table with profiles
load(uigetfile('','Select desired master table'));

%Get average criterion
stimC = [T.stimC];
unStimC = [T.noStimC];
aveC = (stimC + unStimC)/2;

%% Get Profiles

%measurements for curve fitting 
aveC_histcounts = histcounts(aveC,-5:0.175:5);
aveC_range = -4.9:0.175:4.9;

%curvefitting variables
%for SC: amp = 136.7;mu = 0.6774;sigma = 0.4078;
%for V1:amp = 97.8051;mu = 0.7706;sigma = 0.3690;

amp = 136.7;
mu =  0.6774;
sigma = 0.4078;


% Z-score
aveC_zScore = (aveC - mu) / sigma;

%Indices
leftIdx = aveC_zScore < 0;
rightIdx = aveC_zScore > 0;

end