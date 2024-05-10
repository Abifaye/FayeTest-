function [labelTable] = getLabelTable
%Creates a table that contains date, trial end, and animal labels for all
%luminance trials and sessions

%% Create Labels for Data
%load master table
load(uigetfile('Choose Master Table Containing Raw Data')); 

%% Init vars
labelTable= table();
animal = [];
Date = [];
trialEnd = [];
optoPower = [];

%% Date and Animal Labels
for nSession = 1:size(T,1) %loop through each session
    sessionTrialEnds = cell2mat(T.miss(nSession))'; %get all trials from session either from hit/miss/fa logical
    %set date + animal for session as same for each trial 
    Date = [Date; repmat(T.(2)(nSession), 1, size(sessionTrialEnds,1))']; 
    animal = [animal; repmat(T.(1)(nSession), 1, size(sessionTrialEnds,1))']; 
end

%% Trialend Labels
for nSession = 1:size(T,1) %loop through each session
    %init table for trialends logical of each session
    sessionTrialEnds = table(); 
    sessionTrialEnds.miss = cell2mat(T.miss(nSession))'; 
    sessionTrialEnds.hit = cell2mat(T.hit(nSession))';
    sessionTrialEnds.fa = cell2mat(T.hit(nSession))';
    trialEndSession = []; %init var for trialend labels for each session
    %loop through each trial and assign hit/miss/fa based on logical
    for nTrial = 1:size(sessionTrialEnds.miss,1) 
        if sessionTrialEnds.miss(nTrial) == 1
            trialEndSession =  [trialEndSession; "miss"];
        elseif sessionTrialEnds.hit(nTrial) == 1
            trialEndSession =  [trialEndSession; "hit"];
        else sessionTrialEnds.fa(nTrial) == 1 
            trialEndSession =  [trialEndSession; "fa"];
        end
    end
    trialEnd = [trialEnd; trialEndSession]; %append each session's labels to trialEnd var
end

%% OptoPower Label
for nSession = 1:size(T,1)
    optoPower = [optoPower; cell2mat(T.optoPowerMW(nSession))'];
end


%% Combine all labels into one table
labelTable.animal = animal;
labelTable.date = Date;
labelTable.trialEnd = trialEnd;
labelTable.optoPower = optoPower;
end