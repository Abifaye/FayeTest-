%% Data Cleaning
load masterTable_allLuminanceTrials.mat

% Test
for nSession = 1:size(T,1)
    RTs = cell2mat(T.allRTs(nSession));
    if max(RTs) > 100000
        errorTrials(nSession) = sum(RTs > 100000);
    else 
        errorTrials(nSession) = 0;
    end
end
maxErr = max(errorTrials); %max is only 4, therefore did not completely remove any sessions


%Data Cleaning

for nSession = 1:size(T,1)
    RTs = cell2mat(T.allRTs(nSession));
    if max(RTs) > 100000 

        if max(RTs(find(cell2mat(T.hit(nSession))==1 & cell2mat(T.optoPowerMW(nSession))~=0))) > 100000
            B = RTs(find(cell2mat(T.hit(nSession))==1 & cell2mat(T.optoPowerMW(nSession))~=0)); %CHANGE THE NAME OF B
            hitProfs = T.hitProfiles(nSession);
            hitProfs(find(B > 100000)) = [];
        end

        for var = [49:53 55:56]
            A = cell2mat(T.(var)(nSession)); %CHANGE NAME OF A
            A(find(RTs > 100000)) = [];
            T.(var)(nSession) = {A};
        end

        RTs(RTs > 100000) = []; %must be last because you need it as reference for indexing to other variables
        T.allRTs(nSession) = {RTs};

    else
        continue
    end

end

%% Save
save('masterTable_allLuminanceCleaned.mat',"T")




