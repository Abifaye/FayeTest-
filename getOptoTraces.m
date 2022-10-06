function [optoStimuli] = getOptoTraces(trials)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here



% init your output (Best Practice)
optoStimuli = cell(length(trials),1);

% For each trial
for nTrials = 1:length(trials)

    % Extract time change points and powers presented
    time = trials(nTrials).optoStepTimesMS;
    power = trials(nTrials).optoStepPowerMW;
    
    % Created a manual counter
    counter = 1;
    % Init a place to create the trace (Best Practice)
    optoTrace = zeros(1,max(time) - min(time));
    
    % For time change point
    for timePoints = 2:length(time);
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
    optoStimuli{nTrials,1} = optoTrace;
end

end
