function [firstTertile,secondTertile,thirdTertile] = getTertile
%Splits RTs into tertile and takes the corresponding
%hit profiles and plot it. It then bootsraps each tertile and create a plot
%of it with SEM
%% Initialize variables
folderPath = uigetdir();
%load master table with hit profiles file 
load('TablewithHitProfiles.mat');
%init locations for profiles in each tertile
firstTertile= [];
secondTertile = [];
thirdTertile = [];

%% Create loop for getting hit profiles and putting them in each Tertile matrix
%loop through all sessions
for nSession = 1:height(TablewithHitProfiles)
    %create variables for hit profiles and reaction times from the master
    %table
    RTs = cell2mat(TablewithHitProfiles.stimCorrectRTs(nSession));
    hitPros = cell2mat(struct2cell(TablewithHitProfiles.HitProfiles(nSession)));
   
    %creates range for each tertile
    firstIdx = (RTs >= min(prctile(RTs,[0 33.33])) & RTs <= max(prctile(RTs,[0 33.33])));
    secondIdx = (RTs > min(prctile(RTs,[33.33 66.67])) & RTs <= max(prctile(RTs,[33.33 66.67])));
    thirdIdx = (RTs > min(prctile(RTs,[66.67 100])) & RTs <= max(prctile(RTs,[66.67 100])));

    %Grabs all trials in current session and appends them to the matrix
    firstTertile = [firstTertile; hitPros(firstIdx,:)];
    secondTertile = [secondTertile; hitPros(secondIdx,:)];
    thirdTertile = [thirdTertile; hitPros(thirdIdx,:)];
end

% Correct the values since we aren't including the misses
firstTertile = firstTertile/2 + 0.5;
secondTertile = secondTertile/2 + 0.5;
thirdTertile = thirdTertile/2 + 0.5;

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

%% Get AOK

% Compute first AOK
bootfirst = bootstrp(100,@mean,firstTertile);
bootfirst = -(bootfirst);
for nBoot = 1:size(bootfirst,1)
    nAOK = sum(bootfirst(nBoot,401:500)); 
    firstAOK(nBoot) = nAOK;
end

%second AOK
bootsecond = bootstrp(100,@mean,secondTertile);
bootsecond = -(bootsecond);
for nBoot = 1:size(bootsecond,1)
    nAOK = sum(bootsecond(nBoot,401:500)); 
    secondAOK(nBoot) = nAOK;
end

%third AOK
bootthird = bootstrp(100,@mean,thirdTertile);
bootthird = -(bootthird);
for nBoot = 1:size(bootthird,1)
    nAOK = sum(bootthird(nBoot,401:500)); 
    thirdAOK(nBoot) = nAOK;
end



%% Plots

figure;
% 1st Tertile
subplot(3,2,1);
hold on
plot(firstx, firstCIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
firstfillCI = [firstCIs(1, :), fliplr(firstCIs(3, :))]; % This sets up the fill for the errors
fill(x2, firstfillCI, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill
hold off
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XTick = [0, 100, 200, 300, 400, 500, 600, 700, 800];
ax.XTickLabel = {'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [0.47 0.51]);
ay.FontSize = 8;
title('Kernel of First Tertile','FontSize',8);


% 2nd Tertile
subplot(2,3,3);
hold on
plot(secondx, secondCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
secondfillCI = [secondCIs(1, :), fliplr(secondCIs(3, :))]; % This sets up the fill for the errors
fill(x2, secondfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
hold off
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XTick = [0, 100, 200, 300, 400, 500, 600, 700, 800];
ax.XTickLabel = {'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [0.47 0.51]);
ay.FontSize = 8;
title('Kernel of Second Tertile','FontSize',8);

% 3rd Tertile
subplot(2,3,5);
hold on
plot(thirdx, thirdCIs(2, :), 'g', 'LineWidth', 1.5); % This plots the mean of the bootstrap
thirdfillCI = [thirdCIs(1, :), fliplr(thirdCIs(3, :))]; % This sets up the fill for the errors
fill(x2, thirdfillCI, 'g', 'lineStyle', '-', 'edgeColor', 'g', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill
hold off
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XTick = [0, 100, 200, 300, 400, 500, 600, 700, 800];
ax.XTickLabel = {'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [0.47 0.51]);
ay.FontSize = 8;
title('Kernel of Third Tertile','FontSize',8);


%AOK

%1st
subplot(2,3,2);
histogram(firstAOK,'Normalization','probablity',FaceColor="b")
title('AoK of First Tertile','FontSize',8);
ay = gca;
%ylim(ay, [0 30]);
ay.FontSize = 8;
ax = gca;
%xlim(ax, [48.6, 50.6]);
%ax.XTick = [-2.5:0.5:2.5];
%ax.XTickLabel = {'', '-2', '', '-1', '', '0', '', '1', '', '2',''};
ax.FontSize = 7;
ax.TickDir = "out";

%2nd
subplot(2,3,4); 
histogram (secondAOK,'Normalization','probablity',FaceColor="r")
title('AoK of Second Tertile','FontSize',8);
ay = gca;
%ylim(ay, [0 30]); 
ay.FontSize = 8;
ax = gca;
%xlim(ax, [48.6, 50.6]);
%ax.XTick = [-2.5:0.5:2.5];
%ax.XTickLabel = {'', '-2', '', '-1', '', '0', '', '1', '', '2',''};
ax.FontSize = 7;
ax.TickDir = "out";

%3rd
subplot(2,3,6); 
histogram (thirdAOK,'Normalization','probablity',FaceColor="g")
title('AoK of Third Tertile','FontSize',8);
ay = gca;
%ylim(ay, [0 30]); %adjust to have same y-axis
ay.FontSize = 8;
ax = gca;
%xlim(ax, [48.6, 50.6]);
%ax.XTick = [-2.5:0.5:2.5];
%ax.XTickLabel = {'', '-2', '', '-1', '', '0', '', '1', '', '2',''};
ax.FontSize = 7;
ax.TickDir = "out";

 
end