function [firstPros,secondPros,thirdPros] = getTertile
%Splits RTs into tertile and takes the corresponding
%hit profiles

%% Initialize variables
%Go to folder containing hit profiles
cd 'E:\School\Psyc 504\FayeTest-'
%load masterTable file to be able to use getmasterRTs
load('TablewithHitProfiles.mat');
%init locations for top + btm profiles
firstPros = zeros();
secondPros = zeros();
thirdPros = zeros();
%init counters for determining where to put profiles
Counterfirst = 1;
Countersecond = 1;
Counterthird = 1;

%% Create loop for getting hit profiles and putting them in tertile matrices
%loop through all sessions
for nSession = 1:height(TablewithHitProfiles)
    RTs = cell2mat(TablewithHitProfiles.stimCorrectRTs(nSession));
    hitPros = cell2mat(struct2cell(TablewithHitProfiles.HitProfiles(nSession)));
    %Create logical index for the tertile RTs. prctile function
    %creates range for tertiles
    firstIdx = (RTs >= min(prctile(RTs,[0 33.33])) & RTs <= max(prctile(RTs,[0 33.33])));
    secondIdx =(RTs > min(prctile(RTs,[33.34 66.67])) & RTs <= max(prctile(RTs,[33.34 66.67])));
    thirdIdx = (RTs > min(prctile(RTs,[66.68 100])) & RTs <= max(prctile(RTs,[66.68 100])));
    %loops through all trials
    
    for nTrial = 1:length(RTs)
        
        %if current trial is in first tertile
        if firstIdx(nTrial) == 1
           %place corresponding hit profile in topPros matrix
            firstPros(Counterfirst,1:width(hitPros)) = hitPros(nTrial); 
            %increase height of matrix if a profile gets added
            Counterfirst = 1 + height(firstPros); 
         
            %if current trial is in second tertile
        elseif secondIdx(nTrial) == 1
             %place corresponding hit profile in topPros matrix
            secondPros(Countersecond,1:width(hitPros)) = hitPros(nTrial);
            %increase height of matrix if a profile gets added
            Countersecond = 1 + height(secondPros);
        
            %if current trial is in second tertile
        elseif thirdIdx (nTrial)  == 1 
            %place corresponding hit profile in btmPros matrix
            thirdPros(Counterthird,1:width(hitPros)) = hitPros(nTrial); 
            %increase height of matrix if a profile gets added
            Counterthird =  1 + height(thirdPros); 
        end
    end
end
end