function getbootstraps_AOKs
%% Summary
%inserts function for metric of interest to grab its bootstrap and AOK and
%plots them

%Go to folder containing master table
cd(uigetdir('', 'Choose folder containing master table'));
load(uigetfile('','Select desired master table'));

%% Define Variable
[leftIdx, rightIdx] =  getRate_abovBel_mean(T); %replace with function that grabs profiles for metric of interest

%Init matrices for profiles below (leftprofiles) and above (rightprofiles)
%mean
leftProfiles = gpuArray();
rightProfiles = gpuArray();
%init matrices for hit profiles for left and right of mean
hitsLeft = gpuArray();
hitsRight = gpuArray();

%Choose whether to run code for indices that are sessional or for indices
%that goes through each trial
chooseLoop = input('Indices are by sessions or trials? [1=sessions/2=trials]: ');

if chooseLoop==1 %by session
    % loop through all sessions
    for nSession = 1:height(T)
        %get all hit & miss profiles from session
        hitPros = gpuArray(cell2mat(T.hitProfiles(nSession)));
        missPros = gpuArray(cell2mat(T.missProfiles(nSession)));
        comboPros = gpuArray([hitPros;-missPros]);
        %determine if delta_d of session is above or below mean and place in
        %appropriate matrix
        if leftIdx(nSession) == 1
            leftProfiles = [leftProfiles;comboPros(:,:)];
            hitsLeft = [hitsLeft;hitPros(:,:)];
        elseif rightIdx(nSession) == 1
            rightProfiles = [rightProfiles;comboPros(:,:)];
            hitsRight = [hitsRight;hitPros(:,:)];
        end

    end

elseif chooseLoop==2 %by trials
    % loop through all sessions
    for nSession = 1:size(T,1)

        %Init Vars
        hitPros = [T.hitProfiles{nSession}];
        missPros = [T.missProfiles{nSession}];
        comboPros = [hitPros;-missPros];
        sessHits = [T.hit{nSession}];
        sessMiss = [T.miss{nSession}];
        sessPower = [T.optoPowerMW{nSession}];
        sessLeftIdx = [leftIdx{nSession}];
        sessRightIdx = [rightIdx{nSession}];

        % filter each session so that only stimulated hits/misses trials are
        %included for further classification
        leftIdx_hits = sessLeftIdx(sessHits==1 & sessPower~=0);
        lefttIdx_miss = sessLeftIdx(sessMiss==1 & sessPower~=0);
        leftIdx_combo = [leftIdx_hits';lefttIdx_miss'];
        rightIdx_hits = sessRightIdx(sessHits==1 & sessPower~=0);
        rightIdx_miss = sessRightIdx(sessMiss==1 & sessPower~=0);
        rightIdx_combo = [rightIdx_hits';rightIdx_miss'];

        %grab the miss+hits profiles and hit outcomes corresponding to the indices
        leftProfiles = [leftProfiles;comboPros(leftIdx_combo==1,:)];
        rightProfiles = [rightProfiles;comboPros(rightIdx_combo==1,:)];
        hitsLeft = [hitsLeft; hitPros(leftIdx_hits==1,:)];
        hitsRight = [hitsRight; hitPros(rightIdx_hits==1,:)];

    end
end


%% Kernel Bootstrap

% Filter SetUp
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

% Bootstrap

% Compute below mean w/ SEM
bootleft_AOK = bootstrp(1000,@mean,leftProfiles);
bootleft_AOK = gather(bootleft_AOK);
leftPCs = prctile(bootleft_AOK, [15.9, 50, 84.1]); % +/- 1 SEM
leftPCMeans = mean(leftPCs, 2);
leftCIs = zeros(3, size(leftProfiles, 2));
for c = 1:3
    leftCIs(c,:) = filtfilt(filterLP, leftPCs(c,:) - leftPCMeans(c)) + leftPCMeans(c);
end
leftx = 1:size(leftCIs, 2);
leftx2 = [leftx, fliplr(leftx)];
leftbins = size(leftCIs,2);

%above mean w/ SEM
bootright_AOK = bootstrp(1000,@mean,rightProfiles);
bootright_AOK = gather(bootright_AOK);
rightPCs = prctile(bootright_AOK, [15.9, 50, 84.1]); % +/- 1 SEM
rightPCMeans = mean(rightPCs, 2);
rightCIs = zeros(3, size(rightProfiles, 2));
for c = 1:3
    rightCIs(c,:) = filtfilt(filterLP, rightPCs(c,:) - rightPCMeans(c)) + rightPCMeans(c);
end
rightx = 1:size(rightCIs, 2);
rightx2 = [rightx, fliplr(rightx)];
rightbins = size(rightCIs,2);

%% 25 ms timebin bootstrap

analysisDurMS = 25; %The duration of significance test window
analysisStartBin = 26; %this is a rolling average centered on the test bin, we look backwards in time so we cant start on the first bin.
analysisEndBin   = 775; %Similarly we cant test past the end of the vector so when our rolling average gets near the end we stop

% How Many of Each Outcome Type to control bootstrapping to match
% experimental proportions
left_nHit = size(hitsLeft,1); %how many hits
left_total = size(leftProfiles,1); %total of both hits and miss profiles for below mean
right_nHit = size(hitsRight,1);
right_total = size(rightProfiles,1);

% Bootstrap over each bin

%init number of boostraps desired
bootSamps = 1000;


% Init Archives For BootStrap Samples
leftBootsAOK = gpuArray.zeros(bootSamps, 800);
rightBootsAOK = gpuArray.zeros(bootSamps, 800);

