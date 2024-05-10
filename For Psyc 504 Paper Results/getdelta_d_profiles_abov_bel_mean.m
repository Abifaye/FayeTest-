function [leftProfiles, rightProfiles] = getdelta_d_profiles_abov_bel_mean
%loads master table with profiles, gets the function to grab delta
%dprimes, computes its z-score using sigma and mu from curve fitting, and
%sorts them between above and below mean using matrices to place them.

%get delta_d
delta_d = getdelta_d;

%load master table with profiles
load(uigetfile('','Select desired master table'));

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
%Init matrices for profiles below (leftprofiles) and above (rightprofiles)
%meanadfasfasf
leftProfiles = [];
rightProfiles = [];

%% loop through all sessions
for nSession = 1:height(T)
    %get all hit & miss profiles from session
    hitPros = cell2mat(T.hitProfiles(nSession)); 
    missPros = cell2mat(T.missProfiles(nSession)); 
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