function getrandSessionTest
%% Initialize variables 
%get all functions that provides data
masterRollAve = getrollingAverage; %select rewards and allRTs
masterRollRates = getrollingrates; %select fa, miss, and hit

%% Testing for Patterns in Individual Variables
%generate temporary master table with rolling
%select variables dialogue for selecting variables to look at from master table
selection = listdlg('PromptString',{'Select variable(s) to compute','rolling rate'},'ListString', ...
    masterDBDataTable.Properties.VariableNames,'SelectionMode','multiple');
%loop through each variable of interest in the table
for nVar = 1:length(selection)
    var = masterDBDataTable.(masterDBDataTable.Properties.VariableNames{selection(nVar)});

    %random num picker every 100th session the animal does
    total_range = length(var);% Define the total range
    step_size = 100; % Define the step size
    numIterations = 5;%define how many numbers you want to iterate
    randNums = [];%init var for random numbres
    % Generate 5 random numbers within each 100th range
    for nIteration = 1:5
        % Calculate the start and end of each range
        start_range = (nIteration - 1) * step_size + 1;
        end_range = nIteration * step_size;
        %if the end range goes beyond the total nunber of sessions default
        %it as the last session
        if end_range>=400
            end_range = length(var);
        end
        % Generate a random number within the current range
        randNums(nIteration) = randi([start_range end_range], 1, 1);
    end

    %loop through sessions indicated by the random picker
    for nSession = 1:length(randNums)
        %convert session cell to matrix to see all trials
        session_matrix = cell2mat(var(randNums(nSession)));
    end
end
%plot
figure;
scatter(1:length(session_matrix),session_matrix,'.')
title(strcat(masterDBDataTable.Properties.VariableNames{selection(nVar)},' session',append(' ',string(randNums(nSession)))))
end