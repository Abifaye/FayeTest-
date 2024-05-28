function getquintile
    function [firstQuintile,secondQuintile,thirdQuintile] = getTertile(T)
%Splits RTs into tertile and takes the corresponding
%hit profiles and plot it. It then bootsraps each tertile and grabs the AOK for each tertile and create a plot
%of it

%% Initialize variables

%Go to folder with the master table
cd(uigetdir('', 'Choose folder containing master table'));

%load master table of interest
load(uigetfile('','Choose master table of interest'));

%init locations for profiles in each tertile
firstQuintile= [];
secondQuintile = [];
thirdQuintile = [];
fourthQuintile =[];
fifthQuintile = [];

%% Create loop for getting hit profiles and putting them in each Tertile matrix

%loop through all sessions
for nSession = 1:height(T)
    
    %create variables for hit profiles and reaction times from the master
    %table
    RTs = cell2mat(T.stimCorrectRTs(nSession));
    hitPros = cell2mat(T.hitProfiles(nSession)); 
   
    %creates range for each tertile
    firstIdx = (RTs >= min(prctile(RTs,[0 20])) & RTs <= max(prctile(RTs,[0 20])));
    secondIdx = (RTs > min(prctile(RTs,[20 40])) & RTs <= max(prctile(RTs,[20 40])));
    thirdIdx = (RTs > min(prctile(RTs,[40 60])) & RTs <= max(prctile(RTs,[40 60])));
    fourthIdx = (RTs > min(prctile(RTs,[60 80])) & RTs <= max(prctile(RTs,[60 80])));
    fifthIdx = (RTs > min(prctile(RTs,[80 100])) & RTs <= max(prctile(RTs,[80 100])));

    %Grabs all trials in current session and appends them to the
    %appropriate matrix
    firstQuintile = [firstQuintile; hitPros(firstIdx,:)];
    secondQuintile = [secondQuintile; hitPros(secondIdx,:)];
    thirdQuintile = [thirdQuintile; hitPros(thirdIdx,:)];
    fourthQuintile = [fourthQuintile; hitPros(fourthIdx,:)];
    fifthQuintile = [fifthQuintile; hitPros(fifthIdx,:)];
end

% Correct the values since we aren't including the misses
firstQuintile = firstQuintile/2 + 0.5;
secondQuintile = secondQuintile/2 + 0.5;
thirdQuintile = thirdQuintile/2 + 0.5;
fourthQuintile = fourthQuintile/2 + 0.5;
fifthQuintile = fifthQuintile/2 + 0.5;

quintStruct = struct('firstQuint',firstQuintile, 'secondQuint', secondQuintile, 'thirdQuint', thirdQuintile, 'fourthQuint', fourthQuintile, 'fifthQuint', fifthQuintile);
quintFields = fieldnames(quintStruct);
%% Kernel Bootstrap

% Filter SetUp

% Set Up Filter for Profiles
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

% Compute quintiles w/ SEM

%init vars for loop
CIsCell = {};
x = [];
x2 = [];
bins = [];

%loop through each quintile in the struct
for nQuint = 1:length(quintFields)
boot = bootstrp(100,@mean,quintStruct.(string(quintFields(nQuint))));
PCs = prctile(boot, [15.9, 50, 84.1]); % +/- 1 SEM
PCMeans = mean(PCs, 2);
CIs = zeros(3, size(quintStruct.(string(quintFields(nQuint))), 2));
for c = 1:3
    CIs(c,:) = filtfilt(filterLP, PCs(c,:) - PCMeans(c)) + PCMeans(c);
end

x(nQuint,:) = 1:size(CIs, 2);
x2(nQuint,:) = [x, fliplr(x)];
bins(nQuint) = size(CIs,2);
CIsCell{nQuint} = CIs;

end


%% Plots

%create tiled layout for all plots
figure;
t= tiledlayout(3,1);
title(t,append('Reaction Time Kernels and AOK in ',input('Name of brain area and task type: ',"s"))) %change title as needed

