function [holdTime] = getholdTime(trials);
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
preStimLoc =[trials.trial];
preStimTime = [preStimLoc.preStimMS];
totalHoldTime = preStimTime - getRTs(trials);
holdTime = {};
for i = 1:length(totalHoldTime)
    if totalHoldTime < 0
       holdTime = totalHoldTime(i) + 500;
    else
        holdTime = totalHoldTime;
    end
end
end

