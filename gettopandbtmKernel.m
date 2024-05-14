function [comboTopHalf,comboBtmHalf] = gettopandbtmKernel
%Summary: Splits the top and bottom half of the trial profiles in each session and generates
%kernel for each half

%% Classifying the Profiles
%load the master table of interest
load(uigetfile('', 'Choose the master table of interest'))

%Loop through each session
for nSession = 1:size(T,1)
    %Hits Profles

    %init vars
    totTrials = [];
    endtopHalf = [];
    startbtmHalf = [];
    sessionPros = [];

    sessionPros = cell2mat(T.hitProfiles(nSession)); %all profiles inn current session
    totTrials = size(sessionPros,1); %total number of trials in the session
    endtopHalf = floor(totTrials/2); %the last trial in the top half 
    startbtmHalf = floor(totTrials/2)+1; %first trial in the bottom half

    %allocate profiles into a cell based on top or bottom half label
    firstHalfHits{nSession} = sessionPros(1:endtopHalf,:);
    secondHalfHits{nSession} = sessionPros(startbtmHalf:totTrials,:);

    %Miss Profiles

    %re-init vars
    totTrials = [];
    endtopHalf = [];
    startbtmHalf = [];
    sessionPros = [];

    sessionPros = cell2mat(T.missProfiles(nSession));
    totTrials = size(sessionPros,1);
    endtopHalf = floor(totTrials/2);
    startbtmHalf = floor(totTrials/2)+1;

    firstHalfmisses{nSession} = sessionPros(1:endtopHalf,:);
    secondHalfmisses{nSession} = sessionPros(startbtmHalf:totTrials,:);
end

% combine both  halves of the hits and inverse misses 
comboTopHalf = [cell2mat(firstHalfHits'); -cell2mat(firstHalfmisses')]; %top halves
comboBtmHalf = [cell2mat(secondHalfHits'); -cell2mat(secondHalfmisses')]; %bottom halves

%% Plotting Kernel

%bootstrap

% Filter SetUp
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

% Bootstrap

% Compute top profiles w/ SEM
bootTop = bootstrp(1000,@mean,comboTopHalf);
topPCs = prctile(bootTop, [15.9, 50, 84.1]); % +/- 1 SEM
topPCMeans = mean(topPCs, 2);
topCIs = zeros(3, size(comboTopHalf, 2));
for c = 1:3
    topCIs(c,:) = filtfilt(filterLP, topPCs(c,:) - topPCMeans(c)) + topPCMeans(c);
end
topx = 1:size(topCIs, 2);
topx2 = [topx, fliplr(topx)];
topbins = size(topCIs,2);

%compute bottom profiles w/ SEM
bootBtm = bootstrp(1000,@mean,comboBtmHalf);
btmPCs = prctile(bootBtm, [15.9, 50, 84.1]); % +/- 1 SEM
btmPCMeans = mean(btmPCs, 2);
btmCIs = zeros(3, size(comboBtmHalf, 2));
for c = 1:3
    btmCIs(c,:) = filtfilt(filterLP, btmPCs(c,:) - btmPCMeans(c)) + btmPCMeans(c);
end
btmx = 1:size(btmCIs, 2);
btmx2 = [btmx, fliplr(btmx)];
btmbins = size(btmCIs,2);

% Kernel Plots

%create tiled layout for all plots
figure;
t= tiledlayout(2,1);
title(t,append('Top and Bottom Half ', 'Kernels in ', input('Name of brain area and task type: ',"s")))

%below mean
ax1 = nexttile;
hold on
plot(topCIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
topfillCI = [topCIs(1, :), fliplr(topCIs(3, :))]; % This sets up the fill for the errors
fill(topx2, topfillCI, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
yline(0,'--k')
hold off
ax = gca;
xlim(ax, [0, topbins]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [-0.04 0.02]);
ay.FontSize = 8;
title('Kernel of Top Half Profiles','FontSize',8);

%above mean
ax2 = nexttile;
hold on
plot(btmx, btmCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
btmfillCI = [btmCIs(1, :), fliplr(btmCIs(3, :))]; % This sets up the fill for the errors
fill(btmx2, btmfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); %add fill
yline(0,'--k')
hold off
ax = gca;
xlim(ax, [0, btmbins]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [-0.04 0.02]);
ay.FontSize = 8;
title('Kernel of Bottom Half Profiles','FontSize',8); 

%Axes Label
xlabel([ax1 ax2],'Time Relative to Stimulus Onset (ms)','FontSize',8)
ylabel([ax1 ax2],'Normalized Power','FontSize',8) 


end