function [masterInertia] = getkMeanValidation(normData)
%Summary
%% Validation Runner
%Init Vars
compareClusters = input('Input K range for cluster validation: '); %indicate a range of all possible clusters that you want to run validation on (i.e. 2:6)
masterInertia = table(); %contains Intertia of each Kmean analysis
grouping = input('Run analysis by animals? [1=Yes/0=No]: '); %runs Kmeans by each animal

if grouping==0%Run Kmeans, all Data Combined
    for nKMeans = 1:length(compareClusters)%reiterate through all indicated Ks
        %Init Vars
        Clusters = []; %for each animals
        Centroids = [];
        [Clusters Centroids] = kmeans(normData,compareClusters(nKMeans));
        %distance calculation for each cluster
        masterD = struct();%for allocating distances for each cluster
        for nCluster = 1:compareClusters(nKMeans) %reiterate through each cluster
            masterD.(strcat('Cluster',string(nCluster))) = pdist2(normData(Clusters==nCluster,1:end),Centroids(nCluster,1:end)); %computes distance of each point from centroid for each cluster
        end
        masterInertia.(string(compareClusters(nKMeans))) = sum(cell2mat(struct2cell(masterD)));%calculates inertia for Kmean with certain number of clusters
    end
elseif grouping==1%Run Kmeans, by animals
    for nKMeans = 1:length(compareClusters)%reiterate through all indicated Ks
        %Init vars
        Clusters = []; %for each animals
        Centroids = [];
        masterClusters = []; %combines all animals
        masterCentroids = [];
        animalIntertia = [];
        animalDataSet = str2double([masterDBDataTable.animal normData]); %combine animal number and data in one matrix

        for nAnimal = 1:length(animalLabels) %reiterate through each animals
            [Clusters,Centroids] = kmeans(animalDataSet(animalDataSet==str2double(animalLabels(nAnimal)),2:6),compareClusters(nKMeans)); %get cluster labels and centroids for each animal
            %distance calculation for each cluster
            masterD = struct();%for allocating distances for each cluster
            for nCluster = 1:compareClusters(nKMeans) %reiterate through each cluster
                masterD.(strcat('Cluster',string(nCluster))) = pdist2(normData(Clusters==nCluster,1:end),Centroids(nCluster,1:end)); %computes distance of each point from centroid for each cluster
            end
            %put data for each animal in master matrix
            animalIntertia = [animalIntertia; sum(table2array(masterD))];%calculates inertia for Kmean with certain number of clusters
            masterClusters = [masterClusters; Clusters];
            masterCentroids = [masterCentroids;Centroids];
        end
        masterInertia.(string(compareClusters(nKMeans)))= sum(animalIntertia);
    end
end
%% Graph

%A.Properties.VariableNames

end