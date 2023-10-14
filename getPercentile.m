function getPercentile
%% Variable Initialization
%Go to folder with the master table
cd(uigetdir());

%load master table with hit profiles file
load('masterTable_allLuminanceTrials.mat')
load normData.mat
load masterDBDataTable.mat

%Take only miss+hits trials with optopower from master tables
optoHit = normData(strcmp(masterDBDataTable.trialEnd,"hit") & masterDBDataTable.optoPower~=0,1:size(normData,2));
optoMiss = normData(strcmp(masterDBDataTable.trialEnd,"miss") & masterDBDataTable.optoPower~=0,1:size(normData,2));

%Create 2 matrices containing all hits and all miss profiles
hitProfiles = cell2mat(T.hitProfiles);
missProfiles = cell2mat(T.missProfiles);

%create tables so that normalized Data has column labels
Tnorm_hit = array2table(optoHit,'VariableNames',masterDBDataTable.Properties.VariableNames(5:9));
Tnorm_miss = array2table(optoMiss,'VariableNames',masterDBDataTable.Properties.VariableNames(5:9));

%Var Select
Var = listdlg('PromptString',{'Choose which Master Table', 'variable to use for labelling'},'ListString',Tnorm_hit.Properties.VariableNames,'SelectionMode','single');

%Percentile Select
percChoice = {['half'],['tertile']};
percentile = listdlg('PromptString',{'Choose what type of percentile to use for sub-selecting data'},'ListString',percChoice,'SelectionMode','single');

%% Data Sub-Selection

%Group data based on chosen percentile
if percentile == 1%assign groups based on half percentile (top half, bottom half)
    %hits
    topIdx_hit = (Tnorm_hit.(Var) >= min(prctile(Tnorm_hit.(Var),[0 50])) & Tnorm_hit.(Var) <= max(prctile( Tnorm_hit.(Var),[0 50])));
    btmIdx_hit = (Tnorm_hit.(Var) > min(prctile(Tnorm_hit.(Var),[50 100])) & Tnorm_hit.(Var) <= max(prctile( Tnorm_hit.(Var),[50 100])));

    %hmiss
    topIdx_miss = (Tnorm_miss.(Var) >= min(prctile(Tnorm_miss.(Var),[0 50])) & Tnorm_miss.(Var) <= max(prctile(Tnorm_miss.(Var),[0 50])));
    btmIdx_miss = (Tnorm_miss.(Var) > min(prctile(Tnorm_miss.(Var),[50 100])) & Tnorm_miss.(Var) <= max(prctile(Tnorm_miss.(Var),[50 100])));

    %All Profiles Tertile
    allProfiles_top = [hitProfiles(topIdx_hit,1:end); -missProfiles(topIdx_miss,1:end)];
    allProfiles_btm = [hitProfiles(btmIdx_hit,1:end); -missProfiles(btmIdx_miss,1:end)];
    
    %graph
    figure;
    hold on
    plot(mean(allProfiles_top))
    plot(mean(allProfiles_btm))
    title(append(Tnorm_hit.Properties.VariableNames(Var),' ','kernel',' ',percChoice(percentile),' ','percentile'))
    legend ('Top Profiles', 'Bottom Profiles')
    hold off

elseif percentile == 2 %assign groups based on Tertile (first third, second third, last third)
    %hits
    firstIdx_hit = (Tnorm_hit.(Var) >= min(prctile(Tnorm_hit.(Var),[0 33.33])) & Tnorm_hit.(Var) <= max(prctile(Tnorm_hit.(Var),[0 33.33])));
    secondIdx_hit = (Tnorm_hit.(Var) > min(prctile(Tnorm_hit.(Var),[33.33 66.67])) & Tnorm_hit.(Var) <= max(prctile(Tnorm_hit.(Var),[33.33 66.67])));
    thirdIdx_hit = (Tnorm_hit.(Var) > min(prctile(Tnorm_hit.(Var),[66.67 100])) & Tnorm_hit.(Var) <= max(prctile(Tnorm_hit.(Var),[66.67 100])));

    %misses
    firstIdx_miss = (Tnorm_miss.(Var) >= min(prctile(Tnorm_miss.(Var),[0 33.33])) & Tnorm_miss.(Var) <= max(prctile(Tnorm_miss.(Var),[0 33.33])));
    secondIdx_miss = (Tnorm_miss.(Var) > min(prctile(Tnorm_miss.(Var),[33.33 66.67])) & Tnorm_miss.(Var) <= max(prctile(Tnorm_miss.(Var),[33.33 66.67])));
    thirdIdx_miss = (Tnorm_miss.(Var) > min(prctile(Tnorm_miss.(Var),[66.67 100])) & Tnorm_miss.(Var) <= max(prctile(Tnorm_miss.(Var),[66.67 100])));
    % Assign Tertile labels based on idx

    %All Profiles Tertile
    allProfiles_first = [hitProfiles(firstIdx_hit,1:end); -missProfiles(firstIdx_miss,1:end)];
    allProfiles_second = [hitProfiles(secondIdx_hit,1:end); -missProfiles(secondIdx_miss,1:end)];
    allProfiles_third = [hitProfiles(thirdIdx_hit,1:end); -missProfiles(thirdIdx_miss,1:end)];

    %graph
    figure;
    hold on
    plot(mean(allProfiles_first))
    plot(mean(allProfiles_second))
    plot(mean(allProfiles_third))
    title(append(Tnorm_hit.Properties.VariableNames(Var),' ','kernel',' ',percChoice(percentile),' ','percentile'))
    legend ('First Profiles', 'Second Profiles', 'Third Profiles')

end


end