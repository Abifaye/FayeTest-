%% Initializing Variables

%Go to folder with the master table
cd(uigetdir([],'Select Folder Containing Master Table'));

%get all functions that will give the variables struct
masterRollAve = getrollingAverage;
masterRollRates = getrollingrates;
%
masterTable = horzcat(masterRollAve,masterRollRates);

%Normalize Variables
normData = normalize(masterTable{:,:},1); %{:,:} converts table to doubles

%% Seeing which epsilon is best using sample data
tic;
C = [];
for i = 1:100
A = datasample(normData,10000,'Replace',false);
C(i) = clusterDBSCAN.estimateEpsilon(A,2,10);
end
toc;
D = mean(C);

%% DBScan

B = dbscan(normData,0.48,50); %using mean eps from sample


%
tic;
F = dbscan(normData,0.5,40); %20 minpts yielded 6 clusters, 30 minpts yielded 
% 5 clusters, 50 minpts yielded 3 clusters; moving 50 minpts with 0.5
% instead of 0.48 radius reduced it to 2 clusters, using 0.5 eps for 40
% trials also yield 2 clusters; I think 0.48 was better
toc;

