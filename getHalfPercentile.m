function [topPros,btmPros] = getHalfPercentile
%Splits RTs into top and bottom half percentile and takes the corresponding
%hit profiles

%% Initialize variables
%Go to folder containing hit profiles
cd 'E:\School\Psyc 504\FayeTest-'
%load master table with hit profiles file 
load('TablewithHitProfiles.mat');
%getmasterRTs
%init locations for top + btm profiles
topPros = zeros();
btmPros = zeros();
%init counters for determining where to put profiles
CounterTop = 1;
CounterBtm = 1;
%% Create loop for getting hit profiles and putting them in topPros/btmPros matrix
%loop through all sessions
for nSession = 1:height(TablewithHitProfiles)
    %create variables for hit profiles and reaction times from the master
    %table
    RTs = cell2mat(TablewithHitProfiles.stimCorrectRTs(nSession));
    hitPros = cell2mat(struct2cell(TablewithHitProfiles.HitProfiles(nSession)));
    %Create logical index for the top + btm percentile of RTs. prctile function
    %creates range for top and bottom percentile
    topIdx = (RTs >= min(prctile(RTs,[0 50])) & RTs <= max(prctile(RTs,[0 50])));
    btmIdx = (RTs > min(prctile(RTs,[50.01 100])) & RTs <= max(prctile(RTs,[50.01 100])));
    %loops through all trials in current session
    
    for nTrial = 1:length(RTs)
        
        %if current trial is in top half percentile
        if topIdx(nTrial) == 1
            %place corresponding hit profile in topPros matrix
            topPros(CounterTop,1:width(hitPros)) = hitPros(nTrial);
            %increase height of matrix if a profile gets added
            CounterTop = 1 + height(topPros);
           
            %if current trial is in btm half percentile
        elseif btmIdx (nTrial)  == 1
            %place corresponding hit profile in btmPros matrix
            btmPros(CounterBtm,1:width(hitPros)) = hitPros (nTrial);
            %increase height of matrix if a profile gets added
            CounterBtm =  1 + height(btmPros);
        end
    end
end
end