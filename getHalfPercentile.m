function [topPros,btmPros] = getHalfPercentile
% Splits RTs into top and bottom half percentile and takes the corresponding
% hit profiles

%% Initialize variables
%Go to folder containing hit profiles

endcd 'C:\Users\afbar\OneDrive - University of Calgary\Documents\GitHub\FayeTest-'
%load master table with hit profiles file 
load('TablewithHitProfiles.mat');
%getmasterRTs
%init locations for top + btm profiles
topPros = [];
btmPros = [];
%% Create loop for getting hit profiles and putting them in topPros/btmPros matrix
%loop through all sessions
for nSession = 1:height(TablewithHitProfiles)
    %create variables for hit profiles and reaction times from the master
    %table
    RTs = cell2mat(TablewithHitProfiles.stimCorrectRTs(nSession));
    hitPros = cell2mat(struct2cell(TablewithHitProfiles.HitProfiles(nSession)));
    %Create logical index for the top + btm percentile of RTs. prctile function
    %creates range for top and bottom percentile
    topIdx = (RTs >= min(prctile(RTs,[0 50])) & RTs <= max(prctile(RTs,[0 50])));
    btmIdx = (RTs > min(prctile(RTs,[50 100])) & RTs <= max(prctile(RTs,[50 100])));
    %Grabs all trials in current session and appends them to the matrix
    topPros = [topPros; hitPros(topIdx,:)];
    btmPros = [btmPros; hitPros(btmIdx,:)];
end
clf;
hold on
plot(mean(topPros/2 + 0.5,1),Color='b')
plot(mean(btmPros/2 + 0.5,1),Color='r')
hold off
title('Half Percentile of Mean Hit Profiles')
legend('Top Half Percentile','Bottom Half Percentile','Location','southwest')
end