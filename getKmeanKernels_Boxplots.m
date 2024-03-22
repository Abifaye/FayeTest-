function getKmeanKernels_Boxplots
%load necessary files
load('masterTable_allLuminanceTrials.mat')
load("normData_hitRTs.mat")
load("masterDBDataTable_hitsRTs.mat")
load('FiveClusterKmeansLabels.mat')

%% Set up kernel profiles
    %Create 2 matrices containing all hits and all miss profiles
    hitProfiles = cell2mat(T.hitProfiles);
    missProfiles = cell2mat(T.missProfiles);

    %Take only miss+hits trials with optopower
    optoHitClusters = masterClusters(strcmp(masterDBDataTable.trialEnd,"hit") & masterDBDataTable.optoPower~=0);
    optoMissClusters = masterClusters(strcmp(masterDBDataTable.trialEnd,"miss") & masterDBDataTable.optoPower~=0);

    %separate the profiles by each cluster
    firstProfiles = [hitProfiles(optoHitClusters==1,1:end); -missProfiles(optoMissClusters==1,1:end)];
    secondProfiles = [hitProfiles(optoHitClusters==2,1:end); -missProfiles(optoMissClusters==2,1:end)];
    thirdProfiles = [hitProfiles(optoHitClusters==3,1:end); -missProfiles(optoMissClusters==3,1:end)];
    fourthProfiles = [hitProfiles(optoHitClusters==4,1:end); -missProfiles(optoMissClusters==4,1:end)];
    fifthProfiles = [hitProfiles(optoHitClusters==5,1:end); -missProfiles(optoMissClusters==5,1:end)];
    %sixthProfiles = [hitProfiles(optoHitClusters==6,1:end); -missProfiles(optoMissClusters==6,1:end)];
    %seventhProfiles = [hitProfiles(optoHitClusters==7,1:end); -missProfiles(optoMissClusters==7,1:end)];


%% Filter SetUp
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

%% Bootstrap and graphs

%Init Vars
profiles_struct = struct('firstProfiles',firstProfiles,'secondProfiles',secondProfiles,'thirdProfiles',thirdProfiles,'fourthProfiles',fourthProfiles,'fifthProfiles',fifthProfiles);
profile_names = fieldnames(profiles_struct);
clr = 'rkgbm'; %colours of each cluster

%create tiled layout for all plots
figure('Position',[1 1 750 1500]);
t= tiledlayout(3,2);
title(t,'Comparison of Kernels Across the Five Clusters',"FontSize",15)
tileOrder = [2 5 3 4 1]; %places the graphs in right place
% Compute each profile w/ SEM
for nProfiles = 1:length(profile_names)
    boot = bootstrp(1000,@mean,profiles_struct.(string(profile_names(nProfiles))));
    PCs = prctile(boot, [15.9, 50, 84.1]);              % +/- 1 SEM
    PCMeans = mean(PCs, 2);
    CIs = zeros(3, size(profiles_struct.(string(profile_names(nProfiles))), 2));

    for c = 1:3
        CIs(c,:) = filtfilt(filterLP, PCs(c,:) - PCMeans(c)) + PCMeans(c);
    end

    x = 1:size(CIs, 2);
    x2 = [x, fliplr(x)];
    bins = size(CIs,2);

    %plots
    nexttile(tileOrder(nProfiles));
    hold on
    plot(x, CIs(2, :), clr(nProfiles), 'LineWidth', 1.5); % This plots the mean of the bootstrap
    fillCI = [CIs(1, :), fliplr(CIs(3, :))]; % This sets up the fill for the errors
    fill(x2, fillCI, clr(nProfiles), 'lineStyle', '-', 'edgeColor', clr(nProfiles), 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill
    yline(0,'--k')
    hold off
    ylim([-0.06 0.05])
    title(string(profile_names(nProfiles)))
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

%% Boxplots
figure('Position',[1 1 750 1500]);
t= tiledlayout(3,3);
title(t,'Comparison of Variables Boxplots Across the Five Clusters',"FontSize",14)
tileOrder = [1 2 4 5 7 8]; %places the graphs in right place
Vars = 5:9; %vars in masterDBTable to reiterate through
for nVar = 1:length(Vars)
    nexttile(tileOrder(nVar));
    boxplot(masterDBDataTable.(Vars(nVar)),masterClusters,'Colors','rkgbm','Symbol','.' )
    ylabel(masterDBDataTable.Properties.VariableNames(Vars(nVar)))
    xlabel('Cluster')
    title(strcat(masterDBDataTable.Properties.VariableNames(Vars(nVar)),' by Clusters'))
    set(gca,"FontSize",14)
    b.JitterOutliers = 'on';
b.MarkerStyle = '.';
end

