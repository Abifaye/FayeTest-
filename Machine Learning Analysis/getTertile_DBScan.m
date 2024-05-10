function [firstCluster,secondCluster,thirdTertile] = getTertile_DBScan


%% Initialize variables

%Go to folder with the master table
cd(uigetdir());

%load master table with hit profiles file
load('masterTable_allLuminanceTrials.mat')
%load DBHit.mat
%load DBMiss.mat
load DBStruct.mat
%load hitDataTable.mat
%load missDataTable.mat
load masterDBDataTable.mat

%init locations for profiles in each tertile
firstCluster= [];
secondCluster = [];
thirdCluster = [];
outliers = [];

%Append chosen DBScan generated cluster Labels to MasterDataTable
%hitDataTable.labels = DBHit(1).data5; 
%missDataTable.labels = DBMiss(1).data1;
allDataTable.labels = DBStruct(1).data29; %DBstruct doesn't separate by hits and misses

%% Create loop for creating 2 matrices containing all hits and all miss profiles

%Create 2 matrices containing all hits and all miss profiles
hitProfiles = cell2mat(T.hitProfiles);
missProfiles = cell2mat(T.missProfiles);

%hit
hitProfileLabels = table();
hitProfileLabels.profiles = hitProfiles;
hitProfileLabels.labels = allDataTable.labels(find(strcmp(masterDBDataTable.trialEnd,"hit") & masterDBDataTable.optoPower~=0)); %the name of the ____.labels file 
% changes depending on the type of labels (hits vs misses separated, or all
% together)

%miss
missProfileLabels = table();
missProfileLabels.profiles = missProfiles;
missProfileLabels.labels = allDataTable.labels(find(strcmp(masterDBDataTable.trialEnd,"miss") & masterDBDataTable.optoPower~=0)); %the name of the ____.labels file 
% changes depending on the type of labels (hits vs misses separated, or all
% together)

%combined hits and misses
allProfileLabels = table();
allProfileLabels.profiles = [hitProfileLabels.profiles; -missProfileLabels.profiles];
allProfileLabels.labels =  [hitProfileLabels.labels; missProfileLabels.labels];

%% Sort Profiles by cluster labels
firstCluster = allProfileLabels.profiles(find(allProfileLabels.labels==1),1:end);
secondCluster = allProfileLabels.profiles(find(allProfileLabels.labels==2),1:end);
thirdCluster = allProfileLabels.profiles(find(allProfileLabels.labels==3),1:end);
outliers = allProfileLabels.profiles(find(allProfileLabels.labels==-1),1:end);


%% Plots
  
figure;
hold on
plot(mean(firstCluster))
plot(mean(allProfileLabels.profiles))
plot(mean(secondCluster))
plot(mean(outliers))
plot(mean(thirdCluster))
legend('First Cluster', 'All Profiles', 'Second Cluster', 'outliers', 'Third Cluster')
title('Miss and hits non-separated Euclidean DBSCAN 0.24 Eps 50 minpts')
   
%% Other Stuff


%loop through all sessions
sessionCounter = 1;
HitCounter = 1;
MissCounter = 1;
allStimHitLabeled = table();
allStimMissLabeled = table();

hitPros = [];
missPros = [];

for nSession = 1:size(T,1)

    %Init variabels
    hitTrials = [];
    missTrials = [];
    Trials_opToPower = [];

    %create variables for hit profiles and reaction times from the master
    %table
    hitPros(HitCounter:HitCounter+size(cell2mat(T.hitProfiles(nSession)),1)-1, ...
        1:length(cell2mat(T.hitProfiles(nSession)))) = cell2mat(T.hitProfiles(nSession));
    missPros(MissCounter:MissCounter+size(cell2mat(T.missProfiles(nSession)),1)-1, ...
        1:length(cell2mat(T.missProfiles(nSession)))) = cell2mat(T.missProfiles(nSession));
    hitTrials = cell2mat(T.hit(nSession))';
    missTrials = cell2mat(T.miss(nSession))';
    Trials_opToPower = cell2mat(T.optoPowerMW(nSession))';
    Session_Clusters = DBStruct(1).data66(sessionCounter:sessionCounter+size(hitTrials,1)-1); % you minus one because you include counter as first number when indexing
    stimHits_Clusters(HitCounter:HitCounter+size(cell2mat(T.hitProfiles(nSession)), ...
        1)-1) = Session_Clusters(find(hitTrials==1 & Trials_opToPower~=0));% you minus one because you include counter as first number when indexing
    stimMiss_Clusters(MissCounter:MissCounter+size(cell2mat(T.missProfiles(nSession)), ...
        1)-1) = Session_Clusters(find(missTrials==1 & Trials_opToPower~=0));

    sessionCounter = sessionCounter + size(hitTrials,1);
    HitCounter = HitCounter + size(cell2mat(T.hitProfiles(nSession)),1);
    MissCounter = MissCounter + size(cell2mat(T.missProfiles(nSession)),1);

