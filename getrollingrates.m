function [masterRollRates] = getrollingrates
%Computes the rolling average for variables of interest from
%master table and returns a table containing rolling rates for each
%variable

%load master table file
load('masterTable_complete.mat');

%% Variables Init
%select variables dialogue for selecting variables from master table to
%compute rolling rate (i.e. miss,fa,hits)
selection = listdlg('PromptString',{'Select variable(s) to compute', ...
    'rolling rate'},'ListString', ...
    T.Properties.VariableNames,'SelectionMode','multiple');

%init variable for rolling rates table
masterRollRates = table();

%Command window dialgoue for how many trials should be used as window
%length for the rolling rate
k = input(strcat('Input Window Length for Rolling Rate',32)); %code 32 = space

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
        %is true, else false
        for nSession = 1:size(T,1)
            denom{nSession} = T.(T.Properties.VariableNames{denomSelection(1)}){nSession} == 1|...
                T.(T.Properties.VariableNames{denomSelection(2)}){nSession} == 1;
        end

        %init temporary matrix and a
        %counter to help append the next set of trials each session
        counter = 0;
        tempMat = [];

        %loop through each session
        for nSession = 1:size(T,1)
            %calculate rolling sum of numerator and denomenator
            rollNum = movsum(num{nSession},30);
            rollDenom = movsum(denom{nSession},30);
            %calculate rolling rate and input into tempMat
            tempMat(counter+1:counter+length(num{nSession}),1) =...
                (rollNum./rollDenom).*100; %sum num/(sum denom) * 100
            %adjust counter
            counter = counter + length(num{nSession});
        end

        %create labeled column for corresponding variable and place data from
        %temporary matrix into the column
        masterRollRates.(strcat('rolling',T.Properties.VariableNames{selection(nVar)},'rate')) = tempMat;

    %if denominator consists of 3 variables
    elseif length(denomSelection) == 3

        counter = 0;
        tempMat = [];

        for nSession = 1:size(T,1)
            rollNum = movsum(num{nSession},30);
            %use k for denom as all trials are included
            tempMat(counter+1:counter+length(num{nSession}),1) = (rollNum./k).*100;
            counter = counter + length(num{nSession});
        end

        masterRollRates.(strcat('rolling',T.Properties.VariableNames{selection(nVar)},'rate')) = tempMat;


    end
end

end