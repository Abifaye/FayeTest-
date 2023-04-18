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
%Better visualization of graph

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
%try plotting misses in dif meanPowerMW
%dif plots for each hits, misses, false alarms
%try scatterplots with lines instead of circle, make lines really small