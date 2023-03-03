function [firstTertile,secondTertile,thirdTertile,fourthTertile] = getQuartile
%Splits RTs into quartiles and takes the corresponding
%hit profiles and create a plot of it. Then, it bootstraps each quartile
%and plot a graph of it with its SEM

%% Initialize variables
folderPath = uigetdir();
%load master table with hit profiles file 
load('TablewithHitProfiles.mat');
%init locations for profiles in each quartile
firstTertile = [];
secondTertile = [];
thirdTertile = [];
fourthTertile = [];

%% Create loop for getting hit profiles and putting them in topPros/btmPros matrix
%loop through all sessions
for nSession = 1:height(TablewithHitProfiles)
    %create variables for hit profiles and reaction times from the master
    %table
    RTs = cell2mat(TablewithHitProfiles.stimCorrectRTs(nSession));
    hitPros = cell2mat(struct2cell(TablewithHitProfiles.HitProfiles(nSession)));
   
    %creates range for each quartile
     firstIdx = (RTs >= min(prctile(RTs,[0 25])) & RTs <= max(prctile(RTs,[0 25])));
    secondIdx =(RTs > min(prctile(RTs,[25.01 50])) & RTs <= max(prctile(RTs,[25.01 50])));
    thirdIdx = (RTs > min(prctile(RTs,[50.01 75])) & RTs <= max(prctile(RTs,[50.01 75])));
    fourthIdx = (RTs > min(prctile(RTs,[75.01 100])) & RTs <= max(prctile(RTs,[75.01 100])));
    
    %Grabs all trials in current session and appends them to the matrices
    firstTertile = [firstTertile; hitPros(firstIdx,:)];
    secondTertile = [secondTertile; hitPros(secondIdx,:)];
    thirdTertile = [thirdTertile; hitPros(thirdIdx,:)];
    fourthTertile = [fourthTertile; hitPros(fourthIdx,:)];
end

% Correct the values since we aren't including the misses
firstTertile = firstTertile/2 + 0.5;
secondTertile = secondTertile/2 + 0.5;
thirdTertile = thirdTertile/2 + 0.5;
fourthTertile = fourthTertile/2 + 0.5;

%% Graphs

%graph 1
figure;
quartileGraphs = tiledlayout(4,1,"TileSpacing","tight","Padding","tight");
title(quartileGraphs,'Quartile of Mean Hit Profiles')
%1
nexttile
plot(mean(firstTertile/2 + 0.5,1),color='b')
title('First Quartile')
ylim([0.735 0.76])
%2
nexttile
plot(mean(secondTertile/2 + 0.5,1),Color='r')
title('Second Quartile')
ylim([0.735 0.76])
%3
nexttile
plot(mean(thirdTertile/2 + 0.5,1),Color='g')
title('Third Quartile')
ylim([0.735 0.76])
%4
nexttile
plot(mean(fourthTertile/2 + 0.5,1),Color='m')
title('Fourth Quartile')
ylim([0.735 0.76])

%Graph 2
figure;
hold on
plot(mean(firstTertile/2 + 0.5,1),color='b')
plot(mean(secondTertile/2 + 0.5,1),Color='r')
plot(mean(thirdTertile/2 + 0.5,1),Color='g')
plot(mean(fourthTertile/2 + 0.5,1),Color='m')
hold off
title('Quartile of Mean Hit Profiles')

%% Filter SetUp

% Set Up Filter for Profiles
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

%% Bootstrap

% Compute 1st Tertile w/ SEM
bootfirst = bootstrp(1000,@mean,firstTertile);
firstPCs = prctile(bootfirst, [15.9, 50, 84.1]);              % +/- 1 SEM
firstPCMeans = mean(firstPCs, 2);
firstCIs = zeros(3, size(firstTertile, 2));
for c = 1:3
    firstCIs(c,:) = filtfilt(filterLP, firstPCs(c,:) - firstPCMeans(c)) + firstPCMeans(c);
end
firstx = 1:size(firstCIs, 2);
x2 = [firstx, fliplr(firstx)];
bins = size(firstCIs,2);

%2nd Tertile
bootsecond = bootstrp(1000,@mean,secondTertile);
secondPCs = prctile(bootsecond, [15.9, 50, 84.1]);              % +/- 1 SEM
secondPCMeans = mean(secondPCs, 2);
secondCIs = zeros(3, size(secondTertile, 2));
for c = 1:3
    secondCIs(c,:) = filtfilt(filterLP, secondPCs(c,:) - secondPCMeans(c)) + secondPCMeans(c);
end
secondx = 1:size(secondCIs, 2);

%3rd Tertile
bootthird = bootstrp(1000,@mean,thirdTertile);
thirdPCs = prctile(bootthird, [15.9, 50, 84.1]);              % +/- 1 SEM
thirdPCMeans = mean(thirdPCs, 2);
thirdCIs = zeros(3, size(thirdTertile, 2));
for c = 1:3
    thirdCIs(c,:) = filtfilt(filterLP, thirdPCs(c,:) - thirdPCMeans(c)) + thirdPCMeans(c);
end
thirdx = 1:size(thirdCIs, 2);

% Compute 4th Tertile w/ SEM
bootfourth = bootstrp(1000,@mean,fourthTertile);
fourthPCs = prctile(bootfourth, [15.9, 50, 84.1]);              % +/- 1 SEM
fourthPCMeans = mean(fourthPCs, 2);
fourthCIs = zeros(3, size(fourthTertile, 2));
for c = 1:3
    fourthCIs(c,:) = filtfilt(filterLP, fourthPCs(c,:) - fourthPCMeans(c)) + fourthPCMeans(c);
end
fourthx = 1:size(fourthCIs, 2);
x2 = [fourthx, fliplr(fourthx)];
bins = size(fourthCIs,2);

%% Plot Bootstrap w/ SEM
figure;
hold on;


% 1st Tertile
plot(firstx, firstCIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
firstfillCI = [firstCIs(1, :), fliplr(firstCIs(3, :))]; % This sets up the fill for the errors
fill(x2, firstfillCI, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

% 2nd Tertile
plot(secondx, secondCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
secondfillCI = [secondCIs(1, :), fliplr(secondCIs(3, :))]; % This sets up the fill for the errors
fill(x2, secondfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

% 3rd Tertile
plot(thirdx, thirdCIs(2, :), 'g', 'LineWidth', 1.5); % This plots the mean of the bootstrap
thirdfillCI = [thirdCIs(1, :), fliplr(thirdCIs(3, :))]; % This sets up the fill for the errors
fill(x2, thirdfillCI, 'g', 'lineStyle', '-', 'edgeColor', 'g', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

legend('First Tertile','', 'Second Tertile', '', 'Third Tertile',...
    'Location','southwest');

% 4th Tertile
plot(fourthx, fourthCIs(2, :), 'm', 'LineWidth', 1.5); % This plots the mean of the bootstrap
fourthfillCI = [fourthCIs(1, :), fliplr(thirdCIs(3, :))]; % This sets up the fill for the errors
fill(x2, fourthfillCI, 'm', 'lineStyle', '-', 'edgeColor', 'm', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

legend('First Tertile','', 'Second Tertile', '', 'Third Tertile',...
    '', 'Fourth Tertile','Location','southwest');

ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
title('Quartile of Mean Hit Profiles');
ax.XTick = [0, 100, 200, 300, 400, 500, 600, 700, 800];
ax.XTickLabel = {'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'};
ax.YTick = [0.48, 0.49, 0.5, 0.51];
ax.FontSize = 14;
ax.TickDir = "out";
hold off;
 

end

