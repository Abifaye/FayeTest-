function [DBStructData] = getDBScanner
%inputs into normData of either hits, misses, or all trials. normData contains the normalized values of trials
%for each variable of interest. DBScanner then conducts multiple dbscans for all selected
%range of eps and minpts. It returns a struct containing the dbscan
%data, and the corresponding minpts and eps used. 

tic;
%% Variable Initialization
%choose whether to append or create a struct for data obtained from the
%DBScan
append_DBStruct = input(strcat('Append or Create New DBStruct? [Append=1/Create=2]',32)); 

%choose which struct to append/create based on data type from DBScan (hit
%only data, miss only data, or combined)
%selectStruct = listdlg('PromptString',{'Select which struct to use'},'ListString',{['DBStruct'],['DBHit'],['DBMiss']},'SelectionMode','single');
%table2struct(struct2table(struct(load(uigetfile('','Select Struct
%File'))))); %DOES NOT WORK PLEASE FIX
%Select which normalized data to use
normalizedData = cell2mat(struct2cell(load(uigetfile('','Select Normalized Data File'))));


%Set up the Struct to put in the data
if append_DBStruct == 2
    %initialize empty struct, then create labels for where the data, minpts,
    %and eps will be located
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

elseif  append_DBStruct == 1
    if selectStruct == 1 %combined
        load DBStruct.mat
        counter = length(fieldnames(DBStruct.mat));
    elseif  selectStruct == 2 %hit
        load DBHit.mat
        counter = length(fieldnames(DBHit.mat));
    elseif selectStruct == 3 %miss
        load DBMiss.mat
        counter = length(fieldnames(DBMiss.mat));
    end
end

%
chooseEps = input(strcat('Choose file for epsilon range? [Y=1/N=0]:',32));
if chooseEps == 1
    epsRange = load(uigetfile('','Select Epsilon Range File'));
elseif chooseEps == 0
    epsRange = input(strcat('Select a Range for Epsilon:',32));
end

%selection dialogue for choosing range of minpts to conduct dbscan
%with
minptsRange = input(strcat('Select a Range for Minpts:',32)); %code 32 = space

%% jdlaksjdlaskjdalsjd
%loop through each eps and minpts and place the dbscan data, corresponding
%eps + minpts in the right label place
for eps = 1:length(epsRange)
    for minpts = 1:length(minptsRange)
        %conduct dbscan for corresponding eps and minpts and put it in the struct.
        % Put the corresponding minpts and eps in the struct then compute the number of clusters and outliers
        DBStructData(1).(strcat('data',num2str(counter))) = dbscan(normalizedData,epsRange(eps),minptsRange(minpts), "Distance","euclidean");
        DBStructData(2).(strcat('data',num2str(counter))) = minptsRange(minpts);
        DBStructData(3).(strcat('data',num2str(counter))) = epsRange(eps);
        DBStructData(4).(strcat('data',num2str(counter))) = max(DBStructData(1).(strcat('data',num2str(counter))));
        DBStructData(5).(strcat('data',num2str(counter))) = sum(DBStructData(1).(strcat('data',num2str(counter))) == -1);
        %Init matrix for computing # of pts per cluster
        clusterMat = [];
        %go through each 
        for nCluster = 1:DBStructData(4).(strcat('data',num2str(counter)))
            clusterMat(nCluster) = sum(DBStructData(1).(strcat('data',num2str(counter))) == nCluster);
        end
        %assign appropriate values for each labels
        DBStructData(6).(strcat('data',num2str(counter))) =  clusterMat;
        DBStructData(7).(strcat('data',num2str(counter))) = find(DBStructData(6).(strcat('data',num2str(counter))) == ...
            max(DBStructData(6).(strcat('data',num2str(counter)))));
        DBStructData(8).(strcat('data',num2str(counter))) = max(DBStructData(6).(strcat('data',num2str(counter))))/...
            sum(DBStructData(6).(strcat('data', num2str(counter))))*100;
        DBStructData(9).(strcat('data',num2str(counter))) = max(DBStructData(6).(strcat('data',num2str(counter))))/...
            (sum(DBStructData(6).(strcat('data', num2str(counter))))+DBStructData(5).(strcat('data',num2str(counter))))*100;
        counter = counter+1; %extend counter
    end
end
%% 
if append_DBStruct == 1 %if append chosen
    if selectStruct == 1 %combined
        load DBStruct.mat
        names = [fieldnames(DBStruct); fieldnames(DBStructData)]; %obtain fieldnames of dbscan data and previously made struct
        DBStruct = cell2struct([struct2cell(DBStruct); struct2cell(DBStructData)], names, 1); %concatenate dbscan data and struct
    elseif  selectStruct == 2 %hit
        load DBHit.mat
        names = [fieldnames(DBHit); fieldnames(DBStructData)];
        DBHit = cell2struct([struct2cell(DBHit); struct2cell(DBStructData)], names, 1);
    elseif selectStruct == 3 %miss
        load DBMiss.mat
        names = [fieldnames(DBMiss); fieldnames(DBStructData)];
        DBMiss = cell2struct([struct2cell(DBMiss); struct2cell(DBStructData)], names, 1);
    end
else append_DBStruct == 2 %if create chosen
    %init DBScan data as appropriate struct
    if selectStruct == 1
        DBStruct = DBStructData;
    elseif  selectStruct == 2
        DBHit = DBStructData;
    elseif selectStruct == 3
        DBMiss = DBStructData;
    end
end

toc;


end