end

allStimHitLabeled.clusterLabels = stimHits_Clusters';
allStimHitLabeled.Profiles = hitPros;
allStimMissLabeled.clusterLabels = stimMiss_Clusters';
allStimMissLabeled.Profiles = -missPros; %make negative because we will combine the two tables together
comboTable = [allStimHitLabeled;allStimMissLabeled];

firstCluster = comboTable.Profiles(find(comboTable.clusterLabels==1),:);
%secondCluster = comboTable.Profiles(find(comboTable.clusterLabels==2),:);
%thirdCluster = comboTable.Profiles(find(comboTable.clusterLabels==3),:);
outliers = comboTable.Profiles(find(comboTable.clusterLabels==-1),:);

figure;
hold on
plot(mean(comboTable.Profiles))
plot(mean(firstCluster))
%plot(mean(secondCluster))
%plot(mean(thirdCluster))
plot(mean(outliers))
legend('all', 'First Cluster', 'Second', 'Outliers')




%ProfileswithClusters(:,1) = hitPros; %create a table or struct, 1 side will have the cluster label first, then the next set would have the profiles


%firstCluster_hits = [firstCluster_hits; DBscan_Trials(1:length(find(Session_Clusters==1 & hitTrials==1 & Trials_opToPower~=0)),1:800)];



%creates range for each tertile
%firstIdx = (RTs >= min(prctile(RTs,[0 33.33])) & RTs <= max(prctile(RTs,[0 33.33])));
%secondIdx = (RTs > min(prctile(RTs,[33.33 66.67])) & RTs <= max(prctile(RTs,[33.33 66.67])));
%thirdIdx = (RTs > min(prctile(RTs,[66.67 100])) & RTs <= max(prctile(RTs,[66.67 100])));

%Grabs all trials in current session and appends them to the
%appropriate matrix
%find(DBStruct(1).data69(ans))
firstCluster_miss
secondCluster = [secondCluster; hitPros(DBStruct(1).data29==2,:)];
%comboPros = [hitPros;-missPros];

A = hitPros(:,find(DBStruct(1).data69(DBStruct(1).data69==1)));

end

% Correct the values since we aren't including the misses
firstCluster = firstCluster/2 + 0.5;
secondCluster = secondCluster/2 + 0.5;


%% Filter SetUp

% Set Up Filter for Profiles
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

%% Bootstrap

% Compute 1st Tertile w/ SEM
bootfirst = bootstrp(1000,@mean,firstCluster);
firstPCs = prctile(bootfirst, [15.9, 50, 84.1]);              % +/- 1 SEM
firstPCMeans = mean(firstPCs, 2);
firstCIs = zeros(3, size(firstCluster, 2));
for c = 1:3
    firstCIs(c,:) = filtfilt(filterLP, firstPCs(c,:) - firstPCMeans(c)) + firstPCMeans(c);
end
firstx = 1:size(firstCIs, 2);
x2 = [firstx, fliplr(firstx)];
bins = size(firstCIs,2);

%2nd Tertile
bootsecond = bootstrp(1000,@mean,secondCluster);
secondPCs = prctile(bootsecond, [15.9, 50, 84.1]);              % +/- 1 SEM
secondPCMeans = mean(secondPCs, 2);
secondCIs = zeros(3, size(secondCluster, 2));
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

% Get Kernels for AOK
firstAOK_KDE = firstCluster(:,401:500)-0.5;
secondAOK_KDE = secondCluster(:,401:500)-0.5;
thirdAOK_KDE = thirdTertile(:,501:600)-0.5;
thirdAOK_KDE_two = thirdTertile(:,401:500)-0.5;

% Compute first AOK
bootfirst_AOK = bootstrp(100,@mean,firstAOK_KDE);
bootfirst_AOK = -(bootfirst_AOK); %makes values positive
firstAOK = sum(bootfirst_AOK,2);

%second AOK
bootsecond_AOK = bootstrp(100,@mean,secondAOK_KDE);
bootsecond_AOK = -(bootsecond_AOK);  %makes values positive
secondAOK = sum(bootsecond_AOK,2);

%third AOK
bootthird_AOK = bootstrp(100,@mean,thirdAOK_KDE);
bootthird_AOK = -(bootthird_AOK);  %makes values positive
thirdAOK = sum(bootthird_AOK,2);

%third AOK 2
bootthird_AOK_two = bootstrp(100,@mean,thirdAOK_KDE_two);
bootthird_AOK_two = -(bootthird_AOK_two);  %makes values positive
thirdAOK_two = sum(bootthird_AOK_two,2);


%% Plots

%create tiled layout for all plots
figure;
t= tiledlayout(3,2);
title(t,'Reaction Time Kernels and AOK')

