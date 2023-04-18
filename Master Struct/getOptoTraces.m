function [traceMatrix] = getOptoTraces(trials);
%Written by Faye 220929
%Edited 221006
%Edited 221012
%Get the power and time from trials. Throughout time in each trial, put the
%corresponding power. This is placed in a trace called traceMatrix

tic;
%init the matrix for traces
traceMatrix = zeros(length(trials),8000);

% For each trial
for nTrials = 1:length(trials)

    % Extract time change points and powers presented
    time = trials(nTrials).optoStepTimesMS;
    power = trials(nTrials).optoStepPowerMW;
    meanPower = trials(nTrials).meanPowerMW;

    if meanPower==0 % If there was no opto on this trial, skip
        continue;
    elseif  meanPower~=0 % If there is opto, iterate through the trace
        % Loop through all time bins
        for timePoints = 2:length(time)
            if power(timePoints-1)==0 % If there is no power during this bin, skip
                continue  
            elseif power(timePoints-1)~=0 % If power, write the power to the bins that correspond to the right times
                traceMatrix(nTrials,time(timePoints-1)+4000:time(timePoints)+4000) = power(timePoints-1);
            end
        end
    end
end
toc;
end