% 1st Tertile
ax1 = nexttile;
hold on
plot(x, CIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
firstfillCI = [CIs(1, :), fliplr(CIs(3, :))]; % This sets up the fill for the errors
fill(x2, firstfillCI, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill
yline(0.5,'--k')
hold off
title('First Tertile','FontSize',8);
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '', '0', '', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [0.47 0.52]);
ay.FontSize = 8; 

% 2nd Tertile
ax2 = nexttile;
hold on
plot(secondx, secondCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
secondfillCI = [secondCIs(1, :), fliplr(secondCIs(3, :))]; % This sets up the fill for the errors
fill(x2, secondfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
yline(0.5,'--k')
for nBin = 1:800
    if p_second(nBin)==1
        scatter(nBin,0.02,'_','r')
    end
end
hold off
title('Second Tertile','FontSize',8);
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '', '0', '', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [0.47 0.52]);
ay.FontSize = 8; 


% 3rd Tertile
ax3 = nexttile;
hold on
plot(thirdx, thirdCIs(2, :), 'g', 'LineWidth', 1.5); % This plots the mean of the bootstrap
thirdfillCI = [thirdCIs(1, :), fliplr(thirdCIs(3, :))]; % This sets up the fill for the errors
fill(x2, thirdfillCI, 'g', 'lineStyle', '-', 'edgeColor', 'g', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill
yline(0.5,'--k')
for nBin = 1:800
    if p_third(nBin)==1
        scatter(nBin,0.02,'_','r')
    end
end
hold off
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
title('Third Tertile','FontSize',8);
ax.XTickLabel = {'-400', '', '0', '', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [0.47 0.52]);
ay.FontSize = 8; 


%Axes Label
xlabel([ax3],'Time(ms)','FontSize',8)
ylabel([ax2],'Normalized Power','FontSize',8) 

%AOK
if aokChoice==1
%1st
nexttile;
histogram(firstAOK,'Normalization','probability',FaceColor="b")
xline(0,'--k')
title('AoK of First Tertile','FontSize',8);
ay = gca;
ylim(ay, [0 0.4]); 
ay.FontSize = 8;
ylabel('Probability','FontSize',8)
ax = gca;
xlim(ax, [-2, 2]);
ax.XTick = [-2:0.5:2];
ax.XTickLabel = {'-2', '', '-1', '', '0', '', '1', '', '2'};
ax.FontSize = 8;
ax.TickDir = "out";
xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)


%2nd
nexttile; 
histogram(secondAOK,'Normalization','probability',FaceColor="r")
xline(0,'--k')
title('AoK of Second Tertile','FontSize',8);
ay = gca;
ylim(ay, [0 0.4]);
ay.FontSize = 8;
ylabel('Probability','FontSize',8)
ax = gca;
xlim(ax, [-2, 2]);
ax.XTick = [-2:0.5:2];
ax.XTickLabel = {'-2', '', '-1', '', '0', '', '1', '', '2'};
ax.FontSize = 8;
ax.TickDir = "out";
xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)

%3rd
nexttile;
histogram (thirdAOK,'Normalization','probability',FaceColor="g")
xline(0,'--k')
title('AoK of Third Tertile','FontSize',8);
ay = gca;
ylim(ay, [0 0.4]);
ay.FontSize = 8;
ylabel('Probability','FontSize',8)
ax = gca;
xlim(ax, [-2, 2]);
ax.XTick = [-2:0.5:2];
ax.XTickLabel = {'-2', '', '-1', '', '0', '', '1', '', '2'};
ax.FontSize = 8;
ax.TickDir = "out";
xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)

%3rd tertile 0-100ms vs 100-200ms

%tiled layout
figure;
t= tiledlayout(2,1);
title(t,'AOK of 3rd Tertile: 0-100ms vs 100-200ms')

%0 - 100 ms
nexttile;
histogram (thirdAOK_two,'Normalization','probability',FaceColor="#77AC30")
xline(0,':k')
title('AoK of Third Tertile from 0-100 ms','FontSize',8);
ay = gca;
ylim(ay, [0 0.4]);
ay.FontSize = 8;
ylabel('Probability','FontSize',8)
ax = gca;
xlim(ax, [-2, 2]);
ax.XTick = [-2:0.5:2];
ax.XTickLabel = {'-2', '', '-1', '', '0', '', '1', '', '2'};
ax.FontSize = 7;
ax.TickDir = "out";
xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)

%100-200 ms
nexttile;
histogram (thirdAOK,'Normalization','probability',FaceColor="g")
xline(0,':k')
title('AoK of Third Tertile from 100-200 ms','FontSize',8);
ay = gca;
ylim(ay, [0 0.4]);
ay.FontSize = 8;
ylabel('Probability','FontSize',8)
ax = gca;
xlim(ax, [-2, 2]);
ax.XTick = [-2:0.5:2];
ax.XTickLabel = {'-2', '', '-1', '', '0', '', '1', '', '2'};
ax.FontSize = 7;
ax.TickDir = "out";
xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)
end

end
end