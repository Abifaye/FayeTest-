function [masterRollAve] = getrollingAverage
%Computes the rolling average for variables of interest from
%master table and returns a table containing rolling averages for each
%variable

%load master table
load('masterTable_allLuminanceCleaned.mat');

%select variables dialogue for selecting variables from master table to
%compute rolling average (i.e. rewards, allrts)
selection = listdlg('PromptString',{'Select variable(s) to compute', ...
    'rolling average'},'ListString',T.Properties.VariableNames,'SelectionMode','multiple');

%init variable for rolling averages table
masterRollAve = table();

%Command window dialgoue for how many trials should be used as window
%length for the rolling averages
k = input(strcat('Input Window Length for Rolling Average:',32)); %code 32 = space


%loop through each selected variable
for nVar = 1:length(selection)
    variable = [T.(T.Properties.VariableNames{selection(nVar)})];

    if strcmp(T.Properties.VariableNames{selection(nVar)},T.Properties.VariableNames{54})
        tempContainer = [];
        tempRTs = [];
        subSelect = input(strcat('Use all RTs or only hit RTs [0=all/1=hits]',32));
        if subSelect==0
            for nSession = 1:size(T,1)
                tempContainer = variable{nSession};
                tempContainer(tempContainer==100000) = 0;
                variable{nSession} = tempContainer;
            end
        elseif subSelect==1
            for nSession = 1:size(T,1)
                hitIdx = [T.hit{nSession}];
                tempContainer = variable{nSession};
                hitEst = 0;%SHOULD IT START WITH ZERO
                for nTrial = 1:length(tempContainer)
                    if hitIdx(nTrial)==1
                        hitEst = tempContainer(nTrial);

                    for nTrial = 1:length(tempContainer)
                        if hitIdx(nTrial)==1 %% left off here!!!
                        hitEst = tempContainer(nTrial);
                hitEst = 0;
                for nTrial = 1:length(tempContainer)
                    if hitIdx(nTrial)==1
                        hitEst = tempContainer(nTrial);
                        tempRTs(nTrial) = hitEst;
                    else
                        tempRTs(nTrial) = hitEst;
                    end
                end
                variable{nSession} = tempRTs;
            end

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
    end



    %% in case we ever need a different method to get all trials

    %loop through each session of the variable and compute rolling average
    %for nSession = 1:length(variable)
    %masterRollAve(nSession).(strcat('rolling',T.Properties.VariableNames{selection(nVar)})) = movmean(variable{nSession},k);
    %end


end




