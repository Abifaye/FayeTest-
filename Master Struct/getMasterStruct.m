function [masterStruct] = getMasterStruct(pwd);

%created by Faye 221020

%inputs into current folder to get functions for mouse number, date
%indices, tracematrix, rewards, reaction times, visualStim, and meanPower
%and put them in the corresponding fied in masterStruct preloaded with empty 
%fields. nTrials is also created in masterStruct to keep tract of trial
%number.
masterStruct = struct('mouseNumber',[],'Date',[], 'Indicies',[],'traceMatrix',[],...
    'Rewards',[],'reactionTimes',[],'holdTimes',[],'visualStim',[],'meanPower',[],'nTrials',[]);
trialNum = [trials.trial];
masterStruct.nTrials = 1:length(trialNum); 
masterStruct.mouseNumber = getmouseNum(file);
masterStruct.Date = getdate(pwd);
masterStruct.Indicies = getIndicies(trials);
masterStruct.traceMatrix = getOptoTraces(trials);
masterStruct.Rewards = getrewards(trials);
masterStruct.reactionTimes = getRTs(trials);
masterStruct.holdTimes = getholdTime(trials);
masterStruct.visualStim = getvisualStim(trials);
masterStruct.meanPower = getmeanPower(trials);
%way to make this shorter?
end

