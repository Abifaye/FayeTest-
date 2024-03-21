%% Kmeans_coding
%code for analyzing data using Kmeans method

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
k = input('Indicate number of clusters to find: ');
if grouping==0 %Run Kmeans, all Data Combined
    masterClusters = kmeans(normData,k); %runs kmeans
elseif grouping==1 %Run Kmeans, by animals
    animalDataSet = str2double([masterDBDataTable.animal normData]); %combine animal number and data in one matrix
    Clusters = []; %for each animals
    masterClusters = []; %combines all animals

    for nAnimal = 1:length(animalLabels) %reiterate through each animals
        Clusters = kmeans(animalDataSet(animalDataSet(:,1)==str2double(animalLabels(nAnimal)),2:6),k); %get cluster labels for each animal
        %distance calculation for each cluster
        %put data for each animal in master matrix]
        masterClusters = [masterClusters; Clusters];
    end
end
%save('[insertfilename].mat',"masterClusters")
%% Figures 
gen_figs= input('Generate Figures? [Yes=1/0=No]: '); %decide whether to generate any graphs
if gen_figs==1
    %% kernels of clusters
    gen_kernels = input('Generate kernels for each cluster? [Yes=1/0=No]: '); %decide whether to generate kernel graphs for clusters
    if gen_kernels==1
        getKmeanKernels_Boxplots
    end

    %% bar plots
    gen_barplots = input('Generate bar plots of variables with all clusters? [Yes=1/0=No]: '); %decide whether to generate bar graphs to compare each cluster on any variables
    if gen_barplots==1
        getKmeanBarPlots(Clusters,masterDBDataTable)
    end

    %% scatterplots
    gen_scatterplots = input('Generate scatterplots between 2 variables using cluster labels? [Yes=1/0=No]: '); %decide whether to generate scatterplots of 2 variables using the clusters
    %from kmeans to colour code each datapoint
    if gen_scatterplots==1
        getKmeanScatterPlots(masterClusters)
    end

    %% Box plots
    gen_boxplots = input('Generate boxplots of each variable with all clusters? [Yes=1/0=No]: '); %decide whether to generate boxplots to compare each cluster on all variables
    if gen_boxplots==1
        for nVar = 5:10
            figure;
            boxplot(masterDBDataTable.(nVar),masterClusters,'Colors','rkgbm')
            ylabel(masterDBDataTable.Properties.VariableNames(nVar))
            xlabel('Cluster')
            title(strcat(masterDBDataTable.Properties.VariableNames(nVar),' by Clusters'))
            set(gca,"FontSize",16)
        end

    end

end


%% Add prestim time to DBDataTable
%load masterTable_allLuminanceCleaned.mat
%tempMat = [];
%for nSession = 1:size(T,1)
%tempMat = [tempMat; T.preStimMS{nSession}'];
%end
%masterDBDataTable.preStimTime = tempMat;

%save("masterDBDataTable_hitsRTs.mat","masterDBDataTable")
gen_extra= input('Generate Extra Analyses? [Yes=1/0=No]: '); %decide whether to generate extra analyses
if gen_extra==1

    %% Cluster Trial Count
    clusterCount = [];
    for nCluster = 1:max(masterClusters)
        clusterCount(nCluster) = numel(masterClusters(masterClusters==nCluster));
    end

    bar(clusterCount)
    xlabel('Cluster')
    ylabel('Trial Count')


    %% Summing Power

    profilePower = [];
    %get the power per trial for each cluster
    profilePower(1) = mean(sum(firstProfiles,2))/length(firstProfiles); %sum the power in each trial within the cluster (taken from firstProfiles matrix),
    % then get the average power of all trials within the cluster, then divide it by
    % the total number of trials within the cluster
    profilePower(2) = mean(sum(secondProfiles,2))/length(secondProfiles);
    profilePower(3) = mean(sum(thirdProfiles,2))/length(thirdProfiles);
    profilePower(4) = mean(sum(fourthProfiles,2))/length(fourthProfiles);
    profilePower(5) = mean(sum(fifthProfiles,2))/length(fifthProfiles);

    %find SEM for each profile
    semData = [];
    semData(1) = (std(sum(firstProfiles,2))/length(firstProfiles))/sqrt(length(firstProfiles));
    semData(2) = (std(sum(secondProfiles,2))/length(secondProfiles))/sqrt(length(secondProfiles));
    semData(3) = (std(sum(thirdProfiles,2))/length(thirdProfiles))/sqrt(length(thirdProfiles));
    semData(4) = (std(sum(fourthProfiles,2))/length(fourthProfiles))/sqrt(length(fourthProfiles));
    semData(5) = (std(sum(fifthProfiles,2))/length(fifthProfiles))/sqrt(length(fifthProfiles));

    figure;
    hold on
    bar(profilePower)
    for i = 1:length(semData)
        plot([i i], [profilePower(i)+semData(i) profilePower(i)-semData(i)], 'k');
        scatter([i i],[profilePower(i)+semData(i) profilePower(i)-semData(i)], "_",'k');
    end
    xlabel('Cluster')
    ylabel('Sum of Power per Trial (MW)')
    title('Sum of Power per Trial for Each Cluster with SEM')

end






