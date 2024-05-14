function getMissStreaks
%Summary: Goes into the desired master table and counts the consecutive
%miss outcomes and places these counts into a matrix. Kernels of trials
%corresponding to >2+ miss streaks are then plotted. 

%load the desired master table
load(uigetfile('','Choose the desired master table'))

%init variables required from table
hitTrials = [T.hit];
missTrials = [T.miss];
optoPowers = [T.optoPowerMW];
hitPros = [T.hitProfiles];
missPros = [T.missProfiles];

%% Get the miss streaks

%init cell for containing all miss streaks records
streaksCell = {};


%loop through each session
for nSession = 1:length(missTrials)

    %init temp matrix for each session
    sessOutcomes = []; %for trials
    sessOutcomes = missTrials{nSession};
    sessStreaks = []; % for miss streaks

    %init streak counter for counting consecutive miss
    streakCounter = 0;

    %loop through each trial
    for nTrial = 1:length(sessOutcomes)

        %add to the miss streaks in the session matrix if there is a miss 
        if sessOutcomes(nTrial)==1 %if including FAs enter 0
            streakCounter = streakCounter+1;
            sessStreaks(nTrial) = streakCounter;
            %reset the miss streaks to zero if the outcome is not a miss
        else
            streakCounter = 0;
            sessStreaks(nTrial) = streakCounter;
        end

    end
    %add entire session streak counts to the streak cell
    streaksCell{nSession} = sessStreaks;

end

%% Filter the streaksCell so that only trials with miss outcome are remaining because that is the kernel profiles being looked at

%miss

%init new cell for miss outcomes containing new filtered data for all sessions
missStreakCell = {};

%loop through each session
for nSession = 1:length(missTrials)

    %init temp matrix for each session
    sessStreaks = [];
    sessStreaks =  streaksCell{nSession};
    sessOpto = [];
    sessOpto = optoPowers{nSession};
    sessMiss = missTrials{nSession};
    %filter the streaks in the session to contain only those from stimulated miss
    %trials
    sessStreaks = sessStreaks(sessOpto~=0 & sessMiss==1);
    %place new data in the miss streaks cell
    missStreakCell{nSession} = sessStreaks;

end

%% Plot Kernels

%convert variables into matrices
hitProsMat = cell2mat(hitPros);
missProsMat = cell2mat(missPros);
misstreakMat = cell2mat(missStreakCell);

%decide on which profiles to call (i.e. only those with 2+ consecutive miss
%streaks, etc)
streakCount = input('How many consecutive miss streaks: ');
%get the miss profiles with the corresponding number of miss streaks
comboPros = (-missProsMat(misstreakMat<=streakCount,:))/2 + 0.5; 

%Plot
figure;
plot(mean(comboPros))
title(strcat(string(streakCount),' or Less Miss Streak')) %copy paste " with FA" exactly if want to add with FA


end