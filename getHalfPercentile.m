function [topPros,btmPros] = getHalfPercentile
%Splits RTs into top and bottom half percentile and takes the corresponding
%hit profiles
%% Initialize variables
%Go to folder containing hit profiles
cd 'C:\Users\afbar\OneDrive - University of Calgary\Documents\OneDrive\Documents\Psyc 504\Coding\FayeTest-\Stim Profiles'
%get hitProsloc function to get all hit profiles
hitPros = gethitProsloc(pwd);
%go back to previous folder to access getmasterRTs function
cd 'C:\Users\afbar\OneDrive - University of Calgary\Documents\OneDrive\Documents\Psyc 504\Coding\FayeTest-';
%load masterTable file to be able to use getmasterRTs
load('masterTable.mat');
%getmasterRTs
RTs = getmasterRTs(T);
%Create logical index for the top + btm percentile of RTs. prctile function
%creates range for top and bottom percentile
topIdx = (RTs >= min(prctile(RTs,[0 50])) & RTs < max(prctile(RTs,[0 50])));
btmIdx = (RTs >= min(prctile(RTs,[50.01 100])) & RTs <= max(prctile(RTs,[50.01 100])));
%init locations for top + btm profiles
topPros = zeros();
btmPros = zeros();
%init counters for determining where to put profiles
CounterTop = 1;
CounterBtm = 1;
%% Create loop for getting hit profiles and putting them in topPros/btmPros matrix
for nTrial = 1:height(hitPros) %loops through all hit profiles
    if topIdx(nTrial) == 1 %if current trial is in top half percentile
        topPros(CounterTop,1:width(hitPros)) = hitPros (nTrial); %place
        %corresponding hit profile in topPros matrix
        CounterTop = 1 + height(topPros); %increase height of matrix if a profile gets added
    elseif btmIdx (nTrial)  == 1 %if current trial is in btm half percentile
        btmPros(CounterBtm,1:width(hitPros)) = hitPros (nTrial); %place
        %corresponding hit profile in btmPros matrix
        CounterBtm =  1 + height(btmPros); %increase height of matrix if a profile gets added
    end
end
end