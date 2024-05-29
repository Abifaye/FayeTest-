function [firstTertile,secondTertile,thirdTertile] = getTertile(T)
%Splits RTs into tertile and takes the corresponding
%hit profiles and plot it. It then bootsraps each tertile and grabs the AOK for each tertile and create a plot
%of it

    %% Initialize variables
    
    %Go to folder with the master table
    cd(uigetdir('', 'Choose folder containing master table'));
    
    %load master table of interest
    load(uigetfile('','Choose master table of interest'));
    
    %locations for profiles in each tertile
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
    firstTertile_fixed = firstTertile/2 + 0.5;
    secondTertile_fixed = secondTertile/2 + 0.5;
    thirdTertile_fixed = thirdTertile/2 + 0.5;
    
    %% kernel bootstrap
    
    % Filter SetUp
    
    % Set Up Filter for Profiles
    sampleFreqHz = 1000;
    filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
        'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
        'DesignMethod','equiripple');
    
    % Compute 1st Tertile w/ SEM
    bootfirst = bootstrp(1000,@mean,firstTertile_fixed);
    firstPCs = prctile(bootfirst, [15.9, 50, 84.1]);              % +/- 1 SEM
    firstPCMeans = mean(firstPCs, 2);
    firstCIs = zeros(3, size(firstTertile_fixed, 2));
    for c = 1:3
        firstCIs(c,:) = filtfilt(filterLP, firstPCs(c,:) - firstPCMeans(c)) + firstPCMeans(c);
    end
    firstx = 1:size(firstCIs, 2);
    x2 = [firstx, fliplr(firstx)];
    bins = size(firstCIs,2);
    
    %2nd Tertile
    bootsecond = bootstrp(1000,@mean,secondTertile_fixed);
    secondPCs = prctile(bootsecond, [15.9, 50, 84.1]);              % +/- 1 SEM
    secondPCMeans = mean(secondPCs, 2);
    secondCIs = zeros(3, size(secondTertile_fixed, 2));
    for c = 1:3
        secondCIs(c,:) = filtfilt(filterLP, secondPCs(c,:) - secondPCMeans(c)) + secondPCMeans(c);
    end
    secondx = 1:size(secondCIs, 2);
    
    %3rd Tertile
    bootthird = bootstrp(1000,@mean,thirdTertile_fixed);
    thirdPCs = prctile(bootthird, [15.9, 50, 84.1]);              % +/- 1 SEM
    thirdPCMeans = mean(thirdPCs, 2);
    thirdCIs = zeros(3, size(thirdTertile_fixed, 2));
    for c = 1:3
        thirdCIs(c,:) = filtfilt(filterLP, thirdPCs(c,:) - thirdPCMeans(c)) + thirdPCMeans(c);
    end
    thirdx = 1:size(thirdCIs, 2);   
    
    %% 25 ms timebin boostrap
    analysisDurMS    = 25; %The duration of significance test window

    analysisStartBin = 26; %this is a rolling average centered on the test bin, we look backwards in time so we can%t start on the first bin.
     
    analysisEndBin   = 775; %Similarly we can%t test past the end of the vector so when our rolling average gets near the end we stop
    
    % How Many of Each Outcome Type to control bootstrapping to match
    % experimental proportions
    first_nHit = size(firstTertile,1);
    second_nHit = size(secondTertile,1);
    third_nHit = size(thirdTertile,1);
    
    % Bootstrap over each bin
    
    %init number of boostraps desired
    bootSamps = 1000;
    
    %convert tertiles into gpuArray for accelerated processing
    firstTertile_gpu = gpuArray(firstTertile);
    secondTertile_gpu = gpuArray(secondTertile);
    thirdTertile_gpu = gpuArray(thirdTertile);
    
    % How Many of Each Outcome Type to control bootstrapping to match
    % experimental proportions
    first_nHit = size(firstTertile,1);
    second_nHit = size(secondTertile,1);
    third_nHit = size(thirdTertile,1);
    
    % Bootstrap over each bin
    
    % preallocate archives For BootStrap Samples on the GPU
    firstBootsAOK_gpu =  gpuArray.zeros(bootSamps, 800);
    secondBootsAOK_gpu =  gpuArray.zeros(bootSamps, 800);
    thirdBootsAOK_gpu =  gpuArray.zeros(bootSamps, 800);
     
    % Bin to Start Computing AOK
    lookBack = floor(analysisDurMS/2); %This puts the center of the rolling analysis window on the bin being tested  
    startBin = analysisStartBin-lookBack;  %note the difference between "analysisStartBin" and the "StartBin". startBin is set before the loop and then gets iterated with each loop to advance the window whereas analysisStartBin is set once to fix the beginning of the testing window.
     
    for binNum = analysisStartBin:analysisEndBin
        for bootNum = 1:bootSamps
            % Samps For This Round of BootStrapping
            firstSamps = [randsample(first_nHit,first_nHit,true)]';
            secondSamps = [randsample(second_nHit,second_nHit,true)]';
            thirdSamps = [randsample(third_nHit,third_nHit,true)]';
    
            % Convert samples to gpuArray
            firstSamps_gpu = gpuArray(firstSamps);
            secondSamps_gpu = gpuArray(secondSamps);
            thirdSamps_gpu = gpuArray(thirdSamps);
    
            % Select bootstrap samples
            firstBoot = firstTertile_gpu(firstSamps_gpu, :);
            secondBoot = secondTertile_gpu(secondSamps_gpu, :);
            thirdBoot = thirdTertile_gpu(thirdSamps_gpu, :);
    
            %bootstrapped AOK for each kernel
            firstBootsAOK_gpu(bootNum, binNum) = sum(mean(-1 * firstBoot(:, startBin:startBin + analysisDurMS - 1)));
            secondBootsAOK_gpu(bootNum, binNum) = sum(mean(-1 * secondBoot(:, startBin:startBin + analysisDurMS - 1)));
            thirdBootsAOK_gpu(bootNum, binNum) = sum(mean(-1 * thirdBoot(:, startBin:startBin + analysisDurMS - 1)));
        end
    
        % Advance Start Bin
        startBin = startBin+1;
    
        %to track the iteration of boostraps
        disp(binNum)
    
    end
    
    % Gather results back to the CPU
    firstBootsAOK = gather(firstBootsAOK_gpu);
    secondBootsAOK = gather(secondBootsAOK_gpu);
    thirdBootsAOK = gather(thirdBootsAOK_gpu);
     
    % Find Bins with Significant AOK
    p_first = zeros(1, 800);
    p_second = zeros(1, 800);
    p_third = zeros(1, 800);
     
    for binNum = analysisStartBin:analysisEndBin
        p_first(1,binNum) = (size(firstBootsAOK,1) - sum(firstBootsAOK(:,binNum)<0))/size(firstBootsAOK,1);
        p_second(1,binNum) = (size(secondBootsAOK,1) - sum(secondBootsAOK(:,binNum)<0))/size(secondBootsAOK,1);
        p_third(1,binNum) = (size(thirdBootsAOK,1) - sum(thirdBootsAOK(:,binNum)<0))/size(thirdBootsAOK,1);
    end


%% Get AOK
aokChoice = input('Get AOK? [1=Yes/0=No]: ');
if aokChoice==1
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
end


%% Plots

%create tiled layout for all plots
figure;
t= tiledlayout(3,1);
title(t,append('Reaction Time Kernels and AOK in ',input('Name of brain area and task type: ',"s"))) %change title as needed

% 1st Tertile
ax1 = nexttile;
hold on
plot(firstx, firstCIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
firstfillCI = [firstCIs(1, :), fliplr(firstCIs(3, :))]; % This sets up the fill for the errors
fill(x2, firstfillCI, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill
yline(0.5,'--k')
for nBin = 1:800
    if p_first(nBin)==1
        scatter(nBin,0.519,'_','r')
    end
end
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
        scatter(nBin,0.519,'_','r')
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
        scatter(nBin,0.519,'_','r')
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