% 1st Tertile
ax1 = nexttile;
hold on
plot(firstx, firstCIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
firstfillCI = [firstCIs(1, :), fliplr(firstCIs(3, :))]; % This sets up the fill for the errors
fill(x2, firstfillCI, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill
yline(0.5,'--k')
hold off
title('Kernel of First Tertile','FontSize',8);
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [0.47 0.52]);
ay.FontSize = 8;

% 2nd Tertile
ax2 = nexttile(3);
hold on
plot(secondx, secondCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
secondfillCI = [secondCIs(1, :), fliplr(secondCIs(3, :))]; % This sets up the fill for the errors
fill(x2, secondfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
yline(0.5,'--k')
hold off
title('Kernel of Second Tertile','FontSize',8);
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [0.47 0.52]);
ay.FontSize = 8;


% 3rd Tertile
ax3 = nexttile (5);
hold on
plot(thirdx, thirdCIs(2, :), 'g', 'LineWidth', 1.5); % This plots the mean of the bootstrap
thirdfillCI = [thirdCIs(1, :), fliplr(thirdCIs(3, :))]; % This sets up the fill for the errors
fill(x2, thirdfillCI, 'g', 'lineStyle', '-', 'edgeColor', 'g', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill
yline(0.5,'--k')
hold off
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
title('Kernel of Third Tertile','FontSize',8);
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [0.47 0.52]);
ay.FontSize = 8;


%Axes Label
xlabel([ax1,ax2,ax3],'Time Relative to Stimulus Onset (ms)','FontSize',8)
ylabel([ax1,ax2,ax3],'Normalized Power','FontSize',8)

%AOK

%1st
nexttile;
histogram(firstAOK,'Normalization','probability',FaceColor="b")
xline(0,'--k')
title('AoK of First Tertile','FontSize',8);
ay = gca;
ylim(ay, [0 0.4]);
ay.FontSize = 8;
ylabel('Probability','FontSize',8)
ax = gca;
xlim(ax, [-2, 2]);
ax.XTick = [-2:0.5:2];
ax.XTickLabel = {'-2', '', '-1', '', '0', '', '1', '', '2'};
ax.FontSize = 7;
ax.TickDir = "out";
xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)


%2nd
nexttile;
histogram(secondAOK,'Normalization','probability',FaceColor="r")
xline(0,'--k')
title('AoK of Second Tertile','FontSize',8);
ay = gca;
ylim(ay, [0 0.4]);
ay.FontSize = 8;
ylabel('Probability','FontSize',8)
ax = gca;
xlim(ax, [-2, 2]);
ax.XTick = [-2:0.5:2];
ax.XTickLabel = {'-2', '', '-1', '', '0', '', '1', '', '2'};
ax.FontSize = 7;
ax.TickDir = "out";
xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)

%3rd
nexttile;
histogram (thirdAOK,'Normalization','probability',FaceColor="g")
xline(0,'--k')
title('AoK of Third Tertile','FontSize',8);
ay = gca;
ylim(ay, [0 0.4]);
ay.FontSize = 8;
ylabel('Probability','FontSize',8)
ax = gca;
xlim(ax, [-2, 2]);
ax.XTick = [-2:0.5:2];
ax.XTickLabel = {'-2', '', '-1', '', '0', '', '1', '', '2'};
ax.FontSize = 7;
ax.TickDir = "out";
xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)

%3rd tertile 0-100ms vs 100-200ms

%tiled layout
figure;
t= tiledlayout(2,1);
title(t,'AOK of 3rd Tertile: 0-100ms vs 100-200ms')

%0 - 100 ms
nexttile;
histogram (thirdAOK_two,'Normalization','probability',FaceColor="#77AC30")
xline(0,':k')
title('AoK of Third Tertile from 0-100 ms','FontSize',8);
ay = gca;
ylim(ay, [0 0.4]);
ay.FontSize = 8;
ylabel('Probability','FontSize',8)
ax = gca;
xlim(ax, [-2, 2]);
ax.XTick = [-2:0.5:2];
ax.XTickLabel = {'-2', '', '-1', '', '0', '', '1', '', '2'};
ax.FontSize = 7;
ax.TickDir = "out";
xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)

%100-200 ms
nexttile;
histogram (thirdAOK,'Normalization','probability',FaceColor="g")
xline(0,':k')
title('AoK of Third Tertile from 100-200 ms','FontSize',8);
ay = gca;
ylim(ay, [0 0.4]);
ay.FontSize = 8;
ylabel('Probability','FontSize',8)
ax = gca;
xlim(ax, [-2, 2]);
ax.XTick = [-2:0.5:2];
ax.XTickLabel = {'-2', '', '-1', '', '0', '', '1', '', '2'};
ax.FontSize = 7;
ax.TickDir = "out";
xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)



end