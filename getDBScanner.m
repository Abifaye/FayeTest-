function [DBStruct] = getDBScanner(normData)
%inputs into normData which contains the normalized values of all trials
%for each variable of interest. It then conducts multiple dbscans for all selected
%range of eps and minpts. It returns holder, a struct containing the dbscan
%data, and the corresponding minpts and eps used. THIS FUNCTION CAN TAKE A
%LONG TIME TO RUN IF FED WITH LONG RANGES OF EPS AND/OR MINPTS. PLEASE USE A HIGH POWER COMPUTER IF POSSIBLE.

%selection dialogue for choosing range of minpts and eps to conduct dbscan
%with
epsRange = input(strcat('Select a Range for Epsilon:',32));
minptsRange = input(strcat('Select a Range for Minpts:',32)); %code 32 = space

%initialize empty struct, then create labels for where the data, minpts,
%and eps will 
% be located
%DBStruct = struct([]);
%DBStruct(1).labels = 'Data Cluster Labels';
%DBStruct(2).labels = 'Minpts';
%DBStruct(3).labels = 'Eps';
%DBStruct(4).labels = 'Number of Clusters';
%DBStruct(5).labels = 'Number of Outliers';
%DBStruct(6).labels = 'Points per Cluster';
%DBStruct(7).labels = 'Highest Cluster';
%DBStruct(8).labels = 'Cluster Data % of Highest Cluster';
%DBStruct(9).labels = 'All Data % of Highest Cluster';


%initialize counter for creating new field for every dbscan data created
counter = 53;

%loop through each eps and minpts and place the dbscan data, corresponding
%eps + minpts in the right label place
for eps = 1:length(epsRange)
    for minpts = 1:length(minptsRange)

        %conduct dbscan for corresponding eps and minpts and put it in the struct.
        % Put the corresponding minpts and eps in the struct then compute the number of clusters and outliers
        DBStruct(1).(strcat('data',num2str(counter))) = dbscan(normData,epsRange(eps),minptsRange(minpts));
        DBStruct(2).(strcat('data',num2str(counter))) = minptsRange(minpts);
        DBStruct(3).(strcat('data',num2str(counter))) = epsRange(eps);
        DBStruct(4).(strcat('data',num2str(counter))) = max(DBStruct(1).(strcat('data',num2str(counter))));
        DBStruct(5).(strcat('data',num2str(counter))) = sum(DBStruct(1).(strcat('data',num2str(counter))) == -1);

        %Init matrix for computing # of pts per cluster
        clusterMat = [];

        %
        for nCluster = 1:DBStruct(4).(strcat('data',num2str(counter)))
            clusterMat(nCluster) = sum(DBStruct(1).(strcat('data',num2str(counter))) == nCluster);
        end

        %
        DBStruct(6).(strcat('data',num2str(counter))) =  clusterMat;
        DBStruct(7).(strcat('data',num2str(counter))) = find(DBStruct(6).(strcat('data',num2str(counter))) == ...
            max(DBStruct(6).(strcat('data',num2str(counter)))));
        DBStruct(8).(strcat('data',num2str(counter))) = max(DBStruct(6).(strcat('data',num2str(counter))))/...
            sum(DBStruct(6).(strcat('data', num2str(counter))))*100;
        DBStruct(9).(strcat('data',num2str(counter))) = max(DBStruct(6).(strcat('data',num2str(counter))))/...
            (sum(DBStruct(6).(strcat('data', num2str(counter))))+DBStruct(5).(strcat('data',num2str(counter))))*100;
        counter = counter+1; %extend counter
    end
end


end
