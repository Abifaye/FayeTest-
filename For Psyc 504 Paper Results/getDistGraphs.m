function getDistGraphs
%Plots how the distribution of certain metrics are partitioned by colour
%coding them

%% load master table with profiles

%Go to folder containing master table
cd(uigetdir('', 'Go to folder containing master table'));

%choose desired master table file
load(uigetfile('','Select desired master table'));


%% aveC
stimC = [T.stimC];
unStimC = [T.noStimC];
aveC = (stimC + unStimC)/2;

%curvefitting variables
%for SC: amp = 136.7;mu = 0.6774;sigma = 0.4078;
%for V1:amp = 97.8051;mu = 0.7706;sigma = 0.3690;

amp = 97.8051;
mu = 0.7706;
sigma = 0.3690;

% Z-score
aveC_zScore = (aveC - mu) / sigma;

%Indices
leftIdx = aveC_zScore < 0;
rightIdx = aveC_zScore > 0;

%Init matrices for  below (leftprofiles) and above (rightprofiles)
%mean
leftProfiles = [];
rightProfiles = [];

%Divide Ave Cs between above and below mean using the indices
leftProfiles = [leftProfiles;aveC(leftIdx,:)];
rightProfiles = [rightProfiles;aveC(rightIdx,:)];

%plot

%set graph bin edges
binEdges = min(aveC):0.16:max(aveC);

