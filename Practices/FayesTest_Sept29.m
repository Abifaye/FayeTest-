%% Faye's First Code 220907
% Here is where you tell people what the code is going to do

% Logical Indexing in MATLAB
optoStimIdx = [trials.meanPowerMW] ~= 0;

% how many different powers were used?
optoPows = unique([trials.meanPowerMW]);

% Accessing Data in a vector
firstLoc = optoPows(1,1);
secondLoc = optoPows(1,2); 

% access a random point value in optoStimIdx
% randOpto = optoStimIdx(1,randi(size(optoStimIdx,2)));

% Trial Outcomes
% 0 = Hit, animal got the trial right, responded in the RT window
% 1 = False Alarm (FA), animal released before the stimulus
% 2 = Miss, animal failed to release before end of RT window


% Create an Array of the Reaction Times
RTs = [trials.reactTimeMS];
% Create Idx for Hit, Miss, FA
HitIdx = [trials.trialEnd] == 0;
MissIdx = [trials.trialEnd] == 2;
FAIdx = [trials.trialEnd] == 1;

% Create an of reaction time that does not include the false alarms
NonFAIdx = [trials.trialEnd] ~= 1;
RTsSubset = RTs(NonFAIdx);

% Sanity Check length of Subset is exactly the number of FAs less
nFA = sum(FAIdx);
nTrials = length(trials);

% Look Up Assertions: This evaulates to true (e.g., == 1) if we did things
% correctly
(nTrials - nFA) == length(RTsSubset);

%rewards array
Rewards = [trials.reward]
rewardsidx = [trials.reward] ~= 0
rewardsSubset = Rewards(rewardsidx)
optoRewards = unique(Rewards)

% Histogram of Rewards
histogram(optoRewards)

RTs(optoRewards(1,2))
% Stimulus on Time
SoTs = [trials.stimulusOnTime]

% for loop example
% Read up and understand
for i = 1:10
    display(i)
end

% while loop
i = 1;
while i <= 10
    display(i)
    i = i + 1;
end

%% Histogram of RTs
figure;
hold on;
histogram(RTs(HitIdx),-700:75:700);
histogram(RTs(FAIdx),-700:75:700);
hold off;
title('Reaction Time of Hits and False Alarms')
xlabel('Reaction Time (ms)')
ylabel('Counts')
legend('Hits','False Alarms')
fontsize(gca,13,"pixels")

% DisplayStyle
histogram(RTs,'DisplayStyle','Stairs')
histogram(RTs,'DisplayStyle','bar')

figure;
hold on;
histogram(RTs(FAIdx),'Normalization', 'probability');
histogram(RTs(HitIdx),'Normalization', 'probability');
hold off;

%Create a histogram using categorical data
C = categorical(C);
histogram (C, {'FA', 'hit', 'miss'});

% Only Way
C = cell(1,length(RTs));
for i = 1:length(HitIdx) 
    if HitIdx(i) == 1
        C{1,i} = 'hit';
    elseif FAIdx(i) == 1
        C{1,i} = 'FA';
    else
        C{1,i} = 'miss';
    end
end    
% B = zeros(1,length(RTs));
% B(HitIdx) = 1;

%% Plotting Trials By Colour

trialEnd = [trials.trialEnd] %create vector for trialEnd
HitIdx = [trials.trialEnd] == 0; %index for hits
MissIdx = [trials.trialEnd] == 2; %index for misses
FAIdx = [trials.trialEnd] == 1; %index for false alarms

figure; %creates new figure
clf; %clears previous figure
hold on; %holds the multiple plots created by the if statements together
for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
    if HitIdx(i) %if statement adds condition to be whenever HitIdx is associated with the trial end value
       scatter([i,i],[0,50],"color",'b') %creates scatterplot: (x value (vector), y value (vector),color)
    elseif FAIdx(i) %if statement adds condition to be whenever FAIdx is associated with the trial end value
        scatter([i,i],[0,50],"color",'r') %creates scatterplot: (x value (vector), y value (vector),color)
    else MissIdx(i)%if statement adds condition to be whenever MissIdx is associated with the trial end value
       scatter([i,i],[0,50],"color",'g') %creates scatterplot: (x value (vector), y value (vector),color)
    end %Don't forget to end if statements
end %Ends the forloop
hold off; % Ends the hold on graphs

%Better visualization of graph
figure; %creates new figure
clf; %clears previous figure
hold on; %holds the multiple plots created by the if statements together
for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
    if HitIdx(i) %if statement adds condition to be whenever HitIdx is associated with the trial end value
       scatter(i,1,10,'b') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    elseif FAIdx(i) %if statement adds condition to be whenever FAIdx is associated with the trial end value
        scatter(i,2,10,'r') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    else MissIdx(i)%if statement adds condition to be whenever MissIdx is associated with the trial end value
       scatter(i,3,10,'g') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    end %Don't forget to end if statements
