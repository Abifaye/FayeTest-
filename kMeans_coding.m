%% Kmeans_coding

%% Kmeans
%load master data files
load masterTable_allLuminanceCleaned.mat
load(uigetfile('','Select Data table file to use'))
load(uigetfile('','Select normData file to use'))

%get animal labels
animalLabels = [];
animalLabels = masterDBDataTable.animal(1);
currentAnimal = masterDBDataTable.animal(1);
for nTrial = 1:size(masterDBDataTable,1)
    if strcmp(currentAnimal,masterDBDataTable.animal(nTrial))==0
        animalLabels = [animalLabels masterDBDataTable.animal(nTrial)];
        currentAnimal = masterDBDataTable.animal(nTrial);
    end
end

grouping = input('Run analysis by animals? [1=Yes/0=No]: '); %runs Kmeans by each animal




    %Run Kmeans, all Data Combined
    %[Clusters Centroids] = kmeans(normData,2);

    %Run Kmeans, by animals
    Clusters = [];
    Centroids = [];
    masterClusters = [];
    masterCentroids = [];
    animalDataSet = str2double([masterDBDataTable.animal normData]);
    for nAnimal = 1:length(animalLabels)
        [Clusters,Centroids] = kmeans(animalDataSet(animalDataSet==str2double(animalLabels(nAnimal)),2:6),2);
        masterClusters = [masterClusters; Clusters];
        masterCentroids = [masterCentroids;Centroids];
    end




%% figures
%Create 2 matrices containing all hits and all miss profiles
hitProfiles = cell2mat(T.hitProfiles);
missProfiles = cell2mat(T.missProfiles);

%Take only miss+hits trials with optopower
optoHitClusters = masterClusters(strcmp(masterDBDataTable.trialEnd,"hit") & masterDBDataTable.optoPower~=0);
optoMissClusters = masterClusters(strcmp(masterDBDataTable.trialEnd,"miss") & masterDBDataTable.optoPower~=0);

firstProfiles = [hitProfiles(optoHitClusters==1,1:end); -missProfiles(optoMissClusters==1,1:end)];
secondProfiles = [hitProfiles(optoHitClusters==2,1:end); -missProfiles(optoMissClusters==2,1:end)];
thirdProfiles = [hitProfiles(optoHitClusters==3,1:end); -missProfiles(optoMissClusters==3,1:end)];
fourthProfiles = [hitProfiles(optoHitClusters==4,1:end); -missProfiles(optoMissClusters==4,1:end)];

figure;
hold on
plot(mean(firstProfiles))
plot(mean(secondProfiles))
%plot(mean(thirdProfiles))
%plot(mean(fourthProfiles))
legend('First Cluster', 'Second Cluster')
title('kMeans 2 Cluster')

%% Parameters

%bar plots
getKmeanBarPlots(Clusters,masterDBDataTable)

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


