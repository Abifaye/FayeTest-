function [masterRollAve] = getrollingAverage
%Computes the rolling average for variables of interest from
%master table and returns a table containing rolling averages for each
%variable

%load master table
load('masterTable_complete.mat');

%select variables dialogue for selecting variables from master table to
%compute rolling average (i.e. rewards, allrts)
selection = listdlg('PromptString',{'Select variable(s) to compute', ...
    'rolling average'},'ListString',T.Properties.VariableNames,'SelectionMode','multiple');

%init variable for rolling averages table 
masterRollAve = table();

%loop through each selected variable
for nVar = 1:length(selection)

    %init variable from mastertable
    variable = [T.(T.Properties.VariableNames{selection(nVar)})];

    %Command window dialgoue for how many trials should be used as window
    %length for the
    k = input(strcat('Input Window Length for Rolling',T.Properties.VariableNames{selection(nVar)},':',32)); %code 32 = space

    %init counter and temporary matrix
    counter = 0;
    tempMat = [];

    %loop through each session of the variable and compute rolling average
    for nSession = 1:length(variable)
        %place moving average in temporary matrix
        tempMat(counter+1:counter+length(variable{nSession}),1) = [movmean(variable{nSession},k)];

        %adjust counter to extend length of matrix
        counter = counter +length(variable{nSession});
    end

    %create labeled column for corresponding variable and place data from
    %temporary matrix into the column
    masterRollAve.(strcat('rolling',T.Properties.VariableNames{selection(nVar)})) = tempMat;

end




%% in case we ever need a different method to get all trials

  %loop through each session of the variable and compute rolling average
    %for nSession = 1:length(variable)
        %masterRollAve(nSession).(strcat('rolling',T.Properties.VariableNames{selection(nVar)})) = movmean(variable{nSession},k);
    %end


end




