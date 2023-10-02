%% Initializing Variables

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
%save('masterDBDataTable.mat',"masterDBDataTable")



%% Separate hits and miss trials

%all combined trial ends
allTrialEnds = [labelTable.trialEnd];

%miss only
Idx_miss = find(strcmp(allTrialEnds,"miss"));
missDataTable = masterDBDataTable(Idx_miss,masterDBDataTable.Properties.VariableNames([1:4 6:9]));

%hits only
Idx_hit = find(strcmp(allTrialEnds,"hit"));
hitDataTable = masterDBDataTable(Idx_hit,masterDBDataTable.Properties.VariableNames(1:9));


%save('hitDataTable.mat',"hitDataTable")
%save('missDataTable.mat',"missDataTable")

%Normalize Data 
normData = normalize(masterDBDataTable{:,4:8},1); %used z-score
normData_hit = normalize(hitDataTable{:,4:8},1);
normData_miss = normalize(missDataTable{:,4:7},1);

%save('normData.mat',"normData")
%save('normData_hit.mat',"normData_hit")
%save('normData_miss.mat',"normData_miss")


%% DBscan
DBStructData = getDBScanner; %conduct DBScan

%choose whether to append or create a struct for data obtained from the
%DBScan
append_DBStruct = input(strcat('Append or Create New DBStruct? [Append=1/Create=2]',32)); 

%% FOR APPEND WE HAVE TO ADD HERE AN EXTRA STEP TO LOAD THE STRUCT (NO THIS GOES BEFORE WE START DBSTRUCT -- 
% CONFIRMS HOW MANY DATA THERE ARE, better to put it in dbscanner, create a display saying how many data 
% there are, so we don't need to be asked [using sum of from column 2:end])

%choose which struct to append/create based on data type from DBScan (hit
%only data, miss only data, or combined)
selection = listdlg('PromptString',{'Select which Struct to use'},'ListString',{['DBStruct'],['DBHit'],['DBMiss']},'SelectionMode','single');

if append_DBStruct == 1 %if append chosen
    if selection == 1 %combined
        load DBStruct.mat
        names = [fieldnames(DBStruct); fieldnames(DBStructData)]; %obtain fieldnames of dbscan data and previously made struct
        DBStruct = cell2struct([struct2cell(DBStruct); struct2cell(DBStructData)], names, 1); %concatenate dbscan data and struct
    elseif  selection == 2 %hit
        load DBHit.mat
        names = [fieldnames(DBHit); fieldnames(DBStructData)];
        DBHit = cell2struct([struct2cell(DBHit); struct2cell(DBStructData)], names, 1);
    elseif selection == 3 %miss
        load DBMiss.mat
        names = [fieldnames(DBMiss); fieldnames(DBStructData)];
        DBMiss = cell2struct([struct2cell(DBMiss); struct2cell(DBStructData)], names, 1);
    end
else append_DBStruct == 2 %if create chosen
    %init DBScan data as appropriate struct
    if selection == 1
        DBStruct = DBStructData;
    elseif  selection == 2
        DBHit = DBStructData;
    elseif selection == 3
        DBMiss = DBStructData;
    end
end


%% DBStruct Saver
%save('DBStruct.mat',"DBStruct") 
%save('DBHit.mat',"DBHit") 
%save('DBMiss.mat',"DBMiss") 

%% Cityblock Distance Distribution

%hit
A = normData_hit(strcmp(hitDataTable.trialEnd,"hit") & hitDataTable.optoPower~=0,1:5);
B = pdist(A,"cityblock");
ZB = [];
ZB = squareform(B);
triZB = triu(ZB);
MtriZB = mean(triZB);
nBins = -20:0.05:20;

%miss
C = normData_miss(missDataTable.optoPower~=0,1:4);
D = pdist(C,"cityblock");
ZD = [];
ZD = squareform(D);
triZD = triu(ZD);
MtriZD = mean(triZD);
nBins = -20:0.05:20;

%
figure;
histogram(MtriZD)%nBins)

figure;
histogram(MtriZB)%nBins)


%% CurveFitting

% Curve Fitting variables
D_histcounts = histcounts(D,nBins);
Dx = 1:length(D_histcounts);
%
%gaussEqn = 'a*exp(-((x-b)/c)^2)';
gaussEqn = @(x) 1.5543e+07*exp(-((x-7.7)/11).^2);
startPoints = [1.5543e+07];
f1 = fit(Dx',D_histcounts',gaussEqn,'Start', startPoints);

figure;
hold on
plot(D_histcounts,'.')
plot(gaussEqn(Dx))
legend('Data', 'Fitting')


figure;

amp =  171.3; %height% Z-score

mu = -0.04869; %center
sigma = 0.2824; %width

%example that might work: 1.5543e+07*exp(-((x-b)/11)^2) w/ r-square:0.8294;
%try with 7.7 as b. Must try extending x to negatives, fill y-values with
%zeroes manually

deltaD_zScore = (delta_d - mu) / sigma;

%% This Did not work
%gaussian = @(x) 1.7594e+06*exp(-((x-476.3925)/61.8232).^2);
%skewedgaussian = @(x,alpha) 2*gaussian(x).*normcdf(alpha*x);

%figure;
%hold on
%plot(D_histcounts)
%plot(gaussian(Dx))
%plot(Dx, skewedgaussian(Dx, 6))
%legend('Data', 'fitting', 'skewed')

%% Cluster Distances into Tertile

%creates range for each tertile
firstIdx = (MtriZD >= min(prctile(MtriZD,[0 33.33])) & MtriZD <= max(prctile(MtriZD,[0 33.33])));
secondIdx = (MtriZD > min(prctile(MtriZD,[33.33 66.67])) & MtriZD <= max(prctile(MtriZD,[33.33 66.67])));
thirdIdx = (MtriZD > min(prctile(MtriZD,[66.67 100])) & MtriZD <= max(prctile(MtriZD,[66.67 100])));

%load master table with hit profiles file
load('masterTable_allLuminanceTrials.mat')

%Create 2 matrices containing all hits and all miss profiles
hitProfiles = cell2mat(T.hitProfiles);
missProfiles = cell2mat(T.missProfiles);

%miss
firstTertile_miss = missProfiles(firstIdx,1:end);
secondTertile_miss = missProfiles(secondIdx,1:end);
thirdTertile_miss = missProfiles(thirdIdx,1:end);

%hit
firstTertile_hit = hitProfiles(firstIdx,1:end);
secondTertile_hit = hitProfiles(secondIdx,1:end);
thirdTertile_hit = hitProfiles(thirdIdx,1:end);

%all
firstTertile_all = [firstTertile_hit; -firstTertile_miss];
secondTertile_all = [secondTertile_hit; -secondTertile_miss];
thirdTertile_all = [thirdTertile_hit; -thirdTertile_miss];

%no tertiles all
all_profiles = [hitProfiles; -missProfiles];

figure;
hold on
plot(mean(firstTertile_all))
plot(mean(secondTertile_all))
plot(mean(thirdTertile_all))
legend('firstTertile', 'secondTertile', 'thirdTertile')

figure;
hold on
plot(mean(firstTertile_all))
plot(mean(all_profiles))
legend('First Tertile', 'All Profiles')

figure;
hold on
plot(mean(secondTertile_all))
plot(mean(all_profiles))
legend('Second Tertile', 'All Profiles')

figure;
hold on
plot(mean(thirdTertile_all))
plot(mean(all_profiles))
legend('Third Tertile', 'All Profiles')

%% Figures of Data in 2D










