function getKmeanScatterPlots(masterClusters)
%summary: inputs to masterclusters to create a 2D scatter plot of variables
%from the master table sorted by the cluster numbers

%load master table
load masterDBDataTable_hitsRTs.mat

%% Init Vars
xVar = listdlg('PromptString',{'Select x-var'},'ListString',masterDBDataTable.Properties.VariableNames,'SelectionMode','single');
yVar = listdlg('PromptString',{'Select y-var'},'ListString',masterDBDataTable.Properties.VariableNames,'SelectionMode','single');

%% Plot
clr = hsv(max(masterClusters)); %automatically generate unique colours depending on how many clusters there are
figure;
gscatter(masterDBDataTable.(xVar),masterDBDataTable.(yVar),masterClusters,clr,'.',2)
title('Kmean Scatter Plot')
xlabel(masterDBDataTable.Properties.VariableNames{xVar})
ylabel(masterDBDataTable.Properties.VariableNames{yVar})

%% Make more plots
addPlot = input(strcat('Create another plot for current data? [Y=1/N=0]:',32));

while addPlot == 1 % whenever prompt respons is yes, repeat  everything starting from addplot prompt
    xVar = listdlg('PromptString',{'Select x-var'},'ListString',masterDBDataTable.Properties.VariableNames,'SelectionMode','single');
    yVar = listdlg('PromptString',{'Select y-var'},'ListString',masterDBDataTable.Properties.VariableNames,'SelectionMode','single');
    
    figure;
    gscatter(masterDBDataTable.(xVar),masterDBDataTable.(yVar),masterClusters,clr,'.',2)
    title('Kmean Scatter Plot')
    xlabel(masterDBDataTable.Properties.VariableNames{xVar})
    ylabel(masterDBDataTable.Properties.VariableNames{yVar})

    addPlot = input(strcat('Create another plot for current data? [Y=1/N=0]:',32));
end

%% Extra Plot for sorting by all 12 animals
%figure;
gscatter(masterDBDataTable.(xVar),masterDBDataTable.(yVar),masterDBDataTable.animal,clr,'.',2)%check if using xVar and yVar works
title('Kmean Scatter Plot: Animal ID Sorted')
xlabel(masterDBDataTable.Properties.VariableNames{xVar})
ylabel(masterDBDataTable.Properties.VariableNames{yVar})

%Sorted By outcomes
%A = strcmp(masterDBDataTable.trialEnd,"hit");
%B = strcmp(masterDBDataTable.trialEnd,"miss");
%C = strcmp(masterDBDataTable.trialEnd,"fa");
%figure;
%title('Kmean Scatter Plot: Outcome Sorted')
%gscatter(masterDBDataTable.(xVar)(A|B),masterDBDataTable.(yVar)(A|B),masterDBDataTable.trialEnd(A|B),clr,'.',2)%check if using xVar and yVar works
%title('Kmean Scatter Plot')
%xlabel(masterDBDataTable.Properties.VariableNames{xVar})
%ylabel(masterDBDataTable.Properties.VariableNames{yVar})

end