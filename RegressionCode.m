%Summary:

%% Get Dataset
%Go to folder containing master table
folderPath = uigetdir('', 'Go to folder containing master table');
load(uigetfile('','Select desired master table'));


%% Option 1: eggression Model RTs

% Create loop for getting hit profiles and RTs

%init vars
RTs = [];
hitPros = [];
stimHits = [];


% Create loop for getting hit profiles and putting them in each Tertile matrix

%loop through all sessions
for nSession = 1:height(T)

    %create variables for hit profiles and reaction times from the master
    %table
    RTs = [RTs; cell2mat(T.stimCorrectRTs(nSession))'];
    hitPros = horzcat(hitPros,cell2mat(T.hitProfiles(nSession))');

end

%create dataset table for regression model
%dsa = table(RTs,hitPros','VariableNames',{'RTs','HitPros'});

%fit into regression model
mdl = fitglm(hitPros',RTs,'linear','Distribution','normal');

%% Option 2: Binomial Regression
%init vars
hitPros = [];
missPros = [];
hits =[];
miss = [];

%create loop for getting hit and miss profiles plus stimulated hits and
%miss outcomes from each session
for nSession = 1:height(T)
    
    %hits and miss profiels
    hitPros = horzcat(hitPros,cell2mat(T.hitProfiles(nSession))');
    missPros = horzcat(missPros,cell2mat(T.missProfiles(nSession))');

    %hits and miss outcomes

    %init temporary vars
    sessHits = [];
    sessMiss = [];
    sessoptoPower = [];

    %grab data of all vars for each session
    sessHits = [T.hit{nSession}];
    sessMiss = [T.miss{nSession}];
    sessoptoPower = [T.optoPowerMW{nSession}];
    
    %grab stimulated outcomes
    hits = horzcat(hits,sessHits(sessHits==1 & sessoptoPower~=0));
    miss = horzcat(miss,sessMiss(sessMiss==1 & sessoptoPower~=0));

end

%recode misses as zeros
miss(1:end) = repmat(0,size(miss,1),size(miss,2));

%combine outcomes
outcomes = logical([hits'; miss']);

%combine Profiles
comboPros = [hitPros'; -missPros'];

%conduct regression model
mdl = fitglm(comboPros, outcomes,'Distribution','binomial','Link','logit'); 
