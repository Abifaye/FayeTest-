function [tSNE_hit,tSNE_miss] = getTSNE
%% T_SNE Code
%% Label each Data Point Using Percentile of Specified Variable
%load data files
load normData_hit.mat
load normData_miss.mat
load hitDataTable.mat
load missDataTable.mat

%create tables so that normalized Data has column labels
Tnorm_hit = array2table(normData_hit,'VariableNames',hitDataTable.Properties.VariableNames(5:8));
Tnorm_miss = array2table(normData_miss,'VariableNames',missDataTable.Properties.VariableNames(5:7));
Tnorm_hit_half = array2table(normData_hit,'VariableNames',hitDataTable.Properties.VariableNames(5:8));
Tnorm_miss_half = array2table(normData_miss,'VariableNames',missDataTable.Properties.VariableNames(5:7));
Tnorm_hit_tertile = array2table(normData_hit,'VariableNames',hitDataTable.Properties.VariableNames(5:8));
Tnorm_miss_tertile = array2table(normData_miss,'VariableNames',missDataTable.Properties.VariableNames(5:7));

%Var Select
hitVar = listdlg('PromptString',{'Choose which Hit Table', 'variable to use for labelling'},'ListString',Tnorm_hit.Properties.VariableNames,'SelectionMode','single');
missVar = listdlg('PromptString',{'Choose which Miss Table', 'variable to use for labelling'},'ListString',Tnorm_miss.Properties.VariableNames,'SelectionMode','single');

%Percentile Select
percChoice = {['half'],['tertile'], ['Both']};
percentile = listdlg('PromptString',{'Choose what type of percentile to use for sub-selecting data'},'ListString',percChoice,'SelectionMode','single');

%Group data based on chosen percentile
if percentile == 1%assign groups based on half percentile (top half, bottom half)
    %hits
    topIdx_hit = (Tnorm_hit.(hitVar) >= min(prctile(Tnorm_hit.(hitVar),[0 50])) & Tnorm_hit.(hitVar) <= max(prctile( Tnorm_hit.(hitVar),[0 50])));
    btmIdx_hit = (Tnorm_hit.(hitVar) > min(prctile(Tnorm_hit.(hitVar),[50 100])) & Tnorm_hit.(hitVar) <= max(prctile( Tnorm_hit.(hitVar),[50 100])));

    %hmiss
    topIdx_miss = (Tnorm_miss.(missVar) >= min(prctile(Tnorm_miss.(missVar),[0 50])) & Tnorm_miss.(missVar) <= max(prctile(Tnorm_miss.(missVar),[0 50])));
    btmIdx_miss = (Tnorm_miss.(missVar) > min(prctile(Tnorm_miss.(missVar),[50 100])) & Tnorm_miss.(missVar) <= max(prctile(Tnorm_miss.(missVar),[50 100])));

    %hits
    Tnorm_hit.labels(topIdx_hit) = 1;
    Tnorm_hit.labels(btmIdx_hit) = 2;

    %miss
    Tnorm_miss.labels(topIdx_miss) = 1;
    Tnorm_miss.labels(btmIdx_miss) = 2;

    % t-SNE

    %hits
    %tSNE_hit = tsne(normData_hit,"Distance","cityblock");
    tSNE_hit = tsne(normData_hit);

    %miss
    %tSNE_miss = tsne(normData_miss,"Distance","cityblock");
    tSNE_miss = tsne(normData_miss);

    % Plots
    figure;
    gscatter(tSNE_hit(:,1),tSNE_hit(:,2),Tnorm_hit.labels)
    title(append('t-SNE Hits:',' ',Tnorm_hit.Properties.VariableNames(hitVar),' ',percChoice(percentile),' ','percentile'))


    figure;
    gscatter(tSNE_miss(:,1),tSNE_miss(:,2),Tnorm_miss.labels)
    title(append('t-SNE Miss:',' ',Tnorm_miss.Properties.VariableNames(missVar),' ',percChoice(percentile),' ','percentile'))

