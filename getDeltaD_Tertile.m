function [outputArg1,outputArg2] = getDeltaD_Tertile
%UNTITLED5 Summary of this function goes here

%get delta_d
delta_d = getdelta_d;

%load master table with profiles
load('TablewithProfiles.mat');

%% Sort Profiles

%Init matrices for profiles
firstTertile= [];
secondTertile = [];
thirdTertile = [];

%Indices
firstIdx = (delta_d >= min(prctile(delta_d,[0 33.33])) & delta_d <= max(prctile(delta_d,[0 33.33])));
secondIdx = (delta_d > min(prctile(delta_d,[33.33 66.67])) & delta_d <= max(prctile(delta_d,[33.33 66.67])));
thirdIdx = (delta_d > min(prctile(delta_d,[66.67 100])) & delta_d <= max(prctile(delta_d,[66.67 100])));

% loop through all sessions
for nSession = 1:height(TablewithProfiles)
    %get all hit & miss profiles from session
    hitPros = cell2mat(struct2cell(TablewithProfiles.HitProfiles(nSession)));
    missPros = cell2mat(struct2cell(TablewithProfiles.MissProfiles(nSession)));
    comboPros = [hitPros;-missPros];
    %determine where delta_d of session is in gaussian distribution and place in
    %appropriate matrix
    if firstIdx(nSession) == 1
        firstTertile = [firstTertile; comboPros(:,:)];
    elseif secondIdx(nSession) == 1
        secondTertile = [secondTertile; comboPros(:,:)];
    elseif thirdIdx(nSession) == 1
        thirdTertile = [thirdTertile; comboPros(:,:)];
    end

end

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

%2nd Tertile w/ SEM
bootsecond = bootstrp(1000,@mean,secondTertile);
secondPCs = prctile(bootsecond, [15.9, 50, 84.1]);              % +/- 1 SEM
secondPCMeans = mean(secondPCs, 2);
secondCIs = zeros(3, size(secondTertile, 2));
for c = 1:3
    secondCIs(c,:) = filtfilt(filterLP, secondPCs(c,:) - secondPCMeans(c)) + secondPCMeans(c);
end
secondx = 1:size(secondCIs, 2);

%3rd Tertile w/ SEM
bootthird = bootstrp(1000,@mean,thirdTertile);
thirdPCs = prctile(bootthird, [15.9, 50, 84.1]);              % +/- 1 SEM
thirdPCMeans = mean(thirdPCs, 2);
thirdCIs = zeros(3, size(thirdTertile, 2));
for c = 1:3
    thirdCIs(c,:) = filtfilt(filterLP, thirdPCs(c,:) - thirdPCMeans(c)) + thirdPCMeans(c);
end
thirdx = 1:size(thirdCIs, 2);

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

ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
title('Tertile of Delta dprime Profiles');
ax.XTick = [0, 100, 200, 300, 400, 500, 600, 700, 800];
ax.XTickLabel = {'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'};
ax.YTick = [0.48, 0.49, 0.5, 0.51];
ax.FontSize = 14;
ax.TickDir = "out";
hold off;
end