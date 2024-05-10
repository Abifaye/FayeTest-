function [masterdprimes,mastercriterion] = getmasterdprimes_criterions
%A vector for all the RTs for Correct Responses 
% inputs into the Master table (T) and outputs a vector containing dprimes for all sessions + trials 
% inputs into the Master table (T) and outputs a vector containing c for all sessions + trials 

%Go to folder containing master table
folderPath = uigetdir();

%load table containing dprimes and criterions from folder
load('masterTable.mat');

%% Create a Vector of the dprimes
%preallocate vector for all dprimes
masterdprimes = []; 
%put all topUp dprimes into vector
masterdprimes(1:length([T.topUpC]),1) = [T.topUpDPrime]; 
%add in stimulated dprimes into vector
masterdprimes(length(masterdprimes)+1:length(masterdprimes)+length([T.stimDPrime]),1) = [T.stimDPrime];
%add in non-stimulated dprimes into vector
masterdprimes(length(masterdprimes)+1:length(masterdprimes)+length([T.noStimDPrime]),1) = [T.noStimDPrime];

%% Create a Vector of the criterions
%preallocate vector for all criterions
mastercriterion = []; 
%put all topUp dprimes into criterions
mastercriterion(1:length([T.topUpDPrime]),1) = [T.topUpC]; 
%add in stimulated dprimes into criterions
mastercriterion(length(mastercriterion)+1:length(mastercriterion)+length([T.stimC]),1) = [T.stimC];
%add in non-stimulated dprimes into criterions
mastercriterion(length(mastercriterion)+1:length(mastercriterion)+length([T.noStimC]),1) = [T.noStimC];


end