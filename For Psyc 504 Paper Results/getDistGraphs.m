function [outputArg1,outputArg2] = getDistGraphs
%Plots how the distribution of certain metrics are partitioned by colour
%coding them

%load master table with profiles
load('TablewithProfiles.mat');

%% aveC
stimC = [TablewithProfiles.stimC];
unStimC = [TablewithProfiles.noStimC];
aveC = (stimC + unStimC)/2;

%curvefitting variables
amp = 136.7;
mu = 0.6774;
sigma = 0.4078;

% Z-score
aveC_zScore = (aveC - mu) / sigma;

%Indices
leftIdx = aveC_zScore < 0;
rightIdx = aveC_zScore > 0;

%Init matrices for  below (leftprofiles) and above (rightprofiles)
%mean
leftProfiles = [];
rightProfiles = [];

% Divide Ave Cs between above and below mean using the indices
leftProfiles = [leftProfiles;aveC(leftIdx,:)];
rightProfiles = [rightProfiles;aveC(rightIdx,:)];


%plot
figure;
hold on
histogram(leftProfiles,25,'BinLimits',[min(leftProfiles) max(leftProfiles)],'FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="b")
histogram(rightProfiles,25,'BinLimits',[min(rightProfiles) max(rightProfiles)],'FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="r")
xline(mu,'-.')
title('Partition of the Average Criterion Distribution','FontSize',8);
ay = gca;
ylim(ay, [0 45]); 
ay.FontSize = 10;
ylabel('Counts',FontSize=10)
ax = gca;
ax.FontSize = 10;
ax.TickDir = "out";
xlabel('Criterion',FontSize=10)
legend('Criterion Below Mean', 'Criterion Above Mean', 'Mean')

%% Top Up d'

%load master table with profiles
load('TablewithProfiles.mat');

% Init variable
topUp_D = [TablewithProfiles.topUpDPrime];
%the master table
 
% Get Profiles

%curvefitting variables
amp = 81.03;
mu = 2.552;
sigma = 0.8123;

% Z-score
topUp_zScore = (topUp_D - mu) / sigma;

%Indices
leftIdx = topUp_zScore < 0;
rightIdx = topUp_zScore > 0;


%Init matrices for  below (leftprofiles) and above (rightprofiles)
%mean
leftProfiles = [];
rightProfiles = [];


% Divide top up ds between above and below mean using the indices
leftProfiles = [leftProfiles;topUp_D(leftIdx,:)];
rightProfiles = [rightProfiles;topUp_D(rightIdx,:)];

%plot
figure;
hold on
histogram(leftProfiles,25,'BinLimits',[min(leftProfiles) max(leftProfiles)],'FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="b")
histogram(rightProfiles,25,'BinLimits',[min(rightProfiles) max(rightProfiles)],'FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="r")
xline(mu,'-.')
title('Partition of the Top Up Dprime Distribution','FontSize',8);
ay = gca;
ylim(ay, [0 50]); 
ay.FontSize = 10;
ylabel('Counts',FontSize=10)
ax = gca;
ax.FontSize = 10;
ax.TickDir = "out";
xlabel('Top Up Dprime',FontSize=10)
legend('Top Up Dprime Below Mean', 'Top Up Dprime Above Mean', 'Mean',fontsize=8)

%% delta d'

%get delta_d
delta_d = getdelta_d;

%load master table with profiles
load('TablewithProfiles.mat');

% Curve Fitting delta d'
d_histcounts = histcounts(delta_d,-5:0.15:5);
d_range = -4.9:0.15:4.9;

% Z-score
amp =  171.3;
mu = -0.04869;
sigma = 0.2824;
deltaD_zScore = (delta_d - mu) / sigma;


%Indices 
leftIdx = deltaD_zScore < 0;
rightIdx = deltaD_zScore > 0;

%Init matrices for  below (leftprofiles) and above (rightprofiles)
%mean
leftProfiles = [];
rightProfiles = [];

% Divide delta ds between above and below mean using the indices
leftProfiles = [leftProfiles;delta_d(leftIdx,:)];
rightProfiles = [rightProfiles;delta_d(rightIdx,:)];

%plot
figure;
hold on
histogram(leftProfiles,25,'BinLimits',[min(leftProfiles) max(leftProfiles)],'FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="b")
histogram(rightProfiles,25,'BinLimits',[min(rightProfiles) max(rightProfiles)],'FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="r")
xline(mu,'-.')
title('Partition of the Delta Dprime Distribution','FontSize',8);
ay = gca;
ylim(ay, [0 50]); %adjust to have same y-axis
ay.FontSize = 10;
ylabel('Counts',FontSize=10)
ax = gca;
ax.FontSize = 10;
ax.TickDir = "out";
xlabel('Delta Dprime',FontSize=10)
legend('Delta Dprime Below Mean', 'Delta Dprime Above Mean', 'Mean',fontsize=8)

%% RTs
% Initialize variables
folderPath = uigetdir();
%load master table with hit profiles file 
load('TablewithHitProfiles.mat');
%init locations for profiles in each tertile
firstIdx= [];
secondIdx = [];
thirdIdx = [];

%get all RTs in trials and sessions
masterRTs = zeros(); %preallocates vector for all RTs
RTsCell = [TablewithHitProfiles.stimCorrectRTs]; % creates cell with all the RTs from master table for correct responses
Counter = 0; %creates a counter for keeping track of where to place the RTS in the masterRTs
for nSession = 1:length(RTsCell) % loop through all the sessions in RTsCell
    for nTrial = 1:length(RTsCell{nSession}) % loop through all trials in current session
        masterRTs(nTrial + Counter, 1) = RTsCell{nSession}(nTrial); %places the RT for the current trial
        %into the masterRTs vector. The counter keeps track of where to
        %place the next session RTs
    end
    Counter = Counter + sum(nTrial); %The counter keeps track of how long the
        %session is so that the RTs in the next session will be placed 
        % correctly in masterRTs
end

%Creates Indieces that separate RTs into tertile
for nSession = 1:height(TablewithHitProfiles)
    %create variables for reaction times from the master
    %table
    RTs = cell2mat(TablewithHitProfiles.stimCorrectRTs(nSession))';
   
    %creates range for each tertile
    firstIdx = logical([firstIdx; (RTs >= min(prctile(RTs,[0 33.33])) & RTs <= max(prctile(RTs,[0 33.33])))]);
    secondIdx = logical([secondIdx; (RTs > min(prctile(RTs,[33.33 66.67])) & RTs <= max(prctile(RTs,[33.33 66.67])))]);
    thirdIdx = logical([thirdIdx; (RTs > min(prctile(RTs,[66.67 100])) & RTs <= max(prctile(RTs,[66.67 100])))]);

end

%plot
figure;
hold on
histogram(masterRTs(firstIdx),25,'FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="b")
histogram(masterRTs(secondIdx),25,'FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="r")
histogram(masterRTs(thirdIdx),25,'FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="g")
title('Reaction Time Distribution for Each Tertile','FontSize',8);
ay = gca;
ylim(ay, [0 2500]); %adjust to have same y-axis
ay.FontSize = 10;
ylabel('Counts',FontSize=10)
ax = gca;
ax.FontSize = 10;
ax.TickDir = "out";
xlabel('Reaction Time (ms)',FontSize=10)
legend('First Tertile', 'Second Tertile', 'ThirdTertile',fontsize=8)

%% Reaction Time Graph Version 2 (better version)
% Initialize variables
folderPath = uigetdir();
%load master table with hit profiles file 
load('TablewithHitProfiles.mat');

masterRTs = zeros(); %preallocates vector for all RTs
RTsCell = [TablewithHitProfiles.stimCorrectRTs]; % creates cell with all the RTs from master table for correct responses
Counter = 0; %creates a counter for keeping track of where to place the RTS in the masterRTs
for nSession = 1:length(RTsCell) %a for loop to loop through all the sessions in RTsCell
    for nTrial = 1:length(RTsCell{nSession}) %a for loop to go loop through all trials in current session
        masterRTs(nTrial + Counter, 1) = RTsCell{nSession}(nTrial); %places the RT for the current trial
        %into the masterRTs vector. The counter keeps track of where to
        %place the next session RTs
    end
    Counter = Counter + sum(nTrial); %The counter keeps track of how long the
        %session is so that the RTs in the next session will be placed 
        % correctly in masterRTs
end

%Separates master RTs into tertile
firstTertileRange = prctile(masterRTs,[0 33.33]);
secondTertileRange = prctile(masterRTs,[33.33 66.67]);
thirdTertileRange = prctile(masterRTs,[66.67 100]);


%Plot
figure;
hold on
histogram(masterRTs,'FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="b")
xline(100,'-.',Color='b')
xline(248,'-.',Color='r')
xline(303,'-.',Color='g')
title('Partition of the Reaction Time Distribution','FontSize',8);
ay = gca;
%ylim(ay, [0 50]); %adjust to have same y-axis
ay.FontSize = 10;
ylabel('Counts',FontSize=10)
ax = gca;
ax.FontSize = 10;
ax.TickDir = "out";
xlabel('Reaction Time (ms)',FontSize=10)
legend('','Start of First Tertile Range',' Start of Second Tertile Range', ...
    'Start of Third Tertile Range',fontsize=8)

end
end
