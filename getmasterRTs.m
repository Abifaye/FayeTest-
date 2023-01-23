function [masterRTs] = getmasterRTs(T)
%A vector for all the RTs for Correct Responses 
%   inputs into the Master table (T) and outputs a vector containing the reaction
%   times (RTs) for all sessions + trials and then a histogram that shows
%   the distribution of reaction times
%% Create a Vector of the Reaction Times
load('masterTable.mat'); %loads the file for master table T 
masterRTs = zeros(); %preallocates vector for all RTs
RTsCell = [T.stimCorrectRTs]; % creates cell with all the RTs from master table for correct responses
Counter = 0; %creates a counter for keeping track of where to place the RTS in the masterRTs
for nSession = 1:length(RTsCell) %a for loop to loop through all the sessions in RTsCell
    for nTrial = 1:length(RTsCell{nSession}) %a for loop to go loop through all trials in current session
        masterRTs(nTrial + Counter, 1) = RTsCell{nSession}(nTrial); %places the RT for the current trial
        %into the masterRTs vector. The counter keeps track of where to
        %place the next session RTs
    end
    Counter = Counter + sum(nTrial); %The counter keeps track of how long the
        %session is so that the RTs in the next session will be placed 
        % correctly in masterRTs
end
%% Histogram of Distribution of RTs
DistribRTs = histogram(masterRTs);
title('Distribution of Reaction Time for Correct Responses')
xlabel('Reaction Time (ms)')

end