elseif percentile == 2 %assign groups based on Tertile (first third, second third, last third)
    %hits
    firstIdx_hit = (Tnorm_hit.(hitVar) >= min(prctile(Tnorm_hit.(hitVar),[0 33.33])) & Tnorm_hit.(hitVar) <= max(prctile(Tnorm_hit.(hitVar),[0 33.33])));
    secondIdx_hit = (Tnorm_hit.(hitVar) > min(prctile(Tnorm_hit.(hitVar),[33.33 66.67])) & Tnorm_hit.(hitVar) <= max(prctile(Tnorm_hit.(hitVar),[33.33 66.67])));
    thirdIdx_hit = (Tnorm_hit.(hitVar) > min(prctile(Tnorm_hit.(hitVar),[66.67 100])) & Tnorm_hit.(hitVar) <= max(prctile(Tnorm_hit.(hitVar),[66.67 100])));

    %misses
    firstIdx_miss = (Tnorm_miss.(missVar) >= min(prctile(Tnorm_miss.(missVar),[0 33.33])) & Tnorm_miss.(missVar) <= max(prctile(Tnorm_miss.(missVar),[0 33.33])));
    secondIdx_miss = (Tnorm_miss.(missVar) > min(prctile(Tnorm_miss.(missVar),[33.33 66.67])) & Tnorm_miss.(missVar) <= max(prctile(Tnorm_miss.(missVar),[33.33 66.67])));
    thirdIdx_miss = (Tnorm_miss.(missVar) > min(prctile(Tnorm_miss.(missVar),[66.67 100])) & Tnorm_miss.(missVar) <= max(prctile(Tnorm_miss.(missVar),[66.67 100])));
    % Assign Tertile labels based on idx

    %hits
    Tnorm_hit.labels(firstIdx_hit) = 1;
    Tnorm_hit.labels(secondIdx_hit) = 2;
    Tnorm_hit.labels(thirdIdx_hit) = 3;

    %miss
    Tnorm_miss.labels(firstIdx_miss) = 1;
    Tnorm_miss.labels(secondIdx_miss) = 2;
    Tnorm_miss.labels(thirdIdx_miss) = 3;

    % t-SNE

    %hits
    %tSNE_hit = tsne(normData_hit,"Distance","cityblock");
    tSNE_hit = tsne(normData_hit);

    %miss
    %tSNE_miss = tsne(normData_miss,"Distance","cityblock");
    tSNE_miss = tsne(normData_miss);


    % Plots
    figure;
    gscatter(tSNE_hit(:,1),tSNE_hit(:,2),Tnorm_hit.labels)
    title(append('t-SNE Hits:',' ',Tnorm_hit.Properties.VariableNames(hitVar),' ',percChoice(percentile),' ','percentile'))


    figure;
    gscatter(tSNE_miss(:,1),tSNE_miss(:,2),Tnorm_miss.labels)
    title(append('t-SNE Miss:',' ',Tnorm_miss.Properties.VariableNames(missVar),' ',percChoice(percentile),' ','percentile'))

