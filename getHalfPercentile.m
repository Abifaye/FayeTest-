function [topPros,btmPros] = getHalfPercentile
%Splits RTs into top and bottom half percentile and takes the corresponding
%hit profiles
%% Initialize variables
%Go to folder containing hit profiles
cd 'E:\School\Psyc 504\FayeTest-'
%get hitProsloc function to get all hit profiles
%hitPros = gethitProsLoc;
%go back to previous folder to access getmasterRTs function
%cd 'E:\School\Psyc 504\FayeTest-\Stim Profiles';
%load masterTable file to be able to use getmasterRTs
load('TablewithHitProfiles.mat');
%getmasterRTs
%init locations for top + btm profiles
topPros = zeros();
btmPros = zeros();
%init counters for determining where to put profiles
CounterTop = 1;
CounterBtm = 1;
for nSession = 1:height(TablewithHitProfiles)
    RTs = cell2mat(TablewithHitProfiles.stimCorrectRTs(nSession));
    hitPros = cell2mat(struct2cell(TablewithHitProfiles.HitProfiles(nSession)));
    %Create logical index for the top + btm percentile of RTs. prctile function
    %creates range for top and bottom percentile
    topIdx = (RTs >= min(prctile(RTs,[0 50])) & RTs <= max(prctile(RTs,[0 50])));
    btmIdx = (RTs > min(prctile(RTs,[50.01 100])) & RTs <= max(prctile(RTs,[50.01 100])));
    %% Create loop for getting hit profiles and putting them in topPros/btmPros matrix
    for nTrial = 1:length(RTs) %loops through all hit profiles in current session
        if topIdx(nTrial) == 1 %if current trial is in top half percentile
            topPros(CounterTop,1:width(hitPros)) = hitPros(nTrial); %place
            %corresponding hit profile in topPros matrix
            CounterTop = 1 + height(topPros); %increase height of matrix if a profile gets added
        elseif btmIdx (nTrial)  == 1 %if current trial is in btm half percentile
            btmPros(CounterBtm,1:width(hitPros)) = hitPros (nTrial); %place
            %corresponding hit profile in btmPros matrix
            CounterBtm =  1 + height(btmPros); %increase height of matrix if a profile gets added
        end
    end
end
end