figure;
hold on
% h1 = histogram(leftProfiles,'BinLimits',[min(leftProfiles) max(leftProfiles)],'BinWidth', 0.11,'Normalization','probability','FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="b");
% h2 = histogram(rightProfiles,'BinLimits',[min(rightProfiles) max(rightProfiles)],'BinWidth', 0.11,'Normalization','probability','FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="r");
%h1 = histogram(aveC,'BinEdges',binEdges,'Normalization','probability',FaceColor="w");
h2 = histogram(aveC(leftIdx),'BinEdges',binEdges,'Normalization','probability',FaceColor="r");
h3 = histogram(aveC(rightIdx),'BinEdges',binEdges,'Normalization','probability',FaceColor="b");
xline(mu,'--')
title('Partition of the Average Criterion Distribution for V1 Luminance','FontSize',12);
ay = gca;
ay.FontSize = 10;
ylabel('Probability',FontSize=10)
ax = gca;
ax.FontSize = 10;
ax.TickDir = "out";
xlabel('Criterion',FontSize=10)
legend('Criterion Below Mean', 'Criterion Above Mean', 'Mean')

%% Top Up d'

% % Init variable
% topUp_D = [T.topUpDPrime];
% %the master table
% 
% % Get Profiles
% 
% %curvefitting variables
% amp = 81.03;
% mu = 2.552;
% sigma = 0.8123;
% 
% % Z-score
% topUp_zScore = (topUp_D - mu) / sigma;
% 
% %Indices
% leftIdx = topUp_zScore < 0;
% rightIdx = topUp_zScore > 0;
% 
% 
% %Init matrices for  below (leftprofiles) and above (rightprofiles)
% %mean
% leftProfiles = [];
% rightProfiles = [];
% 
% 
% % Divide top up ds between above and below mean using the indices
% leftProfiles = [leftProfiles;topUp_D(leftIdx,:)];
% rightProfiles = [rightProfiles;topUp_D(rightIdx,:)];
% 
% %plot
% figure;
% hold on
% histogram(leftProfiles,25,'BinLimits',[min(leftProfiles) max(leftProfiles)],'Normalization','probability','FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="b")
% histogram(rightProfiles,25,'BinLimits',[min(rightProfiles) max(rightProfiles)],'Normalization','probability','FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="r")
% xline(mu,'-.')
% title('Partition of the Top Up Dprime Distribution','FontSize',8);
% ay = gca;
% ylim(ay, [0 50]);
% ay.FontSize = 10;
% ylabel('Probability',FontSize=10)
% ax = gca;
% ax.FontSize = 10;
% ax.TickDir = "out";
% xlabel('Top Up Dprime',FontSize=10)
% legend('Top Up Dprime Below Mean', 'Top Up Dprime Above Mean', 'Mean',fontsize=8)

%% delta d'

%get delta_d
delta_d = getdelta_d(T);

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
h1 = histogram(leftProfiles,'BinLimits',[min(leftProfiles) max(leftProfiles)], 'BinWidth', 0.075, 'Normalization','probability','FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="b");
h2 = histogram(rightProfiles,'BinLimits',[min(rightProfiles) max(rightProfiles)], 'BinWidth', 0.075, 'Normalization','probability','FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor="r");
xline(mu,'--')
title('Partition of the Delta Dprime Distribution for V1 Luminance','FontSize',12);
ay = gca;
%ylim(ay, [0 0.2]); %adjust to have same y-axis
ay.FontSize = 10;
ylabel('Probability')
ax = gca;
ax.FontSize = 10;
ax.TickDir = "out";
xlim([-0.86 0.6])
xlabel('Delta Dprime')
legend('Delta Dprime Below Mean', 'Delta Dprime Above Mean', 'Mean',fontsize=8)

%for computing optimal binwidth for histogram: max(rightProfiles)-min(leftProfiles)/(2*192^(1/3))

%% Reaction Time Graph Version 1

%for taking the entire RTs and colour coding each quintile

%get all RTs in trials and sessions
masterRTs = zeros(); %preallocates vector for all RTs
RTsCell = [T.stimCorrectRTs]; % creates cell with all the RTs from master table for correct responses
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

% init locations for indices in each quintile
firstIdx= [];
secondIdx = [];
thirdIdx = [];
fourthIdx = [];
fifthIdx = [];


%Creates Indices that separate RTs into tertile
for nSession = 1:height(T)
    %create variables for reaction times from the master
    %table
    RTs = cell2mat(T.stimCorrectRTs(nSession))';

    %creates range for each quintile
    firstIdx = logical([firstIdx; (RTs >= min(prctile(RTs,[0 20])) & RTs <= max(prctile(RTs,[0 20])))]);
    secondIdx = logical([secondIdx; (RTs > min(prctile(RTs,[20 40])) & RTs <= max(prctile(RTs,[20 40])))]);
    thirdIdx = logical([thirdIdx; (RTs > min(prctile(RTs,[40 60])) & RTs <= max(prctile(RTs,[40 60])))]);
    fourthIdx = logical([fourthIdx; (RTs > min(prctile(RTs,[60 80])) & RTs <= max(prctile(RTs,[60 80])))]);
    fifthIdx = logical([fifthIdx; (RTs > min(prctile(RTs,[80 100])) & RTs <= max(prctile(RTs,[80 100])))]);
end


% Calculate the edges for the histogram bins
edges = linspace(min(masterRTs), max(masterRTs), 20);

% Plot 
figure;
hold on
%plot the histogram of the particular quintile distribution
histogram(masterRTs(firstIdx),edges,'Normalization','probability','FaceColor','r')
histogram(masterRTs(secondIdx),edges,'Normalization','probability','FaceColor','g')
histogram(masterRTs(thirdIdx),edges,'Normalization','probability','FaceColor','b')
histogram(masterRTs(fourthIdx),edges,'Normalization','probability','FaceColor','k')
histogram(masterRTs(fifthIdx),edges,'Normalization','probability','FaceColor','m')
xline(mean(masterRTs), '--')
hold off
title('Partition of the Reaction Time Distribution for SC Luminance','FontSize',10);
ylabel('Probability', FontSize=10)
xlabel('Reaction Time (ms)',FontSize=10)
legend('1st Quintile', '2nd Quintile', '3rd Quintile', '4th Quintile', '5th Quintile')


%% RTs Version 2

%for when sorting RTs into quintile for each session

%get all RTs in trials and sessions
masterRTs = zeros(); %preallocates vector for all RTs
RTsCell = [T.stimCorrectRTs]; % creates cell with all the RTs from master table for correct responses
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

% %init locations for indices in each quintile
firstIdx= [];
secondIdx = [];
thirdIdx = [];
fourthIdx = [];
fifthIdx = [];


%Creates Indices that separate RTs into tertile
for nSession = 1:height(T)
    %create variables for reaction times from the master
    %table
    RTs = cell2mat(T.stimCorrectRTs(nSession))';

    %creates range for each quintile
    firstIdx = logical([firstIdx; (RTs >= min(prctile(RTs,[0 20])) & RTs <= max(prctile(RTs,[0 20])))]);
    secondIdx = logical([secondIdx; (RTs > min(prctile(RTs,[20 40])) & RTs <= max(prctile(RTs,[20 40])))]);
    thirdIdx = logical([thirdIdx; (RTs > min(prctile(RTs,[40 60])) & RTs <= max(prctile(RTs,[40 60])))]);
    fourthIdx = logical([fourthIdx; (RTs > min(prctile(RTs,[60 80])) & RTs <= max(prctile(RTs,[60 80])))]);
    fifthIdx = logical([fifthIdx; (RTs > min(prctile(RTs,[80 100])) & RTs <= max(prctile(RTs,[80 100])))]);
end

%Distribution struct
distStruct = struct('FirstQuintile',masterRTs(firstIdx), 'SecondQuintile', masterRTs(secondIdx), 'ThirdQuintile', masterRTs(thirdIdx), 'FourthQuintile', masterRTs(fourthIdx), 'FifthQuintile', masterRTs(fifthIdx));
distFields = fieldnames(distStruct);

%plot

%create tiled layout for all plots
figure;
t= tiledlayout(3,2);
title(t,'Comparison of RTs Distribution Across the Five Quintiles for V1 Luminance',"FontSize",15)
tileOrder = [1 3 5 2 4]; %places the graphs in right place
c = ['rgbkm'];

%loop through each quintile distribution
for nTile = 1:length(distFields)
    %start a tiledlayout
    nexttile(tileOrder(nTile));
    hold on
    %plot the histogram of the particular quintile distribution
    histogram(distStruct.(string(distFields(nTile))),25,'Normalization','probability','FaceAlpha',0.3,'EdgeAlpha',0.3,FaceColor=c(nTile))
    xline(mean(distStruct.(string(distFields(nTile)))), '--')
    hold off
    title(string(distFields(nTile)))
    ay = gca;
    ylim(ay, [0 0.18]); %adjust to have same y-axis
    xlim([0 500])
    ay.FontSize = 10;
    ylabel('Probability', FontSize=10)
    ax = gca;
    ax.FontSize = 10;
    ax.TickDir = "out";
    xlabel('Reaction Time (ms)',FontSize=10)
    legend('','Mean')
end




%% Reaction Time Graph Version 3

%for when sorting the entire RTs into quintile

% Initialize variables
masterRTs = zeros(); %preallocates vector for all RTs
RTsCell = [T.stimCorrectRTs]; % creates cell with all the RTs from master table for correct responses
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

%% Figures V2

[leftIdx,rightIdx] = getUnstimDprimes_abov_bel_mean(T); %change function depending on which you need

selection = listdlg('PromptString',{'Select variable of interest to make plot'},'ListString',T.Properties.VariableNames,'SelectionMode','single');

var = [T.(selection)];

%Divide var between above and below mean using the indices
% leftProfiles = [leftProfiles;var(leftIdx,:)];
% rightProfiles = [rightProfiles;var(rightIdx,:)];
comboIdx = [var(leftIdx);var(rightIdx)];

binrng = [min(var):max(var)];
counts = [];
for k = 1:size(comboIdx,1)
    counts(k,:) = histc(comboIdx(k,:), binrng);
end

%plot
figure;
bar(binrng,counts,'stacked')
grid


end

