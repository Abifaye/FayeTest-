%% Dbscan edit script

%a rough and ongoing copy of the DBscan script

%% Initializing Variables

%Go to folder with the master table
cd(uigetdir([],'Select Folder Containing Master Table'));

%get all functions that will give the variables struct
masterRollAve = getrollingAverage;
masterRollRates = getrollingrates;
masterTable = horzcat(masterRollAve,masterRollRates);

%note, figure out a way to put a mark on the variables before they all go
%away into the masterMat and lose their labels. It should put a labeling
%index saying something like, row 1 of the masterMat corresponds to this
%variable, row 2 is that variable, etc. so that we can track which
%variables are which 

%Normalize Variables
normData = normalize(masterTable{:,:},1);

%% Trial by Trial Matrix
%for nTrialA = 1:length(varA)
    %Matrix(nTrial,:) = varA(nTrial);
    %for nTrialB = 1:length(varB)
        %Matrix(:,nTrialB) = jaksjdaskd
    %end
%end

%pdist(normData,"fastsquaredeuclidean",CacheSize=2);
%triu(masterTable{:,:}));

%% Seeing which epsilon is best (not directly though), just using samples
%next time you can do the estimate epsilon with the real data and plot it
%using the clusterer thing mentioned
tic;
C = [];
for i = 1:100
A = datasample(normData,10000,'Replace',false);
C(i) = clusterDBSCAN.estimateEpsilon(A,2,10);
end
toc;
D = mean(C);

B = dbscan(normData,0.48,10); %using mean from sample

E = clusterDBSCAN.estimateEpsilon(normData,2,10);

%
tic;
F = dbscan(normData,0.5,40); %20 minpts yielded 6 clusters, 30 minpts yielded 
% 5 clusters, 50 minpts yielded 3 clusters; moving 50 minpts with 0.5
% instead of 0.48 radius reduced it to 2 clusters, using 0.5 eps for 40
% trials also yield 2 clusters; I think 0.48 was better
toc;

%%


%
triu(pdist(normData,"euclidean"));

triangleTable = triu(masterTable{:,:});

triangleNorm = logical(triu(normData));

%DBScan

A = dbscan(masterMat,0.6,10,"Distance","cityblock"); % ok, but need a lot of tweaking with the eps and minpts


%% attempts to making dbscan more efficient
%fail 1
%load("masterTable_complete.mat");
%hits = [T.hit];
%container = {};
c%ounter = 0;

%This doesn't work because you can't pdist indiv sessions, must be all;
%for nSession = 1:length(hits)
    %container{nSession} = pdist(normData(counter+1:counter+length(hits{nSession}),1:5),"cityblock");
    %counter = counter + length(hits{nSession});
%end

%cellCont = cell2mat(container);

%= pdist(C,"cityblock");

%attempt 2
%logicalMat = ones(10,10);
%logicalMat = triu(logicalMat,1);
%for dp1 = 1:length(logicalMat)
    %for dp2 = 1:length(logicalMat)
        %if logicalMat(dp1,dp2) == 1
            output = pdist(normData(dp1,:));
        %end
    %end
%end

%% testing on relationship btwn FA and prestim time

%Go to folder with the master table
cd(uigetdir());

%
masterRollRates = getrollingrates;
masterRollAve = getrollingAverage;


%plot overall
figure;
scatter(masterRollAve.rollingpreStimMS,masterRollRates.rollingfarate)
ylabel('Rolling FA Rate')
xlabel('Rolling PreStim Time (ms)')
title('Relationship Between Rolling FA rate and Rolling Prestim Time')


%plot samples
figure;
t= tiledlayout(3,2);
title(t,'Relationship Between Rolling FA Rate and PreStim Time')

%ax = gca;
%xlim(ax, [0, bins]);
%ax.XGrid = 'on';
%ax.XMinorGrid = "on";
%ax.XTick = [0:200:800];
%ax.XTickLabel = {'-400', '-200', '0', '600', '800'};
%ax.FontSize = 8;
%ax.TickDir = "out";
%ay = gca;
%ylim(ay, [0.47 0.52]);
%ay.FontSize = 8;

ax1 = nexttile;
scatter(cellpreStimTime{302},cellFARate{302})
title('Session 302',FontSize=8);

ax2 = nexttile;
scatter(cellpreStimTime{16},cellFARate{16})
title('Session 16',FontSize=8);

ax3 = nexttile;
scatter(cellpreStimTime{9},cellFARate{9})
title('Session 9',FontSize=8);


ax4 = nexttile;
scatter(cellpreStimTime{165},cellFARate{165})
title('Session 165',FontSize=8);

ax5 = nexttile;
scatter(cellpreStimTime{215},cellFARate{215})
title('Session 215',FontSize=8);

ax6 = nexttile;
scatter(cellpreStimTime{156},cellFARate{156})
title('Session 156',FontSize=8);

%xlabels
xlim([ax1,ax2,ax3,ax4,ax5,ax6],[800 2400])

%ylabels
ylim([ax1,ax2,ax3,ax4,ax5,ax6],[0 100]) 
yticks([ax1,ax2,ax3,ax4,ax5,ax6],[0:20:100])

%% Distributions of data

%
[cellRT, cellRwd] = getrollingAverage;
[cellHitRate,cellMissRate,cellFARate] = getrollingrates;

%
rollingRT = cell2mat(cellRT);
rollingRwd = cell2mat(cellRwd);
rollingHitRate = cell2mat(cellHitRate);
rollingMissRate = cell2mat(cellMissRate);
rollingFARate = cell2mat(cellFARate);

%plots
figure;
histogram(rollingRwd)
title('Rolling Rewards')
figure;
histogram(rollingRT)
title('Rolling Reaction Times')
figure;
histogram(rollingHitRate)
title('Rolling Hit Rate')
figure;
histogram(rollingMissRate)
title('Rolling Miss Rate')
figure;
histogram(rollingFARate)
title('Rolling False Alarm Rate')

%% Total Number of Trials
for nData = 1:size(T,1);
    SessionSize(nData) = size(T.optoPowerMW{nData,1},2);
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
B = find(A==0); %animal new one may also have been added from 94-124 (on the shorter one not the longer one; 42

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





   






