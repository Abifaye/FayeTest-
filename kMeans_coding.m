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
%% Starting from here I think we should make this into a function
%input whether or not to run validation for clusters
validationRunner = input('Validate clusters? [1=Yes/0=No]: ');

if validationRunner==1
    %Run Kmeans, all Data Combined
    %[Clusters Centroids] = kmeans(normData,2);

    %Run Kmeans, by animals
    compareClusters = input('Input K range for cluster validation: '); %indicate a range of all possible clusters that you want to run validation on (i.e. 2:6)
    for nKMeans = 1:length(compareClusters) %reiterate through all indicated Ks

        %Init vars
        Clusters = []; %for each animals
        Centroids = [];
        masterClusters = []; %combines all animals
        masterCentroids = [];
        masterInertia = [];
        animalDataSet = str2double([masterDBDataTable.animal normData]); %combine animal number and data in one matrix
       
        for nAnimal = 1:length(animalLabels) %reiterate through each animals
            [Clusters,Centroids] = kmeans(animalDataSet(animalDataSet==str2double(animalLabels(nAnimal)),2:6),compareClusters(nKMeans)); %get cluster labels and centroids for each animal
            %
            masterD = table(); %LEFT OFF HERE, YOU CAN'T SUM ALL IN A TABLE HAVE TO DO IT BY EACH VAR
            for nCluster = 1:compareClusters(nKMeans)
            masterD.(nCluster) = pdist2(Clusters(Cluster==nCluster),Centroids(Centroids==nCluster));
            end

            masterClusters = [masterClusters; Clusters]; %put data for each animal in master matrix
            masterCentroids = [masterCentroids;Centroids];
        end
    end

elseif validationRunner==0
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


