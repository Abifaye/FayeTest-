function [holdTime] = getholdTime(trials);
%Created by Faye 221014
% inputs into trials and get hold time, and corrects for incorrect neg values
% by adding 500
preStimLoc =[trials.trial];%gets location of struct containing preStimTime
preStimTime = [preStimLoc.preStimMS]; %gets preStimTime
% responseType = [trials.trialEnd]; %gets response types
holdTime = preStimTime + getRTs(trials);%calculates
%totalHoldTime by subtracting RTs that are not misses from the preStimTime
%that are not misses
holdTime(holdTime<0) = holdTime(holdTime<0)+500;%index into holdTime with 
%negative values and set it to add 500 to them all

%check = totalHoldTime < 0; 
end






