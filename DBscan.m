%% Initializing Variables

%Go to folder with the master table
cd(uigetdir([],'Select Folder Containing Master Table'));

%% Initialize varibles
%get all functions that provides data
masterRollAve = getrollingAverage; %select rewards and allRTs
masterRollRates = getrollingrates; %select fa, miss, and hit

%concatinate table 
masterTable = horzcat(masterRollAve,masterRollRates);

%Normalize Data
normData = normalize(masterTable{:,:},1); %used z-score

%sample
sampleData = datasample(normData,10,'Replace',false);

save normData


%% Attempt to see which epsilon is best (not directly though), just using samples
holder = [];
for  nDraw = 1:100
sampleData = datasample(normData,10000,'Replace',false);
holder(nDraw) = clusterDBSCAN.estimateEpsilon(sampleData,2,10);
end
toc;
meanEps = mean(holder); 

%% DBscan
DBStruct = getDBScanner(normData);

delete normData.mat

save DBStruct


plot(DBStruct(1).data25,'Color','b')
%clusters = dbscan(normData,0.5,50); %using mean eps from sample


%% Extra
F = dbscan(normData,0.5,40); %20 minpts yielded 6 clusters, 30 minpts yielded 
% 5 clusters, 50 minpts yielded 3 clusters; moving 50 minpts with 0.5
% instead of 0.48 radius reduced it to 2 clusters, using 0.5 eps for 40
% trials also yield 2 clusters; I think 0.48 was better

%figure data 27 clustering
clr = hsv(DBStruct(4).data27); 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data27,clr)

%figure data 28 clustering
clr = hsv(DBStruct(4).data28); 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data28,clr)

%% Total Number of Trials
for nData = 1:size(T,1);
    SessionSize(nData) = size(T.optoPowerMW{nData,1},2);
end

totalTrials = sum(SessionSize);
