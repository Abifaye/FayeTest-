%% Initializing Variables

%Go to folder with the master table
cd(uigetdir([],'Select Folder Containing Master Table'))

%% Initialize variables
%get all functions that provides data
masterRollAve = getrollingAverage; %select rewards and allRTs
masterRollRates = getrollingrates; %select fa, miss, and hit

%% Create Labels for Data
load masterTable_allLuminanceCleaned.mat

labelTable= table();
masterDataTable = table();

animal = [];
date = [];
trialEnd = [];

%
for nSession = 1:size(T,1)
    sessionTrialEnds = table();
    sessionTrialEnds.miss = cell2mat(T.miss(nSession))';
    date = [date; repmat(T.(2)(nSession), 1, size(sessionTrialEnds.miss,1))']; 
    animal = [animal; repmat(T.(1)(nSession), 1, size(sessionTrialEnds.miss,1))'];
end

%
for nSession = 1:size(T,1)
    sessionTrialEnds = table();
    sessionTrialEnds.miss = cell2mat(T.miss(nSession))'; %need to check if it's gonna give us problems
    sessionTrialEnds.hit = cell2mat(T.hit(nSession))';
    sessionTrialEnds.fa = cell2mat(T.hit(nSession))';
    trialEndSession = [];
    for nTrial = 1:size(sessionTrialEnds.miss,1) 
        if sessionTrialEnds.miss(nTrial) == 1
            trialEndSession =  [trialEndSession; "miss"];
        elseif sessionTrialEnds.hit(nTrial) == 1
            trialEndSession =  [trialEndSession; "hit"];
        else sessionTrialEnds.fa(nTrial) == 1 
            trialEndSession =  [trialEndSession; "fa"];
        end
    end
    trialEnd = [trialEnd; trialEndSession];
end


labelTable.animal = animal;
labelTable.date = date;
labelTable.trialEnd = trialEnd;




%concatinate table 
masterDataTable = horzcat(labelTable,masterRollAve,masterRollRates);


%%

matrix = [labelTable.trialEnd];

%miss
Idx_miss = find(strcmp(matrix,"miss"));
missDataTable = masterDataTable(Idx_miss,masterDataTable.Properties.VariableNames([1:4 6:8]));

%hits
Idx_hit = find(strcmp(matrix,"hit"));
hitDataTable = masterDataTable(Idx_hit,masterDataTable.Properties.VariableNames(1:8));


%save('masterDataTable.mat',"masterDataTable")
%save('hitDataTable.mat',"hitDataTable")
%save('missDataTable.mat',"missDataTable")

%Normalize Data
normData = normalize(masterDataTable{:,:},1); %used z-score
normData_hit = normalize(hitDataTable{:,4:8},1);
normData_miss = normalize(missDataTable{:,4:7},1);

%save('normData.mat',"normData")
%save('normData_hit.mat',"normData_hit")
%save('normData_miss.mat',"normData_miss")



DBScan_trial = dbscan(normData_hit,0.24,50);
DBScan_trialMiss = dbscan(normData_miss,0.24,50);

%% DBscan
DBStruct = getDBScanner(normData);

delete normData.mat

save DBStruct

plot(DBStruct(1).data25,'Color','b')
%clusters = dbscan(normData,0.5,50); %using mean eps from sample

%% Total Number of Trials
for nData = 1:size(T,1);
    SessionSize(nData) = size(T.optoPowerMW{nData,1},2);
end
%Something I need to use later on for revising code for rolling averages 
Vdist = 'no';
if strcmp(Vdist,'yes')
    B = 'yay~';
elseif strcmp(Vdist,'no')
    B ='aww';
end

%lapse rate graph against fa and hits

%% remove uncessary pts
for dp1 = 1:length(normData)
    for dp2 = 1:length(normData)
        output(dp1,dp2) = pdist2(normData(dp1),normData(dp2),'euclidean');
    end
end

%% Other extra stuff
distMat = triu(output);
totalTrials = sum(SessionSize);

B = T.animal=="2236";
D = T.date(B); 
E = TablewithHitProfiles.date(TablewithHitProfiles.animal=="2236");%some trials for each animal may have been taken out
%
A = ismember(T.animal,TablewithHitProfiles.animal);
B = find(A==0); %animal new one may also have been added from 94-124 (on the shorter one not the longer one; 421)

%% DBStruct Saver
save('DBStruct.mat',"DBStruct") 

% NEXT JOB IS TO CREATE GRAPHS FOR DBSCAN CLUSTERS WITH MORE THAN 1000 ,
% maybe start for data between 65 and 66 as this takes about 10% (25 000~) of the
% data as outliers 
% MINPTS






