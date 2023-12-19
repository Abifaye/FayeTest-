%% Kmeans_coding

%% Kmeans
%load master data files
load masterTable_allLuminanceCleaned.mat
load(uigetfile('','Select Data table file to use'))
load(uigetfile('','Select normData file to use'))

normData = table2array(normData); %turn normData into array because kMeans can't have tables

%get animal labels
%init vars
animalLabels = [];
animalLabels = masterDBDataTable.animal(1); %get animal number of first animal from master table and put into matrix
currentAnimal = masterDBDataTable.animal(1);%initializes first animal as the current animal for comparing animal labels
for nSession = 1:size(masterDBDataTable,1) %loop through each trial
    if strcmp(currentAnimal,masterDBDataTable.animal(nSession))==0 %compare the animal label for the trial and the label for the current animal. If they are different
        animalLabels = [animalLabels masterDBDataTable.animal(nSession)]; %add the new animal label to animalLabels
        currentAnimal = masterDBDataTable.animal(nSession); %set the animal label for the current trial as the new current animal to compare against
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
%hold on
plot(mean(firstProfiles),'r')
ylim([-0.05 0.05])
title('First Cluster')
figure;
plot(mean(secondProfiles),'y')
ylim([-0.05 0.05])
title('Second Cluster')
figure;
plot(mean(thirdProfiles),'g')
ylim([-0.05 0.05])
title('Third Cluster')
figure;
plot(mean(fourthProfiles),'b')
ylim([-0.05 0.05])
title('Fourth Cluster')
figure;
plot(mean(fifthProfiles),'m')
ylim([-0.05 0.05])
title('Fifth Cluster')
%plot(mean(sixthProfiles))
%plot(mean(seventhProfiles))
%legend('First Cluster')


%% Parameters

%bar plots
getKmeanBarPlots(Clusters,masterDBDataTable)

%scatter plots
getKmeanScatterPlots(masterClusters)

%% Extra Analysis
for nVar = 5:10
    figure;
    boxplot(masterDBDataTable.(nVar),masterClusters)
    ylabel(masterDBDataTable.Properties.VariableNames(nVar))
    xlabel('Cluster')
end

%% Add prestim time to DBDataTable
load masterTable_allLuminanceCleaned.mat
tempMat = [];
for nSession = 1:size(T,1)
    tempMat = [tempMat; T.preStimMS{nSession}'];
end
masterDBDataTable.preStimTime = tempMat;

%save("masterDBDataTable_hitsRTs.mat","masterDBDataTable")

%% Cluster Trial Count
clusterCount = [];
for nCluster = 1:max(masterClusters)
clusterCount(nCluster) = numel(masterClusters(masterClusters==nCluster));
end

bar(clusterCount)
xlabel('Cluster')
ylabel('Trial Count')


%% Summing Power
optoPower = [T.(56){1:end}];
powerSum = [];
for nCluster = 1:max(masterClusters)
powerSum(nCluster) = sum(optoPower(masterClusters==nCluster))/numel(optoPower(masterClusters==nCluster));
end

figure;
bar(powerSum)
xlabel('Cluster')
ylabel('Power per Trial')

profileSum(1) = mean(sum(firstProfiles,2))/length(firstProfiles);
profileSum(2) = mean(sum(secondProfiles,2))/length(secondProfiles);
profileSum(3) = mean(sum(thirdProfiles,2))/length(thirdProfiles);
profileSum(4) = mean(sum(fourthProfiles,2))/length(fourthProfiles);
profileSum(5) = mean(sum(fifthProfiles,2))/length(fifthProfiles);

figure;
bar(profileSum)
xlabel('Cluster')
ylabel('Sum of Power/trial')






