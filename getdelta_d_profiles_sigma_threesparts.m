function [leftProfiles, rightProfiles] = getdelta_d_profiles_sigma_threesparts
%loads master table with the hit profiles, gets the function to grab delta
%dprimes, computes its z-score using sigma and mu from curve fitting, and
%sorts them (delta d<=-1sigma, -1sigma<delta d'<=+1sigma, d'>+1sigma) using matrices to place them.
%Then, bootstraps the three matrices and create a plot with SEM. 


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
leftSigmaIdx = deltaD_zScore <= -1;
betweenSigmaIdx =(-1<deltaD_zScore & deltaD_zScore<=1); 
rightSigmaIdx = deltaD_zScore > 1;

%Init matrices for profiles below (leftprofiles) and above (rightprofiles)
%mean
leftProfiles = [];
betweenProfiles = [];
rightProfiles = [];

% loop through all sessions
for nSession = 1:height(TablewithcomboProsProfiles)
    %get all hit & miss profiles from session
     hitPros = cell2mat(struct2cell(TablewithProfiles.HitProfiles(nSession)));
    missPros = cell2mat(struct2cell(TablewithProfiles.MissProfiles(nSession)));
    comboPros = [hitPros;-missPros];
    %determine if delta_d of session is above or below mean and place in
    %appropriate matrix
    if leftSigmaIdx(nSession) == 1
        leftProfiles = [leftProfiles; comboPros(:,:)];
    elseif betweenSigmaIdx(nSession) == 1
        betweenProfiles = [betweenProfiles; comboPros(:,:)];
    elseif rightSigmaIdx(nSession) == 1
        rightProfiles = [rightProfiles; comboPros(:,:)];
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
title('\fontsize{11}Mean Profiles of Delta dprimes for +/- 1 Sigma');
ax.XTick = [0, 100, 200, 300, 400, 500, 600, 700, 800];
ax.XTickLabel = {'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'};
%ax.YTick = [0.48, 0.49, 0.5, 0.51];
ax.FontSize = 11;
ax.TickDir = "out";
hold off;

end