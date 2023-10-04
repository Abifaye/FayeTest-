function [DBStructData] = getDBScanner
%inputs into normData of either hits, misses, or all trials. normData contains the normalized values of trials
%for each variable of interest. DBScanner then conducts multiple dbscans for all selected
%range of eps and minpts. It returns a struct containing the dbscan
%data, and the corresponding minpts and eps used. 

tic;

%Select which normalized data to use
normalizedData = cell2mat(struct2cell(load(uigetfile('','Select Normalized Data File'))));


%Prompt for whether or not to append generated data to a pre-exisiting
%DBStruct
createStruct = input(strcat('Pre-existing DBStruct Available? [Y=1/N=0]:',32));
while createStruct > 1
    createStruct = input(strcat('You have made an invalid choice. Try again [Y=1/N=0]:',32));
    if createStruct == 1
        break
    elseif createStruct == 0
        break
    end
end

if createStruct == 0
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
elseif  createStruct == 1
    counter = input(strcat('How much data does DBStruct currently have?',32))+1;
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

toc;

%TO FIX THIS, RENAME THE NEW DBSTRUCT AS SOMETHING ELSE AND THEN APPEND TO
%THE ORIGINAL DBSTRUCT. THEN SAVE. CAN ALSO MAKE AN OPTION OF WHICH
%DBSTRUCT TO APPEND TO I.E. ONE FOR HITS ANOTHER FOR MISSES

%% For Saving
%save('DBStruct.mat',"DBStruct") 


end

