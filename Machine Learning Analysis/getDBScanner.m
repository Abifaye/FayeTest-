function [DBStructData] = getDBScanner
%inputs into normData of either hits, misses, or all trials. normData contains the normalized values of trials
%for each variable of interest. DBScanner then conducts multiple dbscans for all selected
%range of eps and minpts. It returns a struct containing the dbscan
%data, and the corresponding minpts and eps used.

tic;
%% Variable Initialization
%choose whether to append or create a new struct for data obtained from the
%DBScan
append_struct = input(strcat('Append or Create New DBStruct? [Append=1/Create=2]:',32)); %32 codes for space

%Set up the Struct to put in the data
if append_struct == 2
    %initialize the contents of the struct under DBStructData
    DBStructData = struct([]);
    DBStructData(1).labels = 'Data Cluster Labels';
    DBStructData(2).labels = 'Minpts';
    DBStructData(3).labels = 'Eps';
    DBStructData(4).labels = 'Number of Clusters';
    DBStructData(5).labels = 'Number of Outliers';
    DBStructData(6).labels = 'Points per Cluster';
    DBStructData(7).labels = 'Highest Cluster';
    DBStructData(8).labels = 'Cluster Data % of Highest Cluster';
    DBStructData(9).labels = 'All Data % of Highest Cluster';
    counter = 1;
elseif append_struct == 1
    %choose which struct to append to
    structFile = load(uigetfile('*.mat','Select Struct to Append to')); %loads struct, but nested within 1x1 struct
    extractedFile = structFile.(string(fieldnames(structFile))); %reassigns structFile as extracted struct
    counter = length(fieldnames(extractedFile)); %tells where new set of data will go in the struct
    DBStructData = struct();

end

%Select which normalized data to use
normalizedData = struct2cell(load(uigetfile('','Select Normalized Data File')));
normalizedData = table2array(normalizedData{1});

%Choose Parameters
chooseEps = input(strcat('Choose file for epsilon range? [Y=1/N=0]:',32)); %if there is file of calculated eps range or make up own range
if chooseEps == 1
    epsRange = load(uigetfile('','Select Epsilon Range File'));
elseif chooseEps == 0
    epsRange = input(strcat('Select a Range for Epsilon:',32));
end
minptsRange = input(strcat('Select a Range for Minpts:',32)); %minpts selection

%% DBSCan Loop
%loop through each eps and minpts
for eps = 1:length(epsRange)
    for minpts = 1:length(minptsRange)
        %DBScan
        DBStructData(1).(strcat('data',num2str(counter))) = dbscan(normalizedData,epsRange(eps),minptsRange(minpts), "Distance","euclidean");

        % Put the corresponding minpts and eps in the struct then compute the number of clusters and outliers
        DBStructData(2).(strcat('data',num2str(counter))) = minptsRange(minpts);
        DBStructData(3).(strcat('data',num2str(counter))) = epsRange(eps);
        DBStructData(4).(strcat('data',num2str(counter))) = max(DBStructData(1).(strcat('data',num2str(counter))));
        DBStructData(5).(strcat('data',num2str(counter))) = sum(DBStructData(1).(strcat('data',num2str(counter))) == -1);

        %Init matrix for computing # of pts per cluster
        clusterMat = [];
        %go through each cluster
        for nCluster = 1:DBStructData(4).(strcat('data',num2str(counter)))
            clusterMat(nCluster) = sum(DBStructData(1).(strcat('data',num2str(counter))) == nCluster);
        end

        DBStructData(6).(strcat('data',num2str(counter))) =  clusterMat;

        %assign appropriate values for each labels
        DBStructData(7).(strcat('data',num2str(counter))) = find(DBStructData(6).(strcat('data',num2str(counter))) == ...
            max(DBStructData(6).(strcat('data',num2str(counter))))); %cluster with highest num of pts
        DBStructData(8).(strcat('data',num2str(counter))) = max(DBStructData(6).(strcat('data',num2str(counter))))/...
            sum(DBStructData(6).(strcat('data', num2str(counter))))*100; %percent of data belonging to highest cluster, not including outliers
        DBStructData(9).(strcat('data',num2str(counter))) = max(DBStructData(6).(strcat('data',num2str(counter))))/...
            (sum(DBStructData(6).(strcat('data', num2str(counter))))+DBStructData(5).(strcat('data',num2str(counter))))*100; %percent of data belonging to highest cluster,
        % including outliers
        counter = counter+1; %extend counter
    end
end

if append_struct == 1
    fields = fieldnames(DBStructData);
    for nField = 1:length(fields)
        for nElement = 1:length(DBStructData)
    extractedFile(nElement).(fields{nField}) = [DBStructData(nElement).(fields{nField})];
        end
    end
    DBStructData = extractedFile;
end

toc;

end

