function [outputArg1,outputArg2] = getTopUpDprimes_profiles_sigma_threesparts
%UNTITLED2 Summary of this function goes here

%Detailed explanation goes here
folderPath = uigetdir();

%load file containing stimulated/non d'
load('TablewithHitProfiles.mat');

%allocate the variables
topUpDPrimes = [TablewithHitProfiles.topUpDPrime];

%curve fitting
dTopUp_histcounts = histcounts(topUpDPrimes,-6:0.2:6);
dTopUp_range = -5.99:0.2:5.99;

%Z-score
[amp,mu,sigma] = get(uigetfile({'*.m'}, 'File Selector'));
dTopUp_zScore = (topUpDPrimes - mu) / sigma;

%Indices 
leftSigmaIdx = dTopUp_zScore <= -1;
betweenSigmaIdx =(-1<dTopUp_zScore & dTopUp_zScore<=1); 
rightSigmaIdx = dTopUp_zScore > 1;

%Init matrices for profiles below (leftprofiles) and above (rightprofiles)
%mean
leftProfiles = [];
betweenProfiles = [];
rightProfiles = [];

% loop through all sessions
for nSession = 1:height(TablewithHitProfiles)
    %get all hit profiles from session
    hitPros = cell2mat(struct2cell(TablewithHitProfiles.HitProfiles(nSession)));
    %determine if delta_d of session is above or below mean and place in
    %appropriate matrix
    if leftSigmaIdx(nSession) == 1
        leftProfiles = [leftProfiles; hitPros(:,:)];
    elseif betweenSigmaIdx(nSession) == 1
        betweenProfiles = [betweenProfiles; hitPros(:,:)];
    elseif rightSigmaIdx(nSession) == 1
        rightProfiles = [rightProfiles; hitPros(:,:)];
    end

end

%% Plots

%below mean
figure;
plot(mean(leftProfiles,1))
title('Mean Hit Profiles 1 Sigma Below for Delta dprimes')
xticklabels({'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'});
%between mean
figure;
plot(mean(betweenProfiles,1))
title('Mean Hit Profiles Between -1 and +1 Sigma for Delta dprimes')
xticklabels({'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'});
%above mean
figure;
plot(mean(rightProfiles,1))
title('Mean Hit Profiles 1 Sigma Above for Delta dprimes')
xticklabels({'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'});

%Bootstrap

% Filter SetUp

% Set Up Filter for Profiles
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

%% Bootstrap

% Compute sigma 1 below w/ SEM
bootleft = bootstrp(1000,@mean,leftProfiles);
leftPCs = prctile(bootleft, [15.9, 50, 84.1]);              % +/- 1 SEM
leftPCMeans = mean(leftPCs, 2);
leftCIs = zeros(3, size(leftProfiles, 2));
for c = 1:3
    leftCIs(c,:) = filtfilt(filterLP, leftPCs(c,:) - leftPCMeans(c)) + leftPCMeans(c);
end
leftx = 1:size(leftCIs, 2);
x2 = [leftx, fliplr(leftx)];
bins = size(leftCIs,2);

% between -1 and +1 sigma w/ SEM
bootbetween = bootstrp(1000,@mean,betweenProfiles);
betweenPCs = prctile(bootbetween, [15.9, 50, 84.1]);              % +/- 1 SEM
betweenPCMeans = mean(betweenPCs, 2);
betweenCIs = zeros(3, size(betweenProfiles, 2));
for c = 1:3
    betweenCIs(c,:) = filtfilt(filterLP, betweenPCs(c,:) - betweenPCMeans(c)) + betweenPCMeans(c);
end
betweenx = 1:size(betweenCIs, 2);
x2 = [betweenx, fliplr(betweenx)];
bins = size(betweenCIs,2);

%sigma 1 above w/ SEM
bootright = bootstrp(1000,@mean,rightProfiles);
rightPCs = prctile(bootright, [15.9, 50, 84.1]);              % +/- 1 SEM
rightPCMeans = mean(rightPCs, 2);
rightCIs = zeros(3, size(rightProfiles, 2));
for c = 1:3
    rightCIs(c,:) = filtfilt(filterLP, rightPCs(c,:) - rightPCMeans(c)) + rightPCMeans(c);
end
rightx = 1:size(rightCIs, 2);

%% Plot Bootstrap w/ SEM
figure;
hold on;
 

%sigma 1 below
plot(leftx, leftCIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
leftfillCI = [leftCIs(1, :), fliplr(leftCIs(3, :))]; % This sets up the fill for the errors
fill(x2, leftfillCI, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

%between -1 and =1 sigma
plot(betweenx, betweenCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
betweenfillCI = [betweenCIs(1, :), fliplr(betweenCIs(3, :))]; % This sets up the fill for the errors
fill(x2, betweenfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

%above mean
plot(rightx, rightCIs(2, :), 'g', 'LineWidth', 1.5); % This plots the mean of the bootstrap
rightfillCI = [rightCIs(1, :), fliplr(rightCIs(3, :))]; % This sets up the fill for the errors
fill(x2, rightfillCI, 'g', 'lineStyle', '-', 'edgeColor', 'g', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

legend('delta dprimes 1 Sigma Below Mean','', 'delta dprimes Between -1 and +1 Sigma','', ...
    'delta dprimes 1 Sigma Above Mean','Fontsize',7,'Location','southwest');
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
title('\fontsize{11}Hit Profiles of Delta dprimes for +/- 1 Sigma');
ax.XTick = [0, 100, 200, 300, 400, 500, 600, 700, 800];
ax.XTickLabel = {'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'};
%ax.YTick = [0.48, 0.49, 0.5, 0.51];
ax.FontSize = 11;
ax.TickDir = "out";
hold off;
end