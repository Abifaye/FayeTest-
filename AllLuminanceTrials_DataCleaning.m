%% Data Cleaning
load masterTable_allLuminanceTrials.mat

% Test if the number of errors in a session is significant enough to
% warrant completely removing the session altogether
for nSession = 1:size(T,1) %loop through each session
    RTs = cell2mat(T.allRTs(nSession)); %get RTs for all trial
    if max(RTs) > 100000 %determines if there is error by seeing if there is any value greater than the set value for a miss (100000)
        errorTrials(nSession) = sum(RTs > 100000); %obtains total number of error trials
    else 
        errorTrials(nSession) = 0; %if there are no error trials
    end
end
maxErr = max(errorTrials); %max is only 4, therefore did not completely remove any sessions


%Data Cleaning Loop

for nSession = 1:size(T,1) %loop through each sessions
    RTs = cell2mat(T.allRTs(nSession)); %get RTs for all trial
    if max(RTs) > 100000 %determines if there are any error trials in the session
%profile cleaning
        if max(RTs(find(cell2mat(T.hit(nSession))==1 & cell2mat(T.optoPowerMW(nSession))~=0))) > 100000 %only hit trials with optopowers are used for hit profiles
            errRTs = RTs(find(cell2mat(T.hit(nSession))==1 & cell2mat(T.optoPowerMW(nSession))~=0)); %identify terials with error RTs
            hitProfs = T.hitProfiles(nSession); %get all hit profiles corresponding to nSession
            hitProfs(find(errRTs > 100000)) = []; %remove hit profiles of trials with error RTs
        end
%individual data cleaning for hits, misses, FAs, and rewards
        for var = [49:53 55:56]
            session_var = cell2mat(T.(var)(nSession)); %put data of particular var and session into a matrix
            session_var(find(RTs > 100000)) = []; %delete trials with error RTs
            T.(var)(nSession) = {session_var}; %input the cleaned session back to the table
        end
%indiv data cleaning for RTs
        RTs(RTs > 100000) = []; %must be last because you need it as reference for indexing to other variables
        T.allRTs(nSession) = {RTs}; %put cleaned RTs back into table

    else
        continue
    end

end

%% Save

%save('masterTable_allLuminanceCleaned.mat',"T")