% Bin to Start Computing AOK
lookBack = floor(analysisDurMS/2); %This puts the center of the rolling analysis window on the bin being tested
startBin = analysisStartBin-lookBack;  %note the difference between "analysisStartBin" and the "StartBin". startBin is set before the loop and then gets iterated with each loop to advance the window whereas analysisStartBin is set once to fix the beginning of the testing window.

for binNum = analysisStartBin:analysisEndBin
    for bootNum = 1:bootSamps
        % Samps For This Round of BootStrapping
        leftSamps = [randsample(left_nHit,left_nHit,true)'...
            randsample([left_nHit+1:left_total],left_total-left_nHit,true)]';
        rightSamps = [randsample(right_nHit,right_nHit,true)'...
            randsample([right_nHit+1:right_total],right_total-right_nHit,true)]';
         
        % Convert samples to gpuArray
        leftSamps_gpu = gpuArray(leftSamps);
        rightSamps_gpu = gpuArray(rightSamps);

        % Take Samples w/ replacement
        leftBoot = leftProfiles(leftSamps_gpu,:);
        rightBoot = rightProfiles(rightSamps_gpu,:);

        %bootstrapped AOK for each kernel
        leftBootsAOK(bootNum,binNum) = sum(mean(-1*leftBoot(:,startBin:startBin+analysisDurMS-1)));
        rightBootsAOK(bootNum,binNum) = sum(mean(-1*rightBoot(:,startBin:startBin+analysisDurMS-1)));


    end

    % Advance Start Bin
    startBin = startBin+1;

    %to track the iteration of boostraps
    disp(binNum)
end

% Gather results back to the CPU
leftBootsAOK = gather(leftBootsAOK);
rightBootsAOK = gather(rightBootsAOK);



% Find Bins with Significant AOK
p_left = zeros(1, 800);
p_right = zeros(1, 800);

for binNum = analysisStartBin:analysisEndBin
    p_left(1,binNum) = (size(leftBootsAOK,1) - sum(leftBootsAOK(:,binNum)<0))/size(leftBootsAOK,1);
    p_right(1,binNum) = (size(rightBootsAOK,1) - sum(rightBootsAOK(:,binNum)<0))/size(rightBootsAOK,1);
end


%% Get AOK
% aokChoice = input('Get AOK? [1=Yes/0=No]: ');
% if aokChoice==1
% 
% % Get Kernels for AOK
% leftAOK_KDE = leftProfiles(:,401:500);
% rightAOK_KDE = rightProfiles(:,401:500);
% 
% % Compute left AOK
% bootleft_AOK = bootstrp(3,@mean,leftAOK_KDE);
% bootleft_AOK = -(bootleft_AOK); %makes values positive
% leftAOK = sum(bootleft_AOK,2);
% 
% %right AOK
% bootright_AOK = bootstrp(3,@mean,rightAOK_KDE);
% bootright_AOK = -(bootright_AOK); %makes values positive
% rightAOK = sum(bootright_AOK,2);
% 
% end

%% Plots

%create tiled layout for all plots
figure;
t = tiledlayout(2,1);
title(t,append(input('Name of metric of interest: ',"s"),' Kernels and AOK in ',input('Name of brain area and task type: ',"s")))

%below mean
ax1 = nexttile;
hold on
plot(leftx, leftCIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
leftfillCI = [leftCIs(1, :), fliplr(leftCIs(3, :))]; % This sets up the fill for the errors
fill(leftx2, leftfillCI, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
yline(0,'--k')
for nBin = 1:800
    if p_left(nBin)==1
        scatter(nBin,0.019,'_','r')
    end
end
hold off
ax = gca;
xlim(ax, [0, leftbins]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [-0.04 0.02]);
ay.FontSize = 8;
title('Kernel of Below Mean Profiles','FontSize',8);

%above mean
ax2 = nexttile;
hold on
plot(rightx, rightCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
rightfillCI = [rightCIs(1, :), fliplr(rightCIs(3, :))]; % This sets up the fill for the errors
fill(rightx2, rightfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
yline(0,'--k')
for nBin = 1:800
    if p_right(nBin)==1
        scatter(nBin,0.019,'_','r')
    end
end
hold off
ax = gca;
xlim(ax, [0, rightbins]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [-0.04 0.02]);
ay.FontSize = 8;
title('Kernel of Above Mean Profiles','FontSize',8);

%Axes Label
xlabel([ax1 ax2],'Time Relative to Stimulus Onset (ms)','FontSize',8)
ylabel([ax1 ax2],'Normalized Power','FontSize',8)


% %AOK
% if aokChoice==1
% %Left
% nexttile;
% hold on
% histogram(leftAOK,'Normalization','probability',FaceColor="b")
% xline(0,'--k')
% hold off
% title('AOK of Below Mean Profiles','FontSize',8);
% ay = gca;
% ylim(ay, [0 0.4]); %adjust to correct limits
% ay.FontSize = 8;
% ylabel('Probability','FontSize',8)
% ax = gca;
% xlim(ax, [-4, 4]);
% ax.XTick = [-4:1:4];
% ax.XTickLabel = {'-4', '', '-2', '', '0', '', '2', '', '4'};
% ax.FontSize = 7;
% ax.TickDir = "out";
% xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)
% 
% %Right
% nexttile;
% hold on
% histogram (rightAOK,'Normalization','probability',FaceColor="r")
% xline(0,'--k')
% hold off
% title('AOK of Above Mean Profiles','FontSize',8);
% ay = gca;
% ylim(ay, [0 0.4]); %adjust to  correct limits
% ay.FontSize = 8;
% ylabel('Probability',FontSize=8)
% ax = gca;
% xlim(ax, [-4, 4]);
% ax.XTick = [-4:1:4];
% ax.XTickLabel = {'-4', '', '-2', '', '0', '', '2', '', '4'};
% ax.FontSize = 7;
% ax.TickDir = "out";
% xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)
% 
% end

end