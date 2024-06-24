function getquintile
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
fourthQuintile = [];
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
firstQuintile = gpuArray(firstQuintile/2 + 0.5);
secondQuintile = gpuArray(secondQuintile/2 + 0.5);
thirdQuintile = gpuArray(thirdQuintile/2 + 0.5);
fourthQuintile = gpuArray(fourthQuintile/2 + 0.5);
fifthQuintile = gpuArray(fifthQuintile/2 + 0.5);

% %find the mean
% MFirstQuint = mean(firstQuintile);
% MSecondQuint = mean(secondQuintile);
% MthirdQuint = mean(thirdQuintile);
% MfourthQuint = mean(fourthQuintile);
% MfifthQuint = mean(fifthQuintile);
% 
% %remove the first 400 ms timebins to shorten heatmap plot
% Mfirst400 = MFirstQuint(400:800); %ASK JACKSON ABOUT THE TIME LABELS
% Msecond400 = MSecondQuint(400:800);
% Mthird400 = MthirdQuint(400:800);
% Mfourth400 = MfourthQuint(400:800);
% Mfifth400 = MfifthQuint(400:800);
% 
% %Smoothen data
% 
% % Define the window size
% windowSize = 5;
% 
% % Calculate the moving average
% smoothfirst = movmean(Mfirst400, windowSize);
% smoothsecond = movmean(Msecond400, windowSize);
% smooththird = movmean(Mthird400, windowSize);
% smoothfourth = movmean(Mfourth400, windowSize);
% smoothfifth = movmean(Mfifth400, windowSize);
% 
% % Subsample the data
% 
% % Define the step size
% stepSize = 5;
% 
% %subsample
% subsampledfirst = smoothfirst(1:stepSize:end);
% subsampledsecond = smoothsecond(1:stepSize:end);
% subsampledthird = smooththird(1:stepSize:end);
% subsampledfourth = smoothfourth(1:stepSize:end);
% subsampledfifth = smoothfifth(1:stepSize:end);
% 
% %normalize data by maximum
% 
% %identify max of each quintile
% maxFirst = max(subsampledfirst);
% maxSecond = max(subsampledsecond);
% maxThird = max(subsampledthird);
% maxFourth = max(subsampledfourth);
% maxFifth =  max(subsampledfifth);
% 
% %normalize and convert samples to negative
% subsampledfirst = -(subsampledfirst/maxFirst);
% subsampledsecond = -(subsampledsecond/maxSecond);
% subsampledthird = -(subsampledthird/maxThird);
% subsampledfourth = -(subsampledfourth/maxFourth);
% subsampledfifth = -(subsampledfifth/maxFifth);


% Plot Check
% figure;
% hold on
% plot(mean(firstQuintile))
% plot(mean(secondQuintile))
% plot(mean(thirdQuintile))
% plot(mean(fourthQuintile))
% plot(mean(fifthQuintile))
% hold off
% legend ('firstQuint','secondQuintile','thirdQuintile','fourthQuintile','fifthQuintile')



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
        p_first(1,binNum) = (size(firstBootsAOK,1) - sum(firstBootsAOK(:,binNum)<0.5))/size(firstBootsAOK,1);
        p_second(1,binNum) = (size(secondBootsAOK,1) - sum(secondBootsAOK(:,binNum)<0.5))/size(secondBootsAOK,1);
        p_third(1,binNum) = (size(thirdBootsAOK,1) - sum(thirdBootsAOK(:,binNum)<0.5))/size(thirdBootsAOK,1);
    end

%% Kernel Plots

% Filter SetUp
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

%create a struct for plotting
quintStruct = struct('firstQuintile',firstQuintile, 'secondQuintile', secondQuintile, 'thirdQuintile', thirdQuintile, 'fourthQuintile', fourthQuintile, 'fifthQuintile', fifthQuintile);
quintFields = fieldnames(quintStruct);

clr = 'rkgbm'; %colours of each cluster


%create tiled layout for all plots
figure('Position',[1 1 750 1500]);
t= tiledlayout(3,2);
title(t,'Comparison of Kernels Across the Five Quintiles',"FontSize",15)
tileOrder = [1 3 5 2 4]; %places the graphs in right place


% Compute each profile w/ SEM
for nProfiles = 1:length(quintFields)
    %init var for smoothing kernel
    smoothKernel = gpuArray();

    for nTrial = 1:length(quintStruct.(string(quintFields(nProfiles))))
    smoothKernel(nTrial,1:length(quintStruct.(string(quintFields(nProfiles)))(nTrial,:))) = smooth(quintStruct.(string(quintFields(nProfiles)))(nTrial,:));
    end

    boot = bootstrp(1000,@mean,smoothKernel);
    PCs = prctile(boot, [15.9, 50, 84.1]);              % +/- 1 SEM
    PCMeans = mean(PCs, 2);
    CIs = zeros(3, size(quintStruct.(string(quintFields(nProfiles))), 2));

    for c = 1:3
        CIs(c,:) = filtfilt(filterLP, PCs(c,:) - PCMeans(c)) + PCMeans(c);
    end

    x = 1:size(CIs, 2);
    x2 = [x, fliplr(x)];
    bins = size(CIs,2);

    %plots
    nexttile(tileOrder(nProfiles)); %or tileorder(nProfiles) if wanted to be ordered
    hold on
    plot(x, CIs(2, :), clr(nProfiles), 'LineWidth', 1.5); % This plots the mean of the bootstrap
    fillCI = [CIs(1, :), fliplr(CIs(3, :))]; % This sets up the fill for the errors
    fill(x2, fillCI, clr(nProfiles), 'lineStyle', '-', 'edgeColor', clr(nProfiles), 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill
    yline(0,'--k')
    hold off
    ylim([0.465 0.515])
    title(string(quintFields(nProfiles)))
    set(gca,"FontSize",15)
    ax = gca;
    ax.XGrid = 'on';
    ax.XMinorGrid = "on";
    ax.XTick = [0:200:800];
    ax.XTickLabel = {'-400', '', '0', '', '400'};
    ax.TickDir = "out";
    xlabel('Time (ms)')
    ylabel('Normalized Power')
end

%% HeatMap Plot
% varNames = ['Quintile', string(1:81)]; %ASK JACKSON FOR GRAPH LABELS
% sz = [5 82];
% timeVar = repmat({'double'},1,81);
% varTypes = ['string', timeVar];
% TheatMap = table('size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
% TheatMap.Quintile = {'FirstQuint','secondQuint','thirdQuint','fourthQuint','fifthQuint'}';
% TheatMap(:,2:end) = array2table(vertcat(subsampledfirst,subsampledsecond,subsampledthird,subsampledfourth,subsampledfifth));
% xvar = TheatMap.Properties.VariableNames(2:end);
% yvar = string(TheatMap.(1));
% cvar = TheatMap{:,2:end};
% %plot
% figure;
% h = heatmap(xvar,yvar,cvar);
% %get color of heatmap 
% currentC = colormap(h);
% %reverse colour so darkest shows deepest peak
% %flipC = flipud(currentC);
% %colormap(h,flipC)
% xlabel('Timebin')
% title('V1 Gabor Quintile RTs from Smoothen 400:800 Timebins Max Normalized')



end