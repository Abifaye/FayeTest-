function getDBScanPlots


%load data files needed
DBStruct_data = load(uigetfile('','Choose DBStruct File')); %choose appropriate DBStruct File
fieldNames_DBStruct = fieldnames(DBStruct_data); %creates place for name of DBStruct so that it
% can be directly accessed instead of embedded in a struct
DBStruct_data = DBStruct_data.(fieldNames_DBStruct{1}); %remakes DBStruct_data as the actual DBStruct
trans_Data = load (uigetfile('','Select Rolling Average Data Table File')); %choose transformed data File
fieldNames_transData = fieldnames(trans_Data); %creates place for name of Rolling Average Data so that it
% can be directly accessed instead of embedded in a struct
trans_Data = trans_Data.(fieldNames_transData{1});%remakes trans_data as the actual table of Rolling Average Data
load(uigetfile('','Choose Master Table of Raw Data File')); %choose appropriate master table File

%Scatter plots
gen_Scatter = input('Generate Scatter plots? [0=No/1=Yes]: ');
if gen_Scatter==1
    DBdata = input(strcat('Choose Data Number from DBStruct to create plot for:',32))+1;
    Fields = fieldnames(DBStruct_data);
    xVar = listdlg('PromptString',{'Select x-var'},'ListString',trans_Data.Properties.VariableNames,'SelectionMode','single');
    yVar = listdlg('PromptString',{'Select y-var'},'ListString',trans_Data.Properties.VariableNames,'SelectionMode','single');
    %
    clrMat= flip({['r', 'b', 'g', 'k', 'y', 'c']; [ 'r' 'b' 'g' 'k' 'y']; ['r' 'b' 'g' 'k']; ['r' 'b' 'g']; ['r' 'b']});
    %
    clrNum = DBStruct_data(4).(string(Fields(DBdata)));

    if clrNum < 6
        clr = cell2mat(clrMat(clrNum));
    elseif clrNum > 5
        clr = hsv(clrNum);
    end

    figure;
    gscatter(trans_Data.(xVar),trans_Data.(yVar),DBStruct_data(1).(string(Fields(DBdata))),clr)%check if using xVar and yVar works
    title(string(Fields(DBdata)))
    xlabel(trans_Data.Properties.VariableNames{xVar})
    ylabel(trans_Data.Properties.VariableNames{yVar})

    addPlot = input(strcat('Create another plot for current data? [Y=1/N=0]:',32));

    while addPlot == 1
        xVar = listdlg('PromptString',{'Select x-var'},'ListString',trans_Data.Properties.VariableNames,'SelectionMode','single');
        yVar = listdlg('PromptString',{'Select y-var'},'ListString',trans_Data.Properties.VariableNames,'SelectionMode','single');

        figure;
        gscatter(DBStruct_data.(xVar),DBStruct_data.(yVar),DBStruct_data(1).(string(Fields(DBdata))),clr)%check if using xVar and yVar works
        title(string(Fields(DBdata)))
        xlabel(DBStruct_data.Properties.VariableNames{xVar})
        ylabel(DBStruct_data.Properties.VariableNames{yVar})
        addPlot = input(strcat('Create another plot for current data? [Y=1/N=0]:',32));
    end
end
%% kernels of clusters
gen_kernels = input('Generate kernels for each cluster? [Yes=1/0=No]: '); %decide whether to generate kernel graphs for clusters
if gen_kernels==1
    DBdata = input(strcat('Choose Data Number from DBStruct to create plot for:',32))+1;
    Fields = fieldnames(DBStruct_data);
    %Create 2 matrices containing all hits and all miss profiles
    hitProfiles = cell2mat(T.hitProfiles);
    missProfiles = cell2mat(T.missProfiles);

    %Take only miss+hits trials with optopower
    optoHitClusters = DBStruct_data(1).(string(Fields(DBdata)))(strcmp(trans_Data.trialEnd,"hit") & trans_Data.optoPower~=0);
    optoMissClusters = DBStruct_data(1).(string(Fields(DBdata)))(strcmp(trans_Data.trialEnd,"miss") & trans_Data.optoPower~=0);

    %separate the profiles by each cluster
    firstProfiles = [hitProfiles(optoHitClusters==1,1:end); -missProfiles(optoMissClusters==1,1:end)];
    secondProfiles = [hitProfiles(optoHitClusters==2,1:end); -missProfiles(optoMissClusters==2,1:end)];
    thirdProfiles = [hitProfiles(optoHitClusters==3,1:end); -missProfiles(optoMissClusters==3,1:end)];
    outliers = [hitProfiles(optoHitClusters==-1,1:end); -missProfiles(optoMissClusters==-1,1:end)];
    allProfiles = [hitProfiles(:,1:end); -missProfiles(:,1:end)];
    %sixthProfiles = [hitProfiles(optoHitClusters==6,1:end); -missProfiles(optoMissClusters==6,1:end)];
    %seventhProfiles = [hitProfiles(optoHitClusters==7,1:end); -missProfiles(optoMissClusters==7,1:end)];
end

% Filter SetUp
% Set Up Filter for Profiles
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

%create tiled layout for all plots
figure('Position',[1 1 750 1500]);
t= tiledlayout(2,2);
title(t,'Comparison of Kernels Across the Five Clusters',"FontSize",15)
% Bootstrap
profiles_struct = struct('firstProfiles',firstProfiles,'secondProfiles',secondProfiles,'thirdProfiles',thirdProfiles,'outliers',outliers);
profile_names = fieldnames(profiles_struct);
clr = 'rkgbm';
%Actual Graphs
% Plot each profile w/ SEM
for nProfiles = 1:length(profile_names)
    boot = bootstrp(1000,@mean,profiles_struct.(string(profile_names(nProfiles))));
    PCs = prctile(boot, [15.9, 50, 84.1]);              % +/- 1 SEM
    PCMeans = mean(PCs, 2);
    CIs = zeros(3, size(profiles_struct.(string(profile_names(nProfiles))), 2));

    for c = 1:3
        CIs(c,:) = filtfilt(filterLP, PCs(c,:) - PCMeans(c)) + PCMeans(c);
    end

    x = 1:size(CIs, 2);
    x2 = [x, fliplr(x)];
    bins = size(CIs,2);

    %plots
    nexttile;
    hold on
    plot(x, CIs(2, :), clr(nProfiles), 'LineWidth', 1.5); % This plots the mean of the bootstrap
    fillCI = [CIs(1, :), fliplr(CIs(3, :))]; % This sets up the fill for the errors
    fill(x2, fillCI, clr(nProfiles), 'lineStyle', '-', 'edgeColor', clr(nProfiles), 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % adds the fill
    yline(0,'--k')
    hold off
    title(string(profile_names(nProfiles)))
    set(gca,"FontSize",16)
    ax = gca;
    ax.XGrid = 'on';
    ax.XMinorGrid = "on";
    ax.XTick = [0:200:800];
    ax.XTickLabel = {'-400', '', '0', '', '400'};
    ax.TickDir = "out";
    ay = gca;
    ay.YLim = [-.23 0.23];
    ay.YTick = [-.23:0.11:0.23];
    ay.YTickLabel = {'-0.23','', '','','0.23'};
    xlabel('Time (ms)')
    ylabel('Normalized Power')
end

%% Extra
%COUNTINUE HERE uitable('Data', A.labels([1:3 5 6])) this might not work.
%Instead try going from 2:10 minpts for any of the stuff for eps_range. We
%need to double check this because the number of outliers are very small
%for such a large eps (Not sure if this is very good or not. Anyway, it
%might make very insignificant results if we replot them as kernels

end
