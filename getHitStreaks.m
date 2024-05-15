function getHitStreaks
%Summary: Goes into the desired master table and counts the consecutive hit
%outcomes and places these counts into a matrix. Kernels of trials
%corresponding to >2+ hit streaks are then plotted. Can either consider
%only hit outcomes, or also add FA trials

%load the desired master table
load(uigetfile('','Choose the desired master table'))

%init variables required from table
hitTrials = [T.hit];
missTrials = [T.miss];
optoPowers = [T.optoPowerMW];
hitPros = [T.hitProfiles];
missPros = [T.missProfiles];

%% Get the hit streaks

%init cell for containing all hit streaks records
streaksCell = {};

%determine whether to include FAs or not
FAorNot = input('include FAs or not? [1=Yes/0=No]: '); %if want to include FAs use miss trials

%loop through each session
for nSession = 1:length(hitTrials)

    %init temp matrix for each session
    sessHits = []; %for trials
    sessMiss = []; %for trials
    sessStreaks = []; % for hit streaks

    if FAorNot==1 %include FAs
        sessHits = hitTrials{nSession};
        sessMiss = missTrials{nSession};

        %init streak counter for counting consecutive hits
        streakCounter = 0;

        %loop through each trial
        for nTrial = 1:length(sessHits)

            %add to the hit streaks in the session matrix if there is a hit (or
            %hits + FAs)
            if sessHits(nTrial)==1 %if hit outcome
                streakCounter = streakCounter+1; % add to streak count
                sessStreaks(nTrial) = streakCounter;
                %reset the hit streaks to zero if the outcome is not a hit (or
                %if it is a miss when considering FAs)
            elseif sessMiss(nTrial)==0 && sessHits(nTrial)==0 %if FA outcome
                sessStreaks(nTrial) = 0; %label trial as zero, but do not restart streak count

            else %if miss
                streakCounter = 0; %restart streak count to zero
                sessStreaks(nTrial) = streakCounter;
            end

        end

    else %do not include FAs
        sessHits = hitTrials{nSession};

        %init streak counter for counting consecutive hits
        streakCounter = 0;


        %loop through each trial
        for nTrial = 1:length(sessHits)

            %add to the hit streaks in the session matrix if there is a hit (or
            %hits + FAs)
            if sessHits(nTrial)==1
                streakCounter = streakCounter+1;
                sessStreaks(nTrial) = streakCounter;
                %reset the hit streaks to zero if the outcome is not a hit (or
                %if it is a miss when considering FAs)
            else
                streakCounter = 0;
                sessStreaks(nTrial) = streakCounter;
            end

        end

    end

    %add entire session streak counts to the streak cell
    streaksCell{nSession} = sessStreaks;

end

%% Filter the streaksCell so that only trials with hit outcome are remaining because that is the kernel profiles being looked at

%hits

%init new cell for hit outcomes containing new filtered data for all sessions
hitStreakCell = {};

%loop through each session
for nSession = 1:length(hitTrials)

    %init temp matrix for each session
    sessStreaks = [];
    sessStreaks =  streaksCell{nSession};
    sessOpto = [];
    sessOpto = optoPowers{nSession};
    sessHits = hitTrials{nSession};
    %filter the streaks in the session to contain only those from stimulated hit
    %trials
    sessStreaks = sessStreaks(sessOpto~=0 & sessHits==1);
    %place new data in the hit streaks cell
    hitStreakCell{nSession} = sessStreaks;

end


%% Plot Kernels

%convert variables into matrices
hitProsMat = cell2mat(hitPros);
missProsMat = cell2mat(missPros);
hitStreakMat = cell2mat(hitStreakCell);


%decide on which profiles to call (i.e. only those with 2+ consecutive hit
%streaks, etc)
streakCount = input('How many consecutive hit streaks: ');
%combine hit and inverse miss profiles
comboPros = (hitProsMat(hitStreakMat>=streakCount,:))/2 + 0.5; %missProsMat(misstreakMat>=streakCount) OR -missProsMat OR /2 + 0.5;

%Plot
figure;
plot(mean(comboPros))
title(strcat(string(streakCount),' or Less', ' Streak', input('Please enter either " with FA" or leave blank: '))) %copy paste " with FA" exactly if want to add with FA


end
