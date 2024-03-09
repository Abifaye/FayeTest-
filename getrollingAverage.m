function [masterRollAve] = getrollingAverage
%Computes the rolling average for variables of interest from
%master table and returns a table containing rolling averages for each
%variable

%load master table
load(uigetfile('Choose Master Table Containing Raw Data')); 

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
        subSelect = input(strcat('Use all RTs or only hit RTs [0=all/1=hits]:',32));
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
                RTsRevised = [];
                hitEst = 0;
                for nTrial = 1:length(tempContainer)
                    if hitIdx(nTrial)==1
                        hitEst = tempContainer(nTrial);
                        RTsRevised(RTsRevised==0)= hitEst;
                    end
                    RTsRevised(nTrial) = hitEst;
                end
                variable{nSession} = RTsRevised;
            end
        end
    end

    %init counter and temporary matrix
    counter = 0;
    tempMat = [];

    trialsOrSessions = input(strcat('Combined rolling average or session by session averages? [combined=0/sessions=1]:',32)); %code 32 = space
    if trialsOrSessions==0
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
   
    elseif trialsOrSessions==1
        for nSession = 1:length(variable)
            masterRollAve.(strcat('rolling',T.Properties.VariableNames{selection(nVar)})){nSession} = movmean(variable{nSession},k);
        end

    end
end
%% Extra Stuff for revision of currently existing data
%masterDBDataTable.rollingallRTs = masterRollAve.rollingallRTs;
%save("masterDBDataTable_hitsRTs.mat","masterDBDataTable")
%normData = normalize(masterDBDataTable(:,5:9));
%save("normData_hitRTs.mat","normData")

end