end %Ends the forloop
hold off; % Ends the hold

%try bar plots, adjust bar spaces
%take1
figure; %creates new figure
clf; %clears previous figure
hold on; %holds the multiple plots created by the if statements together
for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
    if HitIdx(i) %if statement adds condition to be whenever HitIdx is associated with the trial end value
       bar(i,0.2,'b') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    elseif FAIdx(i) %if statement adds condition to be whenever FAIdx is associated with the trial end value
        bar(i,0.2,'r') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    else MissIdx(i)%if statement adds condition to be whenever MissIdx is associated with the trial end value
       bar(i,0.2,'g') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    end %Don't forget to end if statements
end %Ends the forloop
hold off; % Ends the hold

%take2
trialEnd(trialEnd==0)='r'
trialEnd(trialEnd==1)='g'
trialEnd(trialEnd==2)='b'
for i=1:length(trialEnd)
    bar(i,"color",(i))
end
%try plotting misses in dif meanPowerMW
meanPower=[trials.meanPowerMW];
figure; %creates new figure
clf; %clears previous figure
hold on; %holds the multiple plots created by the if statements together
for i = 1:length(meanPower) %starts forloop. Sets i to equal the length of trialEnd
    if MissIdx(i)%if statement adds condition to be whenever MissIdx is associated with the trial end value
       scatter(i,3,10,'g','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    end %Don't forget to end if statements
end %Ends the forloop
hold off; % Ends the hold

%dif plots for each hits, misses, false alarms
figure; %creates new figure
clf; %clears previous figure
hold on; %holds the multiple plots created by the if statements together
for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
    if MissIdx(i)%if statement adds condition to be whenever MissIdx is associated with the trial end value
       scatter(i,3,10,'g','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    end %Don't forget to end if statements
end
hold off;

figure; %creates new figure
clf; %clears previous figure
hold on; %holds the multiple plots created by the if statements together
for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
    if FAIdx(i) %if statement adds condition to be whenever FAIdx is associated with the trial end value
        scatter(i,2,10,'r','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    end %Don't forget to end if statements
end %Ends the forloop
hold off; % Ends the hold

figure; %creates new figure
clf; %clears previous figure
hold on; %holds the multiple plots created by the if statements together
for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
    if HitIdx(i) %if statement adds condition to be whenever HitIdx is associated with the trial end value
       scatter(i,1,10,'b','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    end %Don't forget to end if statements
end %Ends the forloop
hold off; % Ends the hold

%try scatterplots with lines instead of circle, make lines really small
figure; %creates new figure
clf; %clears previous figure
hold on; %holds the multiple plots created by the if statements together
for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
    if HitIdx(i) %if statement adds condition to be whenever HitIdx is associated with the trial end value
       scatter(i,1.75,10,'b','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    elseif FAIdx(i) %if statement adds condition to be whenever FAIdx is associated with the trial end value
        scatter(i,2,10,'r','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    else MissIdx(i)%if statement adds condition to be whenever MissIdx is associated with the trial end value
       scatter(i,2.25,10,'g','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    end %Don't forget to end if statements
end %Ends the forloop
hold off; % Ends the hold
title('Hits, Misses, and False Alarms in Each Trials')
xlabel('Trial Number')
ylabel('Type of Response')
ylim ([1 3])
yticks([1.75 2 2.25])
yticklabels({'Hits', 'False Alarms', 'Misses'})
xticks([0:100:900])

%% Plotting Time and Power

time = [trials.optoStepTimesMS];
power = [trials.optoStepPowerMW];

figure;
for i = 1:length(time);
    plot(power((i+1) - i));
end
%%
time = [trials(4).optoStepTimesMS];
power = [trials(4).optoStepPowerMW];

figure;

% Example of a counter variable

counter = 1;
optoTrace = zeros(1,max(time) - min(time));
for i = 1:length(time);
    if i < length(time)
        nBins = time(i+1) - time(i);
        optoTrace(1,counter:counter+nBins) = power(i);
        counter = counter + nBins;
    elseif i >= length(time)
        optoTrace(1,counter:max(time) - min(time)) = power(i)
    end
end
plot(optoTrace);
ylim([-0.1 0.5]);


% Confusing Example of efficiency
tic;
counter = 1;
optoTrace = zeros(1,max(time) - min(time));
for i = 1:length(time)
    if i < length(time)
        if power(i) ~= 0
            nBins = time(i+1) - time(i);
            optoTrace(1,counter:counter+nBins) = power(i);
            counter = counter + nBins;
        else
            nBins = time(i+1) - time(i);
            counter = counter + nBins;
        end
    elseif i >= length(time)
        if power(i) ~= 0
            optoTrace(1,counter:max(time) - min(time));
        else
            continue
        end
    end
end

plot(optoTrace);
ylim([-0.1 0.5]);
toc;




%%
tic;
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
toc;

%%