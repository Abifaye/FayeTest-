%% Machine Learning Master Script

%Go to folder with the master table
cd(uigetdir([],'Select Folder Containing Master Table'))

%% Initialize variables
%get all functions that provides data
masterRollAve = getrollingAverage; %select rewards and allRTs
masterRollRates = getrollingrates; %select fa, miss, and hit
labelTable = getLabelTable;

%concatinate table 
masterDBDataTable = table();
masterDBDataTable = horzcat(labelTable,masterRollAve,masterRollRates);
%save('[insertfilename].mat',"masterDBDataTable")

%% Separate hits and miss trials

%all combined trial ends
allTrialEnds = [labelTable.trialEnd];

%miss only
Idx_miss = find(strcmp(allTrialEnds,"miss"));
missDataTable = masterDBDataTable(Idx_miss,masterDBDataTable.Properties.VariableNames([1:5 8:9]));

%hits only
Idx_hit = find(strcmp(allTrialEnds,"hit"));
hitDataTable = masterDBDataTable(Idx_hit,masterDBDataTable.Properties.VariableNames([1:7 9]));

%Data table saver
%save('hitDataTable.mat',"hitDataTable")
%save('missDataTable.mat',"missDataTable")

%Normalize Data 
normData = normalize(masterDBDataTable{:,5:9},1); %used z-score
normData_hit = normalize(hitDataTable{:,5:8},1);
normData_miss = normalize(missDataTable{:,5:7},1);

%normData Saver
%save('normData_hitRTs.mat',"normData")
%save('[insertfilename].mat',"normData_hit")
%save('[insertfilename].mat',"normData_miss")


