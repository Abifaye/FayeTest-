function [leftProfiles,rightProfiles] = getTopUp_profiles
%loads master table with profiles, gets the function to grab top up
%dprimes, computes its z-score using sigma and mu from curve fitting, and
%sorts them between above and below mean using matrices to place them.

%% Initiation

%load master table with profiles
load('TablewithProfiles.mat');

% Init variable
topUp_D = [TablewithProfiles.topUpDPrime]; 
%the master table
 
%% Get Profiles

%measurements for curve fitting 
topUpD_histcounts = histcounts(topUp_D,-5:0.2:5);
topUpD_range = -4.9:0.2:4.9;

%curvefitting variables
amp = 81.03;
mu = 2.552;
sigma = 0.8123;

% Z-score
topUp_zScore = (topUp_D - mu) / sigma;

%Indices
leftIdx = topUp_zScore < 0;
rightIdx = topUp_zScore > 0;

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
    %determine if profiles  of session is above or below mean and place in
    %appropriate matrix
    if leftIdx(nSession) == 1
        leftProfiles = [leftProfiles;comboPros(:,:)];
    elseif rightIdx(nSession) == 1
        rightProfiles = [rightProfiles;comboPros(:,:)];
    end
end
end