elseif percentile == 3
    %half percentile
    %hits
    topIdx_hit = (Tnorm_hit.(hitVar) >= min(prctile(Tnorm_hit.(hitVar),[0 50])) & Tnorm_hit.(hitVar) <= max(prctile( Tnorm_hit.(hitVar),[0 50])));
    btmIdx_hit = (Tnorm_hit.(hitVar) > min(prctile(Tnorm_hit.(hitVar),[50 100])) & Tnorm_hit.(hitVar) <= max(prctile( Tnorm_hit.(hitVar),[50 100])));

    %hmiss
    topIdx_miss = (Tnorm_miss.(missVar) >= min(prctile(Tnorm_miss.(missVar),[0 50])) & Tnorm_miss.(missVar) <= max(prctile(Tnorm_miss.(missVar),[0 50])));
    btmIdx_miss = (Tnorm_miss.(missVar) > min(prctile(Tnorm_miss.(missVar),[50 100])) & Tnorm_miss.(missVar) <= max(prctile(Tnorm_miss.(missVar),[50 100])));

    %hits
    Tnorm_hit_half.labels(topIdx_hit) = 1;
    Tnorm_hit_half.labels(btmIdx_hit) = 2;

    %miss
    Tnorm_miss_half.labels(topIdx_miss) = 1;
    Tnorm_miss_half.labels(btmIdx_miss) = 2;

    %Tertile
    %hits
    firstIdx_hit = (Tnorm_hit.(hitVar) >= min(prctile(Tnorm_hit.(hitVar),[0 33.33])) & Tnorm_hit.(hitVar) <= max(prctile(Tnorm_hit.(hitVar),[0 33.33])));
    secondIdx_hit = (Tnorm_hit.(hitVar) > min(prctile(Tnorm_hit.(hitVar),[33.33 66.67])) & Tnorm_hit.(hitVar) <= max(prctile(Tnorm_hit.(hitVar),[33.33 66.67])));
    thirdIdx_hit = (Tnorm_hit.(hitVar) > min(prctile(Tnorm_hit.(hitVar),[66.67 100])) & Tnorm_hit.(hitVar) <= max(prctile(Tnorm_hit.(hitVar),[66.67 100])));

    %misses
    firstIdx_miss = (Tnorm_miss.(missVar) >= min(prctile(Tnorm_miss.(missVar),[0 33.33])) & Tnorm_miss.(missVar) <= max(prctile(Tnorm_miss.(missVar),[0 33.33])));
    secondIdx_miss = (Tnorm_miss.(missVar) > min(prctile(Tnorm_miss.(missVar),[33.33 66.67])) & Tnorm_miss.(missVar) <= max(prctile(Tnorm_miss.(missVar),[33.33 66.67])));
    thirdIdx_miss = (Tnorm_miss.(missVar) > min(prctile(Tnorm_miss.(missVar),[66.67 100])) & Tnorm_miss.(missVar) <= max(prctile(Tnorm_miss.(missVar),[66.67 100])));
    % Assign Tertile labels based on idx

    %hits
    Tnorm_hit_tertile.labels(firstIdx_hit) = 1;
    Tnorm_hit_tertile.labels(secondIdx_hit) = 2;
    Tnorm_hit_tertile.labels(thirdIdx_hit) = 3;

    %miss
    Tnorm_miss_tertile.labels(firstIdx_miss) = 1;
    Tnorm_miss_tertile.labels(secondIdx_miss) = 2;
    Tnorm_miss_tertile.labels(thirdIdx_miss) = 3;

    % t-SNE

    %hits
    %tSNE_hit = tsne(normData_hit,"Distance","cityblock");
    tSNE_hit = tsne(normData_hit);

    %miss
    %tSNE_miss = tsne(normData_miss,"Distance","cityblock");
    tSNE_miss = tsne(normData_miss);

    % Plots
    %hit
    figure;
    t= tiledlayout(2,1);
    title(t,' ',"FontSize",15)
    %half
    nexttile;
    gscatter(tSNE_hit(:,1),tSNE_hit(:,2),Tnorm_hit_half.labels)
    title(append('t-SNE Hits:',' ',Tnorm_hit_half.Properties.VariableNames(hitVar),' ',percChoice(percentile),' ','percentile'))
    set(gca,"FontSize",15)
    xlabel('Dimension 1 Embeddings')
    ylabel('Dimension 2 Embeddings')
    %tertile
    nexttile;
    gscatter(tSNE_hit(:,1),tSNE_hit(:,2),Tnorm_hit_tertile.labels)
    title(append('t-SNE Hits:',' ',Tnorm_hit_tertile.Properties.VariableNames(hitVar),' ',percChoice(percentile),' ','percentile'))
    set(gca,"FontSize",15)
    xlabel('Dimension 1 Embeddings')
    ylabel('Dimension 2 Embeddings')

    %miss
    %half
    figure;
    gscatter(tSNE_miss(:,1),tSNE_miss(:,2),Tnorm_miss_half.labels)
    title(append('t-SNE Miss:',' ',Tnorm_miss_half.Properties.VariableNames(missVar),' ',percChoice(percentile),' ','percentile'))
    set(gca,"FontSize",15)
    %tertile
    figure;
    gscatter(tSNE_miss(:,1),tSNE_miss(:,2),Tnorm_miss_tertile.labels)
    title(append('t-SNE Miss:',' ',Tnorm_miss_tertile.Properties.VariableNames(missVar),' ',percChoice(percentile),' ','percentile'))
    set(gca,"FontSize",15)
end



end