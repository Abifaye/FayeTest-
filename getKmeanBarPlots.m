function getKmeanBarPlots(Clusters,masterDBDataTable)
%% ADD COMMENTS!!!

clusterNum = max(Clusters);
selectVar = listdlg('PromptString',{'Select variable(s) to create', ...
    'graphs for'},'ListString', ...
    masterDBDataTable.Properties.VariableNames,'SelectionMode','multiple');
meanData = table();
stdData = table();

for nVar= 1:length(selectVar)
    for nCluster = 1:clusterNum
        meanData.(string(masterDBDataTable.Properties.VariableNames(selectVar(nVar))))(nCluster) = mean(masterDBDataTable.(selectVar(nVar))(Clusters==nCluster));
        stdData.(string(masterDBDataTable.Properties.VariableNames(selectVar(nVar))))(nCluster) = std(masterDBDataTable.(selectVar(nVar))(Clusters==nCluster));
    end
end

for nVar= 1:length(selectVar)
    x = categorical(append('Cluster',' ',string((1:clusterNum))));
    y = meanData.(nVar)(1:clusterNum);
    figure;
    hold on;
    bar(x,y)
    for nCluster = 1:clusterNum
        plot([nCluster nCluster], [meanData.(nVar)(nCluster)+stdData.(nVar)(nCluster) meanData.(nVar)(nCluster)-stdData.(nVar)(nCluster)], 'k');
        scatter([nCluster nCluster], [meanData.(nVar)(nCluster)+stdData.(nVar)(nCluster) meanData.(nVar)(nCluster)-stdData.(nVar)(nCluster)], "_",'k');
    end
    title(append('Mean',' ',string(masterDBDataTable.Properties.VariableNames(selectVar(nVar)))))
    ylabel('Mean Raw Data')
end

end