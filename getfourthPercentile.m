function [firstPros,thirdPros] = getfourthPercentile
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
%init locations for top + btm profiles
firstPros = zeros();
secondPros = zeros();
thirdPros = zeros();
fourthPros = zeros();
%init counters for determining where to put profiles
Counterfirst = 1;
Countersecond = 1;
Counterthird = 1;
Counterfourth = 1;

%% Create loop for getting hit profiles and putting them in topPros/btmPros matrix
for nSession = 1:height(TablewithHitProfiles)
    RTs = cell2mat(TablewithHitProfiles.stimCorrectRTs(nSession));
    hitPros = cell2mat(struct2cell(TablewithHitProfiles.HitProfiles(nSession)));
    %Create logical index for the top + btm percentile of RTs. prctile function
    %creates range for top and bottom percentile
    firstIdx = (RTs >= min(prctile(RTs,[0 25])) & RTs < max(prctile(RTs,[0 25])));
    secondIdx =(RTs >= min(prctile(RTs,[25.01 50])) & RTs < max(prctile(RTs,[25.01 50])));
    thirdIdx = (RTs >= min(prctile(RTs,[50.01 75])) & RTs <= max(prctile(RTs,[50.01 75])));
    fourthIdx = (RTs >= min(prctile(RTs,[75.01 100])) & RTs <= max(prctile(RTs,[75.01 100])));
    for nTrial = 1:length(RTs) %loops through all hit profiles
        if firstIdx(nTrial) == 1 %if current trial is in top half percentile
            firstPros(Counterfirst,1:width(hitPros)) = hitPros(nTrial); %place
            %corresponding hit profile in topPros matrix
            Counterfirst = 1 + height(firstPros); %increase height of matrix if a profile gets added
        elseif secondIdx(nTrial) == 1
            secondPros(Countersecond,1:width(hitPros)) = hitPros(nTrial); %place
            %corresponding hit profile in topPros matrix
            Countersecond = 1 + height(secondPros);
        elseif thirdIdx (nTrial)  == 1 %if current trial is in btm half percentile
            thirdPros(Counterthird,1:width(hitPros)) = hitPros(nTrial); %place
            %corresponding hit profile in btmPros matrix
            Counterthird =  1 + height(thirdPros); %increase height of matrix if a profile gets added
        elseif thirdIdx (nTrial)  == 1 %if current trial is in btm half percentile
            thirdPros(Counterthird,1:width(hitPros)) = hitPros(nTrial); %place
            %corresponding hit profile in btmPros matrix
            Counterthird =  1 + height(thirdPros); %increase height of matrix if a profile gets added
        end
    end
end
endfunction [outputArg1,outputArg2] = untitled2(inputArg1,inputArg2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

