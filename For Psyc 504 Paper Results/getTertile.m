function [firstTertile,secondTertile,thirdTertile] = getTertile(T)
%Splits RTs into tertile and takes the corresponding
%hit profiles and plot it. It then bootsraps each tertile and grabs the AOK for each tertile and create a plot
%of it

%% Initialize variables

%Go to folder with the master table
cd(uigetdir('', 'Choose folder containing master table'));

%load master table of interest
load(uigetfile('','Choose master table of interest'));

%init locations for profiles in each tertile
firstTertile= [];
secondTertile = [];
thirdTertile = [];

%% Create loop for getting hit profiles and putting them in each Tertile matrix

%loop through all sessions
for nSession = 1:height(T)
    
    %create variables for hit profiles and reaction times from the master
    %table
    RTs = cell2mat(T.stimCorrectRTs(nSession));
    hitPros = cell2mat(T.hitProfiles(nSession)); 
   
    %creates range for each tertile
    firstIdx = (RTs >= min(prctile(RTs,[0 33.33])) & RTs <= max(prctile(RTs,[0 33.33])));
    secondIdx = (RTs > min(prctile(RTs,[33.33 66.67])) & RTs <= max(prctile(RTs,[33.33 66.67])));
    thirdIdx = (RTs > min(prctile(RTs,[66.67 100])) & RTs <= max(prctile(RTs,[66.67 100])));

    %Grabs all trials in current session and appends them to the
    %appropriate matrix
    firstTertile = [firstTertile; hitPros(firstIdx,:)];
    secondTertile = [secondTertile; hitPros(secondIdx,:)];
    thirdTertile = [thirdTertile; hitPros(thirdIdx,:)];
end

% Correct the values since we aren't including the misses
firstTertile = firstTertile/2 + 0.5;
secondTertile = secondTertile/2 + 0.5;
thirdTertile = thirdTertile/2 + 0.5;

%% Filter SetUp

% Set Up Filter for Profiles
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

%% Bootstrap

% Compute 1st Tertile w/ SEM
bootfirst = bootstrp(1000,@mean,firstTertile);
firstPCs = prctile(bootfirst, [15.9, 50, 84.1]);              % +/- 1 SEM
firstPCMeans = mean(firstPCs, 2);
firstCIs = zeros(3, size(firstTertile, 2));
for c = 1:3
    firstCIs(c,:) = filtfilt(filterLP, firstPCs(c,:) - firstPCMeans(c)) + firstPCMeans(c);
end
firstx = 1:size(firstCIs, 2);
x2 = [firstx, fliplr(firstx)];
bins = size(firstCIs,2);

%2nd Tertile
bootsecond = bootstrp(1000,@mean,secondTertile);
secondPCs = prctile(bootsecond, [15.9, 50, 84.1]);              % +/- 1 SEM
secondPCMeans = mean(secondPCs, 2);
secondCIs = zeros(3, size(secondTertile, 2));
for c = 1:3
    secondCIs(c,:) = filtfilt(filterLP, secondPCs(c,:) - secondPCMeans(c)) + secondPCMeans(c);
end
secondx = 1:size(secondCIs, 2);

%3rd Tertile
bootthird = bootstrp(1000,@mean,thirdTertile);
thirdPCs = prctile(bootthird, [15.9, 50, 84.1]);              % +/- 1 SEM
thirdPCMeans = mean(thirdPCs, 2);
thirdCIs = zeros(3, size(thirdTertile, 2));
for c = 1:3
    thirdCIs(c,:) = filtfilt(filterLP, thirdPCs(c,:) - thirdPCMeans(c)) + thirdPCMeans(c);
end
thirdx = 1:size(thirdCIs, 2);



%% Get AOK

% Get Kernels for AOK
firstAOK_KDE = firstTertile(:,401:500)-0.5;
secondAOK_KDE = secondTertile(:,401:500)-0.5;
thirdAOK_KDE = thirdTertile(:,501:600)-0.5;
thirdAOK_KDE_two = thirdTertile(:,401:500)-0.5;

% Compute first AOK
bootfirst_AOK = bootstrp(100,@mean,firstAOK_KDE);
bootfirst_AOK = -(bootfirst_AOK); %makes values positive
firstAOK = sum(bootfirst_AOK,2);

%second AOK
bootsecond_AOK = bootstrp(100,@mean,secondAOK_KDE);
bootsecond_AOK = -(bootsecond_AOK);  %makes values positive
secondAOK = sum(bootsecond_AOK,2);

%third AOK
bootthird_AOK = bootstrp(100,@mean,thirdAOK_KDE);
bootthird_AOK = -(bootthird_AOK);  %makes values positive
thirdAOK = sum(bootthird_AOK,2);

%third AOK 2
bootthird_AOK_two = bootstrp(100,@mean,thirdAOK_KDE_two);
bootthird_AOK_two = -(bootthird_AOK_two);  %makes values positive
thirdAOK_two = sum(bootthird_AOK_two,2);


%% Plots

%create tiled layout for all plots
figure;
t= tiledlayout(3,2);
title(t,append('Reaction Time Kernels and AOK in ',input('Name of brain area and task type: ',"s"))) %change title as needed

% 1st Tertile
ax1 = nexttile;
hold on
plot(firstx, firstCIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
firstfillCI = [firstCIs(1, :), fliplr(firstCIs(3, :))]; % This sets up the fill for the errors
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
ax2 = nexttile(3);
hold on
plot(secondx, secondCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
secondfillCI = [secondCIs(1, :), fliplr(secondCIs(3, :))]; % This sets up the fill for the errors
fill(x2, secondfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
yline(0.5,'--k')
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
ax3 = nexttile(5);
hold on
plot(thirdx, thirdCIs(2, :), 'g', 'LineWidth', 1.5); % This plots the mean of the bootstrap
thirdfillCI = [thirdCIs(1, :), fliplr(thirdCIs(3, :))]; % This sets up the fill for the errors
fill(x2, thirdfillCI, 'g', 'lineStyle', '-', 'edgeColor', 'g', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill
yline(0.5,'--k')
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