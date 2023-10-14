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
%new normhit: normData_hit =
%horzcat(normalize(hitDataTable{:,5:7},1),normalize(hitDataTable{:,9},1));
%%I would suggest instead of doing this just readjust the datables instead

normData_miss = normalize(missDataTable{:,5:7},1);

%normData Saver
%save('normData.mat',"normData",)
%save('normData_hit.mat',"normData_hit")
%save('normData_miss.mat',"normData_miss")


%% DBscan
DBStructData = getDBScanner; %conduct DBScan

% DBStruct Saver
%name = 'DBstruct.mat';
%save(name,'-struct',"DBStruct")  %DOES NOT WORK FIX
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

%% t-SNE
%load data files
load normData_hit.mat
load normData_miss.mat
load hitDataTable.mat
load missDataTable.mat

%create tables so normalized Data has column labels
Tnorm_hit = array2table(normData_hit,'VariableNames',hitDataTable.Properties.VariableNames(5:8));
Tnorm_miss = array2table(normData_miss,'VariableNames',missDataTable.Properties.VariableNames(5:7));

%assign groups based on Tertile reaction times

%hits
firstIdx_hit = (Tnorm_hit.rollingrewards >= min(prctile(Tnorm_hit.rollingrewards,[0 33.33])) & Tnorm_hit.rollingrewards <= max(prctile(Tnorm_hit.rollingrewards,[0 33.33])));
secondIdx_hit = (Tnorm_hit.rollingrewards > min(prctile(Tnorm_hit.rollingrewards,[33.33 66.67])) & Tnorm_hit.rollingrewards <= max(prctile(Tnorm_hit.rollingrewards,[33.33 66.67])));
thirdIdx_hit = (Tnorm_hit.rollingrewards > min(prctile(Tnorm_hit.rollingrewards,[66.67 100])) & Tnorm_hit.rollingrewards <= max(prctile(Tnorm_hit.rollingrewards,[66.67 100])));

%misses
firstIdx_miss = (Tnorm_miss.rollingrewards >= min(prctile(Tnorm_miss.rollingrewards,[0 33.33])) & Tnorm_miss.rollingrewards <= max(prctile(Tnorm_miss.rollingrewards,[0 33.33])));
secondIdx_miss = (Tnorm_miss.rollingrewards > min(prctile(Tnorm_miss.rollingrewards,[33.33 66.67])) & Tnorm_miss.rollingrewards <= max(prctile(Tnorm_miss.rollingrewards,[33.33 66.67])));
thirdIdx_miss = (Tnorm_miss.rollingrewards > min(prctile(Tnorm_miss.rollingrewards,[66.67 100])) & Tnorm_miss.rollingrewards <= max(prctile(Tnorm_miss.rollingrewards,[66.67 100])));

% Assign Tertile labels based on idx

%hits
Tnorm_hit.labels(firstIdx_hit) = 1;
Tnorm_hit.labels(secondIdx_hit) = 2;
Tnorm_hit.labels(thirdIdx_hit) = 3;

%miss
Tnorm_miss.labels(firstIdx_miss) = 1;
Tnorm_miss.labels(secondIdx_miss) = 2;
Tnorm_miss.labels(thirdIdx_miss) = 3;
    
%t-SNE 

%hits
tSNE_hit = tsne(normData_hit,"Distance","cityblock");

figure;
gscatter(tSNE_hit(:,1),tSNE_hit(:,2),Tnorm_hit.labels)
title('t-SNE Hits: RT Tertile')

%miss
tSNE_miss = tsne(normData_miss,"Distance","cityblock"); % I GET A WARNING WRITE IT DOWN

figure;
gscatter(tSNE_miss(:,1),tSNE_miss(:,2),Tnorm_miss.labels)
title('t-SNE Miss: RT Tertile')











