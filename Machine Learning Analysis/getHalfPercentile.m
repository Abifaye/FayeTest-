function [topPercentile,btmPercentile] = getHalfPercentile
% Splits RTs into top and bottom half percentile and takes the corresponding
% hit profiles and create a plot. Then it bootstraps each percentile and
% plot it with its SEM

%% Initialize variables
%Go to folder containing master table
folderPath = uigetdir('','Select Folder Containing Master Table');

%load master table with hit profiles file 
load('TablewithHitProfiles.mat');


%init locations for top + btm profiles
topPercentile = [];
btmPercentile = [];

%% Create loop for getting hit profiles and putting them in topPros/btmPros matrix
%loop through all sessions
for nSession = 1:height(TablewithHitProfiles)
    %create variables for hit profiles and reaction times from the master
    %table
    RTs = cell2mat(TablewithHitProfiles.stimCorrectRTs(nSession));
    hitPros = cell2mat(struct2cell(TablewithHitProfiles.HitProfiles(nSession)));

    %creates range for top and bottom percentile
    topIdx = (RTs >= min(prctile(RTs,[0 50])) & RTs <= max(prctile(RTs,[0 50])));
    btmIdx = (RTs > min(prctile(RTs,[50 100])) & RTs <= max(prctile(RTs,[50 100])));

    %Grabs all trials in current session and appends them to the matrix
    topPercentile = [topPercentile; hitPros(topIdx,:)];
    btmPercentile = [btmPercentile; hitPros(btmIdx,:)];

end

% Correct the values since we aren't including the misses
topPercentile = topPercentile/2 + 0.5;
btmPercentile = btmPercentile/2 + 0.5;

%% Graphs
figure;
hold on
plot(mean(topPercentile,1),Color='b')
plot(mean(btmPercentile,1),Color='r')
hold off
title('Half Percentile of Mean Hit Profiles')
legend('Top Half Percentile','Bottom Half Percentile','Location','southwest')
xticklabels({'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'});

%% Filter SetUp

% Set Up Filter for Profiles
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

%% Bootstrap

% Compute Top Half Percentile w/ SEM
boottop = bootstrp(1000,@mean,topPercentile);
topPCs = prctile(boottop, [15.9, 50, 84.1]);              % +/- 1 SEM
topPCMeans = mean(topPCs, 2);
topCIs = zeros(3, size(topPercentile, 2));
for c = 1:3
    topCIs(c,:) = filtfilt(filterLP, topPCs(c,:) - topPCMeans(c)) + topPCMeans(c);
end
topx = 1:size(topCIs, 2);
x2 = [topx, fliplr(topx)];
bins = size(topCIs,2);

%2nd Tertile w/ SEM
bootbtm = bootstrp(1000,@mean,btmPercentile);
btmPCs = prctile(bootbtm, [15.9, 50, 84.1]);              % +/- 1 SEM
btmPCMeans = mean(btmPCs, 2);
btmCIs = zeros(3, size(btmPercentile, 2));
for c = 1:3
    btmCIs(c,:) = filtfilt(filterLP, btmPCs(c,:) - btmPCMeans(c)) + btmPCMeans(c);
end
btmx = 1:size(btmCIs, 2);

%% Plot Bootstrap w/ SEM
figure;
hold on;
 

%Top Half
plot(topx, topCIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
topfillCI = [topCIs(1, :), fliplr(topCIs(3, :))]; % This sets up the fill for the errors
fill(x2, topfillCI, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

%Bottom Half
plot(btmx, btmCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
btmfillCI = [btmCIs(1, :), fliplr(btmCIs(3, :))]; % This sets up the fill for the errors
fill(x2, btmfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

legend('Top Half Percentile','', 'Bottom Half Percentile', '','Location','southwest');
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
title('Half Percentile of Mean Hit Profiles');
ax.XTick = [0, 100, 200, 300, 400, 500, 600, 700, 800];
ax.XTickLabel = {'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'};
ax.YTick = [0.48, 0.49, 0.5, 0.51];
ax.FontSize = 14;
ax.TickDir = "out";
hold off;

find(TablewithProfiles.animal)

strfind(A)
A = TablewithProfiles.animal
 
end