function [leftProfiles, rightProfiles] = getdelta_d_profiles_abov_bel_mean
%loads master table with the hit profiles, gets the function to grab delta
%dprimes, computes its z-score using sigma and mu from curve fitting, and
%sorts them between above and below mean using matrices to place them.
%Then, bootstraps the two matrices and create a plot with SEM. 
%   Detailed explanation goes here

%get delta_d
delta_d = getdelta_d;

%load master table with hit profiles
load('TablewithProfiles.mat');

%% Curve Fitting delta d'
d_histcounts = histcounts(delta_d,-5:0.15:5);
d_range = -4.9:0.15:4.9;

%% Profiles Above and Below Mean

% Z-score
amp =  171.3;
mu = -0.04869;
sigma = 0.2824;
deltaD_zScore = (delta_d - mu) / sigma;

%Indices 
leftIdx = deltaD_zScore < 0;
rightIdx = deltaD_zScore > 0;

%Init matrices for profiles below (leftprofiles) and above (rightprofiles)
%mean
leftProfiles = [];
rightProfiles = [];

% loop through all sessions
for nSession = 1:height(TablewithProfiles)
    %get all hit profiles from session
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

%% Plots

%below mean
figure;
plot(mean(leftProfiles,1))
title('Mean Hit Profiles Below Mean for Delta dprimes')
xticklabels({'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'});
%above mean
figure;
plot(mean(rightProfiles,1))
title('Mean Hit Profiles Above Mean for Delta dprimes')
xticklabels({'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'});

% Filter SetUp

% Set Up Filter for Profiles
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

%% Bootstrap

% Compute below mean w/ SEM
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

%above mean w/ SEM
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
 

%below mean
plot(leftx, leftCIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
leftfillCI = [leftCIs(1, :), fliplr(leftCIs(3, :))]; % This sets up the fill for the errors
fill(x2, leftfillCI, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

%above mean
plot(rightx, rightCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
rightfillCI = [rightCIs(1, :), fliplr(rightCIs(3, :))]; % This sets up the fill for the errors
fill(x2, rightfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

legend('delta dprimes Below Mean','', 'delta dprimes Above Mean','Fontsize',7,'Location','southwest');
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
title('\fontsize{11}Mean Hit Profiles of Delta dprimes for Above and Below Mean');
ax.XTick = [0, 100, 200, 300, 400, 500, 600, 700, 800];
ax.XTickLabel = {'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'};
%ax.YTick = [0.48, 0.49, 0.5, 0.51];
ax.FontSize = 11;
ax.TickDir = "out";
hold off;

end