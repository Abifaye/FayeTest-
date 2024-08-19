function getBootstraps_AOKs_hits_miss_separate
%% Summary

%inserts function for metric of interest to grab its bootstrap and AOK and
%plots them with hits and miss separated

%Go to folder containing master table
cd(uigetdir('', 'Choose folder containing master table'));
load(uigetfile('','Select desired master table'));

%go to folder containing the function
cd(uigetdir('', 'Choose folder containing getRate_abovBel_mean function'));

%% Define Variable
[leftIdx, rightIdx] =  getRate_abovBel_mean(T); %replace with function that grabs profiles for metric of interest

%Init matrices for profiles below (leftprofiles) and above (rightprofiles)
%mean
leftProfiles = gpuArray();
rightProfiles = gpuArray();

%init matrices for hit profiles for left and right of mean
hitsLeft = gpuArray();
hitsRight = gpuArray();
missLeft = gpuArray();
missRight = gpuArray();

% loop through all sessions
for nSession = 1:size(T,1)

    %Init Vars
    hitPros = [T.hitProfiles{nSession}];
    missPros = [T.missProfiles{nSession}];
    %comboPros = [hitPros;-missPros];
    sessHits = [T.hit{nSession}];
    sessMiss = [T.miss{nSession}];
    sessPower = [T.optoPowerMW{nSession}];
    sessLeftIdx = [leftIdx{nSession}];
    sessRightIdx = [rightIdx{nSession}];

    % filter each session so that only stimulated hits/misses trials are
    %included for further classification
    leftIdx_hits = sessLeftIdx(sessHits==1 & sessPower~=0);
    leftIdx_miss = sessLeftIdx(sessMiss==1 & sessPower~=0);
    %leftIdx_combo = [leftIdx_hits';lefttIdx_miss'];
    rightIdx_hits = sessRightIdx(sessHits==1 & sessPower~=0);
    rightIdx_miss = sessRightIdx(sessMiss==1 & sessPower~=0);
    %rightIdx_combo = [rightIdx_hits';rightIdx_miss'];

    %grab the miss+hits profiles corresponding to the indices
    % leftProfiles = [leftProfiles;comboPros(leftIdx_combo==1,:)];
    % rightProfiles = [rightProfiles;comboPros(rightIdx_combo==1,:)];
    hitsLeft = [hitsLeft; (hitPros(leftIdx_hits==1,:)/2)+0.5];
    hitsRight = [hitsRight; (hitPros(rightIdx_hits==1,:)/2)+0.5];
    missLeft = [missLeft; (missPros(leftIdx_miss==1,:)/2)+0.5];
    missRight = [missRight; (missPros(rightIdx_miss==1,:)/2)+0.5];


    % end
end


%% Kernel Bootstrap

% Filter SetUp
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

% Bootstrap

% Compute below mean w/ SEM

%miss
bootleft_miss = bootstrp(1000,@mean,missLeft);
bootleft_miss = gather(bootleft_miss);
leftPCs_miss = prctile(bootleft_miss, [15.9, 50, 84.1]); % +/- 1 SEM
leftPCMeans_miss = mean(leftPCs_miss, 2);
leftCIs_miss = zeros(3, size(missLeft, 2));
for c = 1:3
    leftCIs_miss(c,:) = filtfilt(filterLP, leftPCs_miss(c,:) - leftPCMeans_miss(c)) + leftPCMeans_miss(c);
end
leftx_miss = 1:size(leftCIs_miss, 2);
leftx2_miss = [leftx_miss, fliplr(leftx_miss)];
leftbins_miss = size(leftCIs_miss,2);

%hits
bootleft_hits = bootstrp(1000,@mean,hitsLeft);
bootleft_hits = gather(bootleft_hits);
leftPCs_hits = prctile(bootleft_hits, [15.9, 50, 84.1]); % +/- 1 SEM
leftPCMeans_hits = mean(leftPCs_hits, 2);
leftCIs_hits = zeros(3, size(hitsLeft, 2));
for c = 1:3
    leftCIs_hits(c,:) = filtfilt(filterLP, leftPCs_hits(c,:) - leftPCMeans_hits(c)) + leftPCMeans_hits(c);
end
leftx_hits = 1:size(leftCIs_hits, 2);
leftx2_hits = [leftx_hits, fliplr(leftx_hits)];
leftbins_hits = size(leftCIs_hits,2);

%above mean w/ SEM

%miss
bootright_miss = bootstrp(1000,@mean,missRight);
bootright_miss = gather(bootright_miss);
rightPCs_miss = prctile(bootright_miss, [15.9, 50, 84.1]); % +/- 1 SEM
rightPCMeans_miss = mean(rightPCs_miss, 2);
rightCIs_miss = zeros(3, size(missRight, 2));
for c = 1:3
    rightCIs_miss(c,:) = filtfilt(filterLP, rightPCs_miss(c,:) - rightPCMeans_miss(c)) + rightPCMeans_miss(c);
end
rightx_miss = 1:size(rightCIs_miss, 2);
rightx2_miss = [rightx_miss, fliplr(rightx_miss)];
rightbins_miss = size(rightCIs_miss,2);

%hits
bootright_hits = bootstrp(1000,@mean,hitsRight);
bootright_hits = gather(bootright_hits);
rightPCs_hits = prctile(bootright_hits, [15.9, 50, 84.1]); % +/- 1 SEM
rightPCMeans_hits = mean(rightPCs_hits, 2);
rightCIs_hits = zeros(3, size(hitsRight, 2));
for c = 1:3
    rightCIs_hits(c,:) = filtfilt(filterLP, rightPCs_hits(c,:) - rightPCMeans_hits(c)) + rightPCMeans_hits(c);
end
rightx_hits = 1:size(rightCIs_hits, 2);
rightx2_hits = [rightx_hits, fliplr(rightx_hits)];
rightbins_hits = size(rightCIs_hits,2);


%% 25 ms timebin bootstrap

analysisDurMS = 25; %The duration of significance test window
analysisStartBin = 26; %this is a rolling average centered on the test bin, we look backwards in time so we cant start on the first bin.
analysisEndBin   = 775; %Similarly we cant test past the end of the vector so when our rolling average gets near the end we stop

% How Many of Each Outcome Type for bootstrapping 
% left_nHit = size(hitsLeft,1); %how many hits
% left_ntotal = size(leftProfiles,1); %total of both hits and miss profiles for below mean
% right_nHit = size(hitsRight,1);
% right_total = size(rightProfiles,1);
left_nMiss = size(missLeft,1);
left_nHit = size(hitsLeft,1); 
right_nMiss = size(missRight,1);
right_nHit = size(hitsRight,1); 

% Bootstrap over each bin

%init number of boostraps desired
bootSamps = 1000;


% Init Archives For BootStrap Samples
leftBootsAOK_miss = gpuArray.zeros(bootSamps, 800);
leftBootsAOK_hits = gpuArray.zeros(bootSamps, 800);
rightBootsAOK_miss = gpuArray.zeros(bootSamps, 800);
rightBootsAOK_htis = gpuArray.zeros(bootSamps, 800);

% Bin to Start Computing AOK
lookBack = floor(analysisDurMS/2); %This puts the center of the rolling analysis window on the bin being tested
startBin = analysisStartBin-lookBack;  %note the difference between "analysisStartBin" and the "StartBin". startBin is set before the loop and then gets iterated with each loop to advance the window whereas analysisStartBin is set once to fix the beginning of the testing window.

for binNum = analysisStartBin:analysisEndBin
    for bootNum = 1:bootSamps
        % Samps For This Round of BootStrapping
        leftSamps_miss = randsample(left_nMiss,left_nMiss,true);
        leftSamps_hits = randsample(left_nHit,left_nHit,true);
        rightSamps_miss = randsample(right_nMiss,right_nMiss,true);
        rightSamps_hits = randsample(right_nHit,right_nHit,true);

        % Convert samples to gpuArray
        leftSamps_gpuMiss = gpuArray(leftSamps_miss);
        leftSamps_gpuHits = gpuArray(leftSamps_hits);
        rightSamps_gpuMiss = gpuArray(rightSamps_miss);
        rightSamps_gpuHits = gpuArray(rightSamps_hits);

        % Take Samples w/ replacement
        leftBoot_miss = missLeft(leftSamps_gpuMiss,:);
        leftBoot_hits = hitsLeft(leftSamps_gpuHits,:);
        rightBoot_miss = missRight(rightSamps_gpuMiss,:);
        rightBoot_hits = hitsRight(rightSamps_gpuHits,:);

        %bootstrapped AOK for each kernel
        leftBootsAOK_miss(bootNum,binNum) = sum(mean(0.5-leftBoot_miss(:,startBin:startBin+analysisDurMS-1)));
        leftBootsAOK_hits(bootNum,binNum) = sum(mean(0.5-leftBoot_hits(:,startBin:startBin+analysisDurMS-1)));
        rightBootsAOK_miss(bootNum,binNum) = sum(mean(0.5-rightBoot_miss(:,startBin:startBin+analysisDurMS-1)));
        rightBootsAOK_hits(bootNum,binNum) = sum(mean(0.5-rightBoot_hits(:,startBin:startBin+analysisDurMS-1)));


    end

    % Advance Start Bin
    startBin = startBin+1;

    %to track the iteration of boostraps
    disp(binNum)
end

% Gather results back to the CPU
leftBootsAOK_miss = gather(leftBootsAOK_miss);
leftBootsAOK_hits = gather(leftBootsAOK_hits);
rightBootsAOK_miss = gather(rightBootsAOK_miss);
rightBootsAOK_hits = gather(rightBootsAOK_hits);




% Find Bins with Significant AOK
p_leftMiss = zeros(1, 800);
p_leftHits = zeros(1, 800);
p_rightMiss = zeros(1, 800);
p_rightHits = zeros(1, 800);

for binNum = analysisStartBin:analysisEndBin
    p_leftMiss(1,binNum) = (size(leftBootsAOK_miss,1) - sum(leftBootsAOK_miss(:,binNum)<0))/size(leftBootsAOK_miss,1);
    p_leftHits(1,binNum) = (size(leftBootsAOK_hits,1) - sum(leftBootsAOK_hits(:,binNum)<0))/size(leftBootsAOK_hits,1);
    p_rightMiss(1,binNum) = (size(rightBootsAOK_miss,1) - sum(rightBootsAOK_miss(:,binNum)<0))/size(rightBootsAOK_miss,1);
    p_rightHits(1,binNum) = (size(rightBootsAOK_hits,1) - sum(rightBootsAOK_hits(:,binNum)<0))/size(rightBootsAOK_hits,1);
end


%% Plots

%create tiled layout for all plots
figure;
t = tiledlayout(4,1);
title(t,append(input('Name of metric of interest: ',"s"),' Kernels and AOK in ',input('Name of brain area and task type: ',"s")))

%below mean

%miss
ax1 = nexttile;
hold on
plot(leftx_miss, leftCIs_miss(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
leftfillCI_miss = [leftCIs_miss(1, :), fliplr(leftCIs_miss(3, :))]; % This sets up the fill for the errors
fill(leftx2_miss, leftfillCI_miss, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
yline(0.5,'--k')
for nBin = 1:800
    if p_leftMiss(nBin)==1
        scatter(nBin,0.529,'_','r')
    end
end
hold off
ax = gca;
xlim(ax, [0, leftbins_miss]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
%ylim(ay, [0.4 0.6]);
ay.FontSize = 8;
title('Kernel of Below Mean Miss Profiles','FontSize',8);

%hits
ax1 = nexttile;
hold on
plot(leftx_hits, leftCIs_hits(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
leftfillCI_hits = [leftCIs_hits(1, :), fliplr(leftCIs_hits(3, :))]; % This sets up the fill for the errors
fill(leftx2_hits, leftfillCI_hits, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
yline(0.5,'--k')
for nBin = 1:800
    if p_leftHits(nBin)==1
        scatter(nBin,0.529,'_','r')
    end
end
hold off
ax = gca;
xlim(ax, [0, leftbins_hits]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
%ylim(ay, [0.4 0.6]);
ay.FontSize = 8;
title('Kernel of Below Mean Hits Profiles','FontSize',8);


%above mean

%miss
ax2 = nexttile;
hold on
plot(rightx_miss, rightCIs_miss(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
rightfillCI_miss = [rightCIs_miss(1, :), fliplr(rightCIs_miss(3, :))]; % This sets up the fill for the errors
fill(rightx2_miss, rightfillCI_miss, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
yline(0.5,'--k')
for nBin = 1:800
    if p_rightMiss(nBin)==1
        scatter(nBin,0.529,'_','r')
    end
end
hold off
ax = gca;
xlim(ax, [0, rightbins_miss]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
%ylim(ay, [0.4 0.6]);
ay.FontSize = 8;
title('Kernel of Above Mean Miss Profiles','FontSize',8);

%Axes Label
xlabel([ax1 ax2],'Time Relative to Stimulus Onset (ms)','FontSize',8)
ylabel([ax1 ax2],'Normalized Power','FontSize',8)

%hits
ax2 = nexttile;
hold on
plot(rightx_hits, rightCIs_hits(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
rightfillCI_hits = [rightCIs_hits(1, :), fliplr(rightCIs_hits(3, :))]; % This sets up the fill for the errors
fill(rightx2_hits, rightfillCI_hits, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
yline(0.5,'--k')
for nBin = 1:800
    if p_rightHits(nBin)==1
        scatter(nBin,0.529,'_','r')
    end
end
hold off
ax = gca;
xlim(ax, [0, rightbins_hits]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
%ylim(ay, [0.4 0.6]);
ay.FontSize = 8;
title('Kernel of Above Mean Hits Profiles','FontSize',8);

%Axes Label
xlabel([ax1 ax2],'Time Relative to Stimulus Onset (ms)','FontSize',8)
ylabel([ax1 ax2],'Normalized Power','FontSize',8)





end