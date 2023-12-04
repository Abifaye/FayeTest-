function [masterInertia] = getkMeanValidation(normData,masterDBDataTable,animalLabels)
%Summary inputs into normData, masterDBDataTable, and animalLabels
%variables from kMeans_coding.m to run a validation for indicated Ks of
%kMean analysis. Returns masterInertia containing the total intertia for
%each particular K and creates a graph of cluster number vs inertia to see
%which is the best K to use for kMeans analysis

%% Validation Runner

%Init Vars
compareClusters = input('Input K range for cluster validation: '); %indicate a range of all possible clusters that you want to run validation on (i.e. 2:6)
masterInertia = table(); %contains Intertia of each Kmean analysis
grouping = input('Run analysis by animals? [1=Yes/0=No]: '); %runs Kmeans by each animal

if grouping==0%Run Kmeans, all Data Combined
    for nKMeans = 1:length(compareClusters)%reiterate through all indicated Ks
        %Init Vars
        Clusters = []; %for each k
        Centroids = [];
        kIntertia = [];
        tempMat = [];%for allocating distances for each cluster
        [Clusters Centroids] = kmeans(normData,compareClusters(nKMeans));
        %distance calculation for each cluster
        for nCluster = 1:compareClusters(nKMeans) %reiterate through each cluster
            tempMat = pdist2(normData(Clusters==nCluster,1:end),Centroids(nCluster,1:end)); %computes distance of each point from centroid for each cluster
            kIntertia = [kIntertia; tempMat];
        end
        masterInertia.(string(compareClusters(nKMeans))) = sum(kIntertia);%calculates inertia for Kmean with certain number of clusters
    end
elseif grouping==1%Run Kmeans, by animals
    animalDataSet = str2double([masterDBDataTable.animal normData]); %combine animal number and data in one matrix
    for nKMeans = 1:length(compareClusters)%reiterate through all indicated Ks
        %Init vars
        Clusters = []; %for each animals
        Centroids = [];
        masterClusters = []; %combines all animals
        masterCentroids = [];
        kIntertia = [];

        for nAnimal = 1:length(animalLabels) %reiterate through each animals
            [Clusters,Centroids] = kmeans(animalDataSet(animalDataSet(:,1)==str2double(animalLabels(nAnimal)),2:6),compareClusters(nKMeans)); %get cluster labels and centroids for each animal
            %distance calculation for each cluster
            tempMat = [];%for allocating distances for each cluster
            animalIntertia = [];%for allocating total inertia for each animal
            for nCluster = 1:compareClusters(nKMeans) %reiterate through each cluster
                tempMat = pdist2(normData(Clusters==nCluster,1:end),Centroids(nCluster,1:end)); %computes distance of each point from centroid for each cluster
                animalIntertia = [animalIntertia; tempMat];
            end
            %put data for each animal in master matrix
            kIntertia = [kIntertia; sum(animalIntertia)];%calculates inertia for Kmean with certain number of clusters
            masterClusters = [masterClusters; Clusters];
            masterCentroids = [masterCentroids;Centroids];
        end
        masterInertia.(string(compareClusters(nKMeans)))= sum(animalIntertia);
    end
end

%% Graph
x = categorical(str2double(masterInertia.Properties.VariableNames));
figure;
hold on
plot(x,table2array(masterInertia))
scatter(x,table2array(masterInertia))
xlabel('# of Clusters')
ylabel('Inertia')

end