function [masterRollRates] = getrollingrates
%Computes the rolling average for variables of interest from
%master table and returns a table containing rolling rates for each
%variable

%load master table file
load('masterTable_allLuminanceCleaned.mat');

%% Variables Init
%select variables dialogue for selecting variables from master table to
%compute rolling rate
selection = listdlg('PromptString',{'Select variable(s) to compute', ...
    'rolling rate'},'ListString', ...
    T.Properties.VariableNames,'SelectionMode','multiple');

%init variable for rolling rates table
masterRollRates = table();

%Command window dialgoue for how many trials should be used as window
%length for the rolling rate
k = input(strcat('Input Window Length for Rolling Rate:',32)); %code 32 = space


trialsOrSessions = input(strcat('Combined rolling average or session by session averages? [combined=0/sessions=1]:',32)); %code 32 = space

%% For Loop for retrieving rolling rates of all trials

%Loop through each variable of interest
for nVar = 1:length(selection)

    %init numerator (the variable of interest)
    num = [T.(T.Properties.VariableNames{selection(nVar)})];

    %select variable(s) for denominator
    denomSelection = listdlg('PromptString',{'Select Denominator for', ...
        strcat(T.Properties.VariableNames{selection(nVar)},32,'rate')},'ListString',T.Properties.VariableNames, ...
        'SelectionMode','multiple','Name','Select Variable');

    %if denominator consists of 2 variables
    if length(denomSelection) == 2
        %create a new logical that considers occurence of either variable
        %being true, else false
        for nSession = 1:size(T,1)
            denom{nSession} = T.(T.Properties.VariableNames{denomSelection(1)}){nSession} == 1|...
                T.(T.Properties.VariableNames{denomSelection(2)}){nSession} == 1;
        end

        if trialsOrSessions==0
            %init temporary matrix and a counter to help append the next set of trials for each session
            counter = 0;
            tempMat = [];
            rollNum = [];
            rollDenom = [];
            %loop through each session
            for nSession = 1:size(T,1)
                %calculate rolling sum of numerator and denomenator
                rollNum = movsum(num{nSession},k);
                rollDenom = movsum(denom{nSession},k);
                %calculate rolling rate and input into tempMat
                tempMat(counter+1:counter+length(num{nSession}),1) =...
                    (rollNum./rollDenom).*100; %sum num/(sum denom) * 100
                %adjust counter
                counter = counter + length(num{nSession});
            end

            %create labeled column for corresponding variable and place data from
            %temporary matrix into the column
            masterRollRates.(strcat('rolling',T.Properties.VariableNames{selection(nVar)},'rate')) = tempMat;
        elseif trialsOrSessions==1
            for nSession = 1:size(T,1)
                rollNum = movsum(num{nSession},k);
                rollDenom = movsum(denom{nSession},k);
                masterRollRates.(strcat('rolling',T.Properties.VariableNames{selection(nVar)})){nSession} = (rollNum./rollDenom).*100;
            end
        end

        %if denominator consists of 3 variables
    elseif length(denomSelection) == 3

        if trialsOrSessions==0

            counter = 0;
            tempMat = [];

            for nSession = 1:size(T,1)
                rollNum = movsum(num{nSession},k);
                %use k for denom as all trials are included
                tempMat(counter+1:counter+length(num{nSession}),1) = (rollNum./k).*100;
                counter = counter + length(num{nSession});
            end
            masterRollRates.(strcat('rolling',T.Properties.VariableNames{selection(nVar)},'rate')) = tempMat;

        elseif trialsOrSessions==1
            for nSession = 1:size(T,1)
                rollNum = movsum(num{nSession},k);
                %use k for denom as all trials are included
                masterRollRates.(strcat('rolling',T.Properties.VariableNames{selection(nVar)})){nSession} = (rollNum./k).*100;
            end

        end
    end

end