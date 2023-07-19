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

%figure data 5 clustering
clr = hsv(DBStruct(4).data5); 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data5,clr)
title('Data 5')
xlabel('Rolling Hit Rate')
ylabel('Rolling Rewards')

%figure data 10 clustering
clr = hsv(DBStruct(4).data10); 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data10,clr)
title('Data 10')
xlabel('Rolling Hit Rate')
ylabel('Rolling Rewards')

%figure data 15 clustering
clr = ['r','b']; 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data15,clr)
title('Data 15')
xlabel('Rolling Hit Rate')
ylabel('Rolling Rewards')

%figure data 20 clustering
clr = ['r','b','g','k']; 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data20,clr)
title('Data 20')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')

%figure data 25 clustering
clr = ['r','b','g']; 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data25,clr)
title('Data 25')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')

%figure data 57 clustering
clr = ['r','g','b']; 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data57,clr)
title('Data 57')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')

%figure data 63 clustering
clr = ['r','g']; 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data63,clr)
title('Data 63')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')

%figure data 63 clustering
clr = ['r','g']; 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data63,clr)
title('Data 63')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')

%figure data 64 clustering
clr = ['r','g','b']; 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data64,clr)
title('Data 64')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')

%figure data 68 clustering
clr = ['r','b']; 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data68,clr)
title('Data 68')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')


%figure data 40 clustering
clr = ['r','b','g','k','y','c','m']; 
figure;
gscatter(masterTable.rollinghitrate,masterTable.rollingrewards,DBStruct(1).data40,clr)
title('Data 40')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')

%


%% Total Number of Trials
for nData = 1:size(T,1);
    SessionSize(nData) = size(T.optoPowerMW{nData,1},2);
end

totalTrials = sum(SessionSize);
