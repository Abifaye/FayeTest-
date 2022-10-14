function [holdTime] = getholdTime(trials);
%Created by
% inputs into trials and get hold time, and corrects for incorrect neg values
% by adding 500
preStimLoc =[trials.trial];%gets location of struct containing preStimTime
preStimTime = [preStimLoc.preStimMS]; %gets preStimTime
responseType = [trials.trialEnd]; %gets response types
RTs = [trials.reactTimeMS]; %gets reaction time
totalHoldTime = preStimTime(responseType~=2) - RTs(responseType~=2); %calculates
%totalHoldTime by subtracting RTs that are not misses from the preStimTime
%that are not misses

for i = 1:length(totalHoldTime) %loops through totalHoldTime
    if totalHoldTime(i) < 0 %when totalHoldTime is negative
        holdTime(i) = totalHoldTime(i) + 500; %add 500 to the value and write it 
        % in holdTime
    else %or if it's positive
        holdTime(i) = totalHoldTime(i); %just write the value in holdTime
    end
end
%check = totalHoldTime < 0; no neg values?
end






