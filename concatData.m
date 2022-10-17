%% Concat Data
%written by Faye 221012



%Index for mouse number

%Index for Date
%create a struct to put all info

masterStruct = struct('mouseNumber',[],'Date',[], 'Indicies',[],'traceMatrix',[],...
    'Rewards',[],'reactionTimes',[],'holdTimes',[],'visualStim',[],'meanPower',[],'nTrials',[]);
masterStruct.nTrials = 1:length(trials); 
masterStruct.mouseNumber = getmouseNum(file);
masterStruct.date = getdate(pwd);
masterStruct.Indicies = getIndicies(trials);
masterStruct.traceMatrix = getOptoTraces(trials);
masterStruct.Rewards = getrewards(trials);
masterStruct.reactionTimes = getRTs(trials);
masterStruct.holdTimes = getholdTime(trials);
masterStruct.visualStim = getvisualStim(trials);
masterStruct.meanPower = getmeanPower(trials);
%way to make this shorter?




