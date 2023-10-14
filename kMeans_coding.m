%% Kmeans_coding

%% Kmeans
%load master data files
load masterTable_allLuminanceCleaned.mat
load masterDBDataTable.mat
load normData.mat

%Run Kmeans
Clusters = kmeans(normData,2);

%% figures
%Create 2 matrices containing all hits and all miss profiles
hitProfiles = cell2mat(T.hitProfiles);
missProfiles = cell2mat(T.missProfiles);

%Take only miss+hits trials with optopower
optoHitClusters = Clusters(strcmp(masterDBDataTable.trialEnd,"hit") & masterDBDataTable.optoPower~=0);
optoMissClusters = Clusters(strcmp(masterDBDataTable.trialEnd,"miss") & masterDBDataTable.optoPower~=0);

firstProfiles = [hitProfiles(optoHitClusters==1,1:end); -missProfiles(optoMissClusters==1,1:end)];
secondProfiles = [hitProfiles(optoHitClusters==2,1:end); -missProfiles(optoMissClusters==2,1:end)];
thirdProfiles = [hitProfiles(optoHitClusters==3,1:end); -missProfiles(optoMissClusters==3,1:end)];
fourthProfiles = [hitProfiles(optoHitClusters==4,1:end); -missProfiles(optoMissClusters==4,1:end)];

figure;
hold on
plot(mean(firstProfiles))
plot(mean(secondProfiles))
plot(mean(thirdProfiles))
plot(mean(fourthProfiles))
legend('First Cluster', 'Second Cluster', 'Third Cluster', 'Fourth Cluster')
title('kMeans 4 Cluster')

%% Parameters
% ADD THE ERROR BARS

%mean rolling hit rate
mHR_first = mean(masterDBDataTable.rollinghitrate(Clusters==1));
mHR_second =  mean(masterDBDataTable.rollinghitrate(Clusters==2));

figure;
x = categorical(["First Cluster"; "Second Cluster"]);
y = [mHR_first mHR_second];
bar(x,y)
title('Mean Rolling Hit Rate')

%mean rolling Miss rate
mMR_first = mean(masterDBDataTable.rollingmissrate(Clusters==1));
mMR_second =  mean(masterDBDataTable.rollingmissrate(Clusters==2));

figure;
x = categorical(["First Cluster"; "Second Cluster"]);
y = [mMR_first mMR_second];
bar(x,y)
title('Mean Miss Rate')

%mean rolling farate
mFAR_first = mean(masterDBDataTable.rollingfarate(Clusters==1));
mFAR_second =  mean(masterDBDataTable.rollingfarate(Clusters==2));

figure;
x = categorical(["First Cluster"; "Second Cluster"]);
y = [mFAR_first mFAR_second];
bar(x,y)
title('Mean FA Rate')

%% additional plots
gscatter(masterDBDataTable.rollingfarate,masterDBDataTable.rollinghitrate,Clusters)

%
figure;
gscatter(tSNE_hit(:,1),tSNE_hit(:,2),Clusters(strcmp(masterDBDataTable.trialEnd,"hit")))
figure;
gscatter(tSNE_miss(:,1),tSNE_miss(:,2),Clusters)


%% Kmeans and T-SNE combined
%load masterDBDataTable.mat
%load normData_hit.mat
%load normData_miss.mat

%Take only miss+hits trials with optopower from master tables

%twoclusters_hit = kmeans(normData_hit,3);
%twoclusters_miss = kmeans(normData_miss,3);

%Graphs
%figure;
%gscatter(tSNE_hit(:,1),tSNE_hit(:,2),twoclusters_hit)

%figure;
%gscatter(tSNE_miss(:,1),tSNE_miss(:,2),twoclusters_miss)


