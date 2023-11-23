function getKmeanScatterPlots(masterClusters)
%% ADD COMMENTS!!!

%% Init Vars
%
load masterDBDataTable.mat

%
xVar = listdlg('PromptString',{'Select x-var'},'ListString',masterDBDataTable.Properties.VariableNames,'SelectionMode','single');
yVar = listdlg('PromptString',{'Select y-var'},'ListString',masterDBDataTable.Properties.VariableNames,'SelectionMode','single');

%% Plot
figure;
gscatter(masterDBDataTable.(xVar),masterDBDataTable.(yVar),masterClusters)%check if using xVar and yVar works
title('Kmean Scatter Plot')
xlabel(masterDBDataTable.Properties.VariableNames{xVar})
ylabel(masterDBDataTable.Properties.VariableNames{yVar})

%% Make more plots
addPlot = input(strcat('Create another plot for current data? [Y=1/N=0]:',32));

while addPlot == 1
    xVar = listdlg('PromptString',{'Select x-var'},'ListString',masterDBDataTable.Properties.VariableNames,'SelectionMode','single');
    yVar = listdlg('PromptString',{'Select y-var'},'ListString',masterDBDataTable.Properties.VariableNames,'SelectionMode','single');

    figure;
    gscatter(masterDBDataTable.(xVar),masterDBDataTable.(yVar),masterClusters)
    title('Kmean Scatter Plot')
    xlabel(masterDBDataTable.Properties.VariableNames{xVar})
    ylabel(masterDBDataTable.Properties.VariableNames{yVar})
    addPlot = input(strcat('Create another plot for current data? [Y=1/N=0]:',32));
end

end