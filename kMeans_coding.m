%% Kmeans_coding

%% Kmeans
%load master data files
load masterTable_allLuminanceCleaned.mat
load masterDBDataTable.mat
load normData.mat

%Run Kmeans
Clusters = kmeans(normData,3);

%% figures
%Create 2 matrices containing all hits and all miss profiles
hitProfiles = cell2mat(T.hitProfiles);
missProfiles = cell2mat(T.missProfiles);

%Take only miss+hits trials with optopower
optoHitClusters = Clusters(strcmp(masterDBDataTable.trialEnd,"hit") & masterDBDataTable.optoPower~=0);
optoMissClusters = Clusters(strcmp(masterDBDataTable.trialEnd,"miss") & masterDBDataTable.optoPower~=0);

firstProfiles = [hitProfiles(optoHitClusters==1,1:end); -missProfiles(optoMissClusters==1,1:end)];
secondProfiles = [hitProfiles(optoHitClusters==2,1:end); -missProfiles(optoMissClusters==2,1:end)];
thirdProfiles = [hitProfiles(optoHitClusters==3,1:end); -missProfiles(optoMissClusters==3,1:end)];
fourthProfiles = [hitProfiles(optoHitClusters==4,1:end); -missProfiles(optoMissClusters==4,1:end)];

figure;
hold on
plot(mean(firstProfiles))
plot(mean(secondProfiles))
legend('First Cluster', 'Second Cluster')
title('kMeans 2 Cluster maholanobis')
plot(mean(thirdProfiles))
plot(mean(fourthProfiles))
legend('First Cluster', 'Second Cluster', 'Third Cluster', 'Fourth Cluster')
title('kMeans 4 Cluster')

%% Parameters

%bar plots
getKmeanBarPlots(Clusters)

%scatter plots
getKmeanScatterPlots(Clusters)



%% Kmeans and T-SNE combined
%load masterDBDataTable.mat
%load normData_hit.mat
%load normData_miss.mat

%Take only miss+hits trials with optopower from master tables

%twoclusters_hit = kmeans(normData_hit,3);
%twoclusters_miss = kmeans(normData_miss,3);

%Graphs
%figure;
%gscatter(tSNE_hit(:,1),tSNE_hit(:,2),twoclusters_hit)

%figure;
%gscatter(tSNE_miss(:,1),tSNE_miss(:,2),twoclusters_miss)


