function [traceMatrix] = getOptoTracesOld(trials);
%Written by Faye 220929
%Edited 221006

tic;
%init the matrix for traces
traceMatrix = zeros(length(trials),8000);

% init your output (Best Practice)
% optoStimuli = cell(length(trials),1);

% For each trial
for nTrials = 1:length(trials)

    % Extract time change points and powers presented
    time = trials(nTrials).optoStepTimesMS;
    power = trials(nTrials).optoStepPowerMW;
    
    % Created a manual counter
    counter = 1;
    % Init a place to create the trace (Best Practice)
    optoTrace = zeros(1,range(time));
    
    % For time change point
    for timePoints = 2:length(time)
        % How many timepoints elapsed between the current point and the
        % next time point
        nBins = time(timePoints) - time(timePoints-1);
        % Write the power to the corresponding duration
        optoTrace(1,counter:counter+nBins) = power(timePoints-1);
        % Manually adjust our counter to the new start point for next
        % bin
        counter = counter + nBins;

    end
    % You've completed a loop through one trial --> Write the result to the
    % output that you will return from the function
    % optoStimuli{nTrials,1} = optoTrace;
    % input optoTrace into the matrix, matrix must be same length as
    % optoTrace and spans from starting point ( 0 = 4000) until duration
    traceMatrix(nTrials,min(time)+4000:min(time)+4000+range(time)) = optoTrace;
end
toc;
end


%%

% For each trial, 
% if there is no power at all 
% (trials.meanPowerMW ==0) skip this trial (continue)
% if there is power (trials.meanPowerMW ~= 0)
% Then you will start to edit the matrix, given current time point
% However:
% if no power in current time window, you can skip those bins
% else you need to write the power for that time window
% Tricky part: to the correct bins in traceMatrix
% Account for the reference/start point for your trace Matrix
% and the start point of the optoProfile on that trial.

