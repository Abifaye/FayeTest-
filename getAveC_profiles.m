function [leftProfiles,rightProfiles] = getAveC_profiles
%UNTITLED2 Summary of this function goes here

%load master table with profiles
load('TablewithProfiles.mat');

%
stimC = [TablewithProfiles.stimC];
unStimC = [TablewithProfiles.noStimC];
aveC = (stimC + unStimC)/2;

%% Get Profiles

%measurements for curve fitting 
aveC_histcounts = histcounts(aveC,-5:0.17:5);
aveC_range = -4.9:0.17:4.9;

%curvefitting variables
amp = 136.7;
mu = 0.6774;
sigma = 0.4078;

% Z-score
aveC_zScore = (aveC - mu) / sigma;

%Indices
leftIdx = aveC_zScore < 0;
rightIdx = aveC_zScore > 0;

%Init matrices for profiles below (leftprofiles) and above (rightprofiles)
%mean
leftProfiles = [];
rightProfiles = [];

% loop through all sessions
for nSession = 1:height(TablewithProfiles)
    %get all hit & miss profiles from session
    hitPros = cell2mat(struct2cell(TablewithProfiles.HitProfiles(nSession)));
    missPros = cell2mat(struct2cell(TablewithProfiles.MissProfiles(nSession)));
    comboPros = [hitPros;-missPros];
    %determine if delta_d of session is above or below mean and place in
    %appropriate matrix
    if leftIdx(nSession) == 1
        leftProfiles = [leftProfiles;comboPros(:,:)];
    elseif rightIdx(nSession) == 1
        rightProfiles = [rightProfiles;comboPros(:,:)];
    end
end
end