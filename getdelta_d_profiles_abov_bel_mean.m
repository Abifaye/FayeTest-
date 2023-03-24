function [leftProfiles, rightProfiles] = getdelta_d_profiles_abov_bel_mean
%loads master table with profiles, gets the function to grab delta
%dprimes, computes its z-score using sigma and mu from curve fitting, and
%sorts them between above and below mean using matrices to place them.
%Then, bootstraps the two matrices and create a plot with SEM. 

%get delta_d
delta_d = getdelta_d;

%load master table with profiles
load('TablewithProfiles.mat');

%% Curve Fitting delta d'
d_histcounts = histcounts(delta_d,-5:0.15:5);
d_range = -4.9:0.15:4.9;

% Z-score
amp =  171.3;
mu = -0.04869;
sigma = 0.2824;
deltaD_zScore = (delta_d - mu) / sigma;

%% Variables Initiation
%Indices 
leftIdx = deltaD_zScore < 0;
rightIdx = deltaD_zScore > 0;

%Init matrices for profiles below (leftprofiles) and above (rightprofiles)
%mean
leftProfiles = [];
rightProfiles = [];

%% loop through all sessions
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