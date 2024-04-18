function [masterInertia] = getkMeanValidation(normData,masterDBDataTable,animalLabels)
%Summary inputs into normData, masterDBDataTable, and animalLabels
%variables from kMeans_coding.m to run a validation for indicated Ks of
%kMean analysis. Returns masterInertia containing the total intertia for
%each particular K and creates a graph of cluster number vs inertia to see
%which is the best K to use for kMeans analysis

%% Validation Runner

%Init Vars
compareClusters = input('Input K range for cluster validation: '); %indicate a range of all possible clusters that you want to run validation on (i.e. 2:6)
%contains Intertia of each Kmean analysis
masterInertia_Tog = table(); 
masterInertia_Animal = table();

grouping = input('Run analysis by animals or together? [1=Animals/0=together/2=Both]: '); %runs Kmeans by each animal

if grouping==0%Run Kmeans, all Data Combined
    for nKMeans = 1:length(compareClusters)%reiterate through all indicated Ks
        %Init Vars
        Clusters = []; %for each k
        Centroids = [];
        kInertia = [];
        tempMat = [];%for allocating distances for each cluster
        [Clusters Centroids] = kmeans(normData,compareClusters(nKMeans));
        %distance calculation for each cluster
        for nCluster = 1:compareClusters(nKMeans) %reiterate through each cluster
            tempMat = pdist2(normData(Clusters==nCluster,1:end),Centroids(nCluster,1:end)); %computes distance of each point from centroid for each cluster
            kInertia = [kInertia; tempMat];
        end
        masterInertia.(string(compareClusters(nKMeans))) = sum(kInertia);%calculates inertia for Kmean with certain number of clusters
    end
elseif grouping==1%Run Kmeans, by animals
    animalDataSet = str2double([masterDBDataTable.animal normData]); %combine animal number and data in one matrix
    for nKMeans = 1:length(compareClusters)%reiterate through all indicated Ks
        %Init vars
        Clusters = []; %for each animals
        Centroids = [];
        masterClusters = []; %combines all animals
        masterCentroids = [];
        kInertia = [];

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
            kInertia = [kInertia; sum(animalIntertia)];%calculates inertia for Kmean with certain number of clusters
            masterClusters = [masterClusters; Clusters];
            masterCentroids = [masterCentroids;Centroids];
        end
        masterInertia.(string(compareClusters(nKMeans)))= sum(animalIntertia);
    end
elseif grouping==2
    %together
    for nKMeans = 1:length(compareClusters)%reiterate through all indicated Ks
        %Init Vars
        Clusters = []; %for each k
        Centroids = [];
        kInertia = [];
        tempMat = [];%for allocating distances for each cluster
        [Clusters Centroids] = kmeans(normData,compareClusters(nKMeans));
        %distance calculation for each cluster
        for nCluster = 1:compareClusters(nKMeans) %reiterate through each cluster
            tempMat = pdist2(normData(Clusters==nCluster,1:end),Centroids(nCluster,1:end)); %computes distance of each point from centroid for each cluster
            kInertia = [kInertia; tempMat];
        end
        masterInertia_Tog.(string(compareClusters(nKMeans))) = sum(kInertia);%calculates inertia for Kmean with certain number of clusters
    end
    %by animal
    animalDataSet = str2double([masterDBDataTable.animal normData]); %combine animal number and data in one matrix
    for nKMeans = 1:length(compareClusters)%reiterate through all indicated Ks
        %Init vars
        Clusters = []; %for each animals
        Centroids = [];
        masterClusters = []; %combines all animals
        masterCentroids = [];
        kInertia = [];

        for nAnimal = 1:length(animalLabels) %reiterate through each animals
            [Clusters,Centroids] = kmeans(animalDataSet(animalDataSet(:,1)==str2double(animalLabels(nAnimal)),2:5),compareClusters(nKMeans)); %get cluster labels and centroids for each animal
            %distance calculation for each cluster
            tempMat = [];%for allocating distances for each cluster
            animalIntertia = [];%for allocating total inertia for each animal
            for nCluster = 1:compareClusters(nKMeans) %reiterate through each cluster
                tempMat = pdist2(normData(Clusters==nCluster,1:end),Centroids(nCluster,1:end)); %computes distance of each point from centroid for each cluster
                animalIntertia = [animalIntertia; tempMat];
            end
            %put data for each animal in master matrix
            kInertia = [kInertia; sum(animalIntertia)];%calculates inertia for Kmean with certain number of clusters
            masterClusters = [masterClusters; Clusters];
            masterCentroids = [masterCentroids;Centroids];
        end
        masterInertia_Animal.(string(compareClusters(nKMeans)))= sum(animalIntertia);
    end
    %graphs
    figure;
    t= tiledlayout(2,1);
    title(t,'KMeans Model Validation',"FontSize",15)
    % Together Graph
    x1 = categorical(str2double(masterInertia_Tog.Properties.VariableNames));
    nexttile;
    hold on
    plot(x1,table2array(masterInertia_Tog))
    scatter(x1,table2array(masterInertia_Tog),'filled')
    xlabel('# of Clusters')
    ylabel('Inertia')
    title('Combined Analysis')
    set(gca,"FontSize",15)
    %animal graph
    x2 = categorical(str2double(masterInertia_Animal.Properties.VariableNames));
    nexttile;
    hold on
    plot(x2,table2array(masterInertia_Animal))
    scatter(x2,table2array(masterInertia_Animal),'filled')
    xlabel('# of Clusters')
    ylabel('Inertia')
    title('Animal Separated Analysis')
    set(gca,"FontSize",15)
end

%% Graph
x = categorical(str2double(masterInertia.Properties.VariableNames));
figure;
hold on
plot(x,table2array(masterInertia))
scatter(x,table2array(masterInertia),'filled')
xlabel('# of Clusters')
ylabel('Inertia')

end