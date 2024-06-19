%Summary:

%% For Reaction Time 
%Go to folder containing master table
folderPath = uigetdir('', 'Go to folder containing master table');
load(uigetfile('','Select desired master table'));

% Create loop for getting hit profiles and RTs

%init vars
RTs = [];
hitPros = [];
stimHits = [];


%% Create loop for getting hit profiles and putting them in each Tertile matrix

%loop through all sessions
for nSession = 1:height(T)

    %create variables for hit profiles and reaction times from the master
    %table
    RTs = [RTs; cell2mat(T.stimCorrectRTs(nSession))'];
    hitPros = horzcat(hitPros,cell2mat(T.hitProfiles(nSession))');

end

%create dataset table for regression model
%dsa = table(RTs,hitPros','VariableNames',{'RTs','HitPros'});

%% Reggression Model
%fit into regression model
mdl = fitglm(hitPros',RTs,'linear','Distribution','normal');

%% Binomial Regression

mdl = fitglm(hitidx,comboPros,'Distribution','binomial','logit'); %need to get rid of false alarms in the hitidx 
