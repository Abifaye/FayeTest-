function [leftProfiles, rightProfiles] = getstimC_profiles_sigma_foursparts
%loads master table with the profiles, gets the function to grab stimulated
%Criterion, computes its z-score using sigma and mu from curve fitting, and
%sorts them (stimC<=-1sigma, -1sigma<stimC<=mean, mean<stimC<=+1sigma, stimC>+1sigma) using matrices to place them.
%Then, bootstraps the four matrices and create a plot with SEM. 

%get delta_C
stimC = [TablewithProfiles.stimC];

%load master table with profiles
load('TablewithProfiles.mat');

%% Curve Fitting stimC
C_histcounts = histcounts(stimC,-5:0.15:5);
C_range = -4.9:0.15:4.9;

%% Sorting Profiles

% Z-score
amp = 325.2;
mu =  0.06186;
sigma = 0.1497;
stimC_zScore = (stimC - mu) / sigma;

%Indices 
leftSigmaIdx = stimC_zScore <= -1;
lSigma_to_mean_idx = (-1<stimC_zScore & stimC_zScore<=0); 
mean_to_rSigma_idx = (0<stimC_zScore & stimC_zScore<=1); 
rightSigmaIdx = stimC_zScore > 1;

%Init matrices for profiles 
leftProfiles = [];
lSigma_to_mean_profiles = [];
mean_to_rSigma_profiles = [];
rightProfiles = [];

% loop through all sessions
for nSession = 1:height(TablewithProfiles)
   %get all hit & miss profiles from session
    hitPros = cell2mat(struct2cell(TablewithProfiles.HitProfiles(nSession)));
    missPros = cell2mat(struct2cell(TablewithProfiles.MissProfiles(nSession)));
    comboPros = [hitPros;-missPros];
    %determine if stimC of session is above or below mean and place in
    %appropriate matrix
    if leftSigmaIdx(nSession) == 1
        leftProfiles = [leftProfiles; comboPros(:,:)];
    elseif lSigma_to_mean_idx(nSession) == 1
        lSigma_to_mean_profiles = [lSigma_to_mean_profiles; comboPros(:,:)];
    elseif mean_to_rSigma_idx(nSession) == 1
        mean_to_rSigma_profiles = [mean_to_rSigma_profiles; comboPros(:,:)];
    elseif rightSigmaIdx(nSession) == 1
        rightProfiles = [rightProfiles; comboPros(:,:)];
    end
end

%% Plots

%below mean
figure;
plot(mean(leftProfiles,1))
title('Mean Profiles 1 Sigma Below of Delta dprimes')
xticklabels({'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'});

%-1 sigma to mean
figure;
plot(mean(lSigma_to_mean_profiles ,1))
title('delta Criterion Between -1 Sigma and Mean of Delta dprimes')
xticklabels({'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'});

%mean to +1 sigma
figure;
plot(mean(mean_to_rSigma_profiles,1))
title('delta Criterion Between Mean and +1 Sigma of Delta dprimes')
xticklabels({'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'});

%above mean
figure;
plot(mean(rightProfiles,1))
title('Mean Profiles 1 Sigma Above of Delta Criterion')
xticklabels({'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'});

%% Filter SetUp

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

% -1 sigma to mean w/ SEM
bootLSigma_to_mean = bootstrp(1000,@mean,lSigma_to_mean_profiles);
lSigma_to_meanPCs = prctile(bootLSigma_to_mean, [15.9, 50, 84.1]);              % +/- 1 SEM
lSigma_to_meanPCMeans = mean(lSigma_to_meanPCs, 2);
lSigma_to_meanCIs = zeros(3, size(lSigma_to_mean_profiles, 2));
for c = 1:3
    lSigma_to_meanCIs(c,:) = filtfilt(filterLP, lSigma_to_meanPCs(c,:) - lSigma_to_meanPCMeans(c)) + lSigma_to_meanPCMeans(c);
end
lSigma_to_meanx = 1:size(lSigma_to_meanCIs, 2);
x2 = [lSigma_to_meanx, fliplr(lSigma_to_meanx)];
bins = size(lSigma_to_meanCIs,2);

% mean to +1 sigma w/ SEM
bootMean_to_rSigma = bootstrp(1000,@mean,mean_to_rSigma_profiles);
mean_to_rSigmaPCs = prctile(bootMean_to_rSigma, [15.9, 50, 84.1]);              % +/- 1 SEM
mean_to_rSigmaPCMeans = mean(mean_to_rSigmaPCs, 2);
mean_to_rSigmaCIs = zeros(3, size(mean_to_rSigma_profiles, 2));
for c = 1:3
   mean_to_rSigmaCIs(c,:) = filtfilt(filterLP, mean_to_rSigmaPCs(c,:) - mean_to_rSigmaPCMeans(c)) + mean_to_rSigmaPCMeans(c);
end
mean_to_rSigmax = 1:size(mean_to_rSigmaCIs, 2);
x2 = [mean_to_rSigmax, fliplr(mean_to_rSigmax)];
bins = size(mean_to_rSigmaCIs,2);

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

% -1 sigma to mean w/ SEM
plot(lSigma_to_meanx, lSigma_to_meanCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
lSigma_to_meanfillCI = [lSigma_to_meanCIs(1, :), fliplr(lSigma_to_meanCIs(3, :))]; % This sets up the fill for the errors
fill(x2, lSigma_to_meanfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

% mean to +1 sigma w/ SEM
plot(mean_to_rSigmax, mean_to_rSigmaCIs(2, :), 'g', 'LineWidth', 1.5); % This plots the mean of the bootstrap
mean_to_rSigmafillCI = [mean_to_rSigmaCIs(1, :), fliplr(mean_to_rSigmaCIs(3, :))]; % This sets up the fill for the errors
fill(x2, mean_to_rSigmafillCI, 'g', 'lineStyle', '-', 'edgeColor', 'g', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

%above mean
plot(rightx, rightCIs(2, :), 'm', 'LineWidth', 1.5); % This plots the mean of the bootstrap
rightfillCI = [rightCIs(1, :), fliplr(rightCIs(3, :))]; % This sets up the fill for the errors
fill(x2, rightfillCI, 'm', 'lineStyle', '-', 'edgeColor', 'm', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill

legend('Stimulated Criterion 1 Sigma Below Mean','', 'Stimulated Criterion Between -1 Sigma and Mean','', ...
    'Stimulated Criterion Between mean and +1 Sigma','','Stimulated Criterion 1 Sigma Above Mean','Fontsize',5,'Location','southwest');
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
title('\fontsize{11}Mean Profiles of Stimulated Criterion for +/- 1 Sigma and Inbetween Mean');
ax.XTick = [0, 100, 200, 300, 400, 500, 600, 700, 800];
ax.XTickLabel = {'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'};
%ax.YTick = [0.48, 0.49, 0.5, 0.51];
ax.FontSize = 11;
ax.TickDir = "out";
hold off;

end