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

%kmeans validation
validate = input('Run Validation for kMeans [Yes=1/0=No]: '); %decide whether to validate which K to use first
if validate==1
    [masterInertia] = getkMeanValidation(normData,masterDBDataTable,animalLabels);
end

%Kmeans analysis
grouping = input('Run kMean analysis by animals? [1=Yes/0=No]: '); %runs Kmeans by each animal
if grouping==0 %Run Kmeans, all Data Combined
    masterClusters = kmeans(normData,5); %runs kmeans
elseif grouping==1 %Run Kmeans, by animals
    animalDataSet = str2double([masterDBDataTable.animal normData]); %combine animal number and data in one matrix
    Clusters = []; %for each animals
    masterClusters = []; %combines all animals

    for nAnimal = 1:length(animalLabels) %reiterate through each animals
        Clusters = kmeans(animalDataSet(animalDataSet(:,1)==str2double(animalLabels(nAnimal)),2:6),5); %get cluster labels for each animal
        %distance calculation for each cluster
        %put data for each animal in master matrix]
        masterClusters = [masterClusters; Clusters];
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
fifthProfiles = [hitProfiles(optoHitClusters==5,1:end); -missProfiles(optoMissClusters==5,1:end)];
%sixthProfiles = [hitProfiles(optoHitClusters==6,1:end); -missProfiles(optoMissClusters==6,1:end)];
%seventhProfiles = [hitProfiles(optoHitClusters==7,1:end); -missProfiles(optoMissClusters==7,1:end)];

figure;
hold on
%plot(mean(firstProfiles),'r')
%plot(mean(secondProfiles),'y')
%plot(mean(thirdProfiles),'g')
%plot(mean(fourthProfiles),'b')
plot(mean(fifthProfiles),'m')
%plot(mean(sixthProfiles))
%plot(mean(seventhProfiles))
%legend('First Cluster')
ylim([-0.05 0.05])
title('fifth Cluster')

%% Parameters

%bar plots
getKmeanBarPlots(Clusters,masterDBDataTable)

%scatter plots
getKmeanScatterPlots(Clusters)






