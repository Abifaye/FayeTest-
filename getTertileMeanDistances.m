function getTertileMeanDistances
%% Calculate Mean Distance Distribution (trials with profiles only)
%load necessary variables
load masterDBDataTable.mat
load normData.mat

%hits
hits_w_profiles = normData(strcmp(masterDBDataTable.trialEnd,"hit") & masterDBDataTable.optoPower~=0,1:5);
distOfHitProfs = pdist(hits_w_profiles,"euclidean"); %distances btwn each data points
squareformedDistances_hits = [];
squareformedDistances_hits = squareform(distOfHitProfs); %squareform  distances
triSquareformed_hits = triu(squareformedDistances_hits); %remove repeated points from squareform
MtriSquareformed_hits = mean(triSquareformed_hits); %calculate mean of all distances for each trial
%nBins = -20:0.05:20;

%miss
miss_w_profiles = normData(strcmp(masterDBDataTable.trialEnd,"miss") & masterDBDataTable.optoPower~=0,[1:3 5]);
distOfmissProfs = pdist(miss_w_profiles,"euclidean"); %distances btwn each data points
squareformedDistances_miss = [];
squareformedDistances_miss = squareform(distOfmissProfs);%squareform  distances
triSquareformed_miss = triu(squareformedDistances_miss); %remove repeated points from squareform
MtriSquareformed_miss = mean(triSquareformed_miss);%calculate mean of all distances for each trial
%nBins = -20:0.05:20;

%Distributions plots
%figure;
%histogram(MtriSquareformed_miss)%nBins)

%figure;
%histogram(MtriSquareformed_hits)%nBins)

%% Cluster Distances into Tertile

%creates range for each tertile
firstIdx = (MtriSquareformed_miss >= min(prctile(MtriSquareformed_miss,[0 33.33])) & MtriSquareformed_miss <= max(prctile(MtriSquareformed_miss,[0 33.33]))); %can also use Hit var instead
secondIdx = (MtriSquareformed_miss > min(prctile(MtriSquareformed_miss,[33.33 66.67])) & MtriSquareformed_miss <= max(prctile(MtriSquareformed_miss,[33.33 66.67])));
thirdIdx = (MtriSquareformed_miss > min(prctile(MtriSquareformed_miss,[66.67 100])) & MtriSquareformed_miss <= max(prctile(MtriSquareformed_miss,[66.67 100])));

%load master table with hit profiles file
load('masterTable_allLuminanceTrials.mat')

%Create 2 matrices containing all hits and all miss profiles
hitProfiles = cell2mat(T.hitProfiles);
missProfiles = cell2mat(T.missProfiles);

%miss
firstTertile_miss = missProfiles(firstIdx,1:end);
secondTertile_miss = missProfiles(secondIdx,1:end);
thirdTertile_miss = missProfiles(thirdIdx,1:end);

%hit
firstTertile_hit = hitProfiles(firstIdx,1:end);
secondTertile_hit = hitProfiles(secondIdx,1:end);
thirdTertile_hit = hitProfiles(thirdIdx,1:end);

%all
firstTertile_all = [firstTertile_hit; -firstTertile_miss];
secondTertile_all = [secondTertile_hit; -secondTertile_miss];
thirdTertile_all = [thirdTertile_hit; -thirdTertile_miss];


%no tertiles all
%all_profiles = [hitProfiles; -missProfiles];
%% plots
% Filter SetUp
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

%create struct so can loop through each matrix
tertileStruct = struct('FirstTertile',firstTertile_all,'SecondTertile',secondTertile_all,'ThirdTertile',thirdTertile_all);
%loop through tertile struct
tertileFields = fieldnames(tertileStruct);
%create tiled layout for all plots
figure;
t= tiledlayout(3,1);
title(t,'Comparison of Kernels Across the Five Clusters',"FontSize",15)
clr = 'rgbmk';

for nTertile = 1:length(tertileFields)
    boot = bootstrp(1000,@mean,tertileStruct.(string(tertileFields(nTertile))));
    PCs = prctile(boot, [15.9, 50, 84.1]);              % +/- 1 SEM
    PCMeans = mean(PCs, 2);
    CIs = zeros(3, size(tertileStruct.(string(tertileFields(nTertile))), 2));

    for c = 1:3
        CIs(c,:) = filtfilt(filterLP, PCs(c,:) - PCMeans(c)) + PCMeans(c);
    end

    x = 1:size(CIs, 2);
    x2 = [x, fliplr(x)];
    bins = size(CIs,2);

    %plots
    nexttile;
    hold on
    plot(x, CIs(2, :),clr(nTertile),'LineWidth', 1.5); % This plots the mean of the bootstrap
    fillCI = [CIs(1, :), fliplr(CIs(3, :))]; % This sets up the fill for the errors
    fill(x2, fillCI, clr(nTertile), 'lineStyle', '-', 'edgeColor', clr(nTertile), 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill
    yline(0,'--k')
    hold off
    ylim([-0.06 0.05])
    title(string(tertileFields(nTertile)))
    set(gca,"FontSize",15)
    ax = gca;
    ax.XGrid = 'on';
    ax.XMinorGrid = "on";
    ax.XTick = [0:200:800];
    ax.XTickLabel = {'-400', '', '0', '', '400'};
    ax.TickDir = "out";
    xlabel('Time (ms)')
    ylabel('Normalized Power')
end

%Extra Figures
figure;
hold on
plot(mean(firstTertile_all))
plot(mean(all_profiles))
legend('First Tertile', 'All Profiles')

figure;
hold on
plot(mean(secondTertile_all))
plot(mean(all_profiles))
legend('Second Tertile', 'All Profiles')

figure;
hold on
plot(mean(thirdTertile_all))
plot(mean(all_profiles))
legend('Third Tertile', 'All Profiles')
end