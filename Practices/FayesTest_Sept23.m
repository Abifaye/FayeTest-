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
% Outcomes = cell(1,length(trialEnd))
% for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
%     if HitIdx(i) %if statement adds condition to be whenever HitIdx is associated with the trial end value
%         Outcomes{1,i}='b' %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
%     elseif FAIdx(i) %if statement adds condition to be whenever FAIdx is associated with the trial end value
%         Outcomes{1,i}='r' %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
%     else MissIdx(i)%if statement adds condition to be whenever MissIdx is associated with the trial end value
%         Outcomes{1,i} ='g' %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
%     end %Don't forget to end if statements
% end %Ends the forloop

% figure;
% hold on;
% for i = 1:length(trialEnd)
%     bar(i,1,0.1,Outcomes{i})
% end
% hold off;
% 
% bar(trialEnd,Outcomes)

% %take2
% trialEnd(trialEnd==0)='r'
% trialEnd(trialEnd==1)='g'
% trialEnd(trialEnd==2)='b'
% for i=1:length(trialEnd)
%     bar(i,"color",(i))
% end
% 
% %try plotting misses in dif meanPowerMW
% meanPower=[trials.meanPowerMW];
% figure; %creates new figure
% clf; %clears previous figure
% hold on; %holds the multiple plots created by the if statements together
% for i = 1:length(meanPower) %starts forloop. Sets i to equal the length of trialEnd
%     if MissIdx(i)%if statement adds condition to be whenever MissIdx is associated with the trial end value
%        scatter(i,3,10,'g','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
%     end %Don't forget to end if statements
% end %Ends the forloop
% hold off; % Ends the hold

% %dif plots for each hits, misses, false alarms
% figure; %creates new figure
% clf; %clears previous figure
% hold on; %holds the multiple plots created by the if statements together
% for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
%     if MissIdx(i)%if statement adds condition to be whenever MissIdx is associated with the trial end value
%        scatter(i,3,10,'g','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
%     end %Don't forget to end if statements
% end
% hold off;
% 
% figure; %creates new figure
% clf; %clears previous figure
% hold on; %holds the multiple plots created by the if statements together
% for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
%     if FAIdx(i) %if statement adds condition to be whenever FAIdx is associated with the trial end value
%         scatter(i,2,10,'r','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
%     end %Don't forget to end if statements
% end %Ends the forloop
% hold off; % Ends the hold
% 
% figure; %creates new figure
% clf; %clears previous figure
% hold on; %holds the multiple plots created by the if statements together
% for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
%     if HitIdx(i) %if statement adds condition to be whenever HitIdx is associated with the trial end value
%        scatter(i,1,10,'b','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
%     end %Don't forget to end if statements
% end %Ends the forloop
% hold off; % Ends the hold

%try scatterplots with lines instead of circle, make lines really small
figure; %creates new figure
clf; %clears previous figure
hold on; %holds the multiple plots created by the if statements together
for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
    if HitIdx(i) %if statement adds condition to be whenever HitIdx is associated with the trial end value
       scatter(i,1,10,'b','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    elseif FAIdx(i) %if statement adds condition to be whenever FAIdx is associated with the trial end value
        scatter(i,2,10,'r','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    else MissIdx(i)%if statement adds condition to be whenever MissIdx is associated with the trial end value
       scatter(i,3,10,'g','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    end %Don't forget to end if statements
end %Ends the forloop
hold off; % Ends the hold



%% Plotting Trials By Colour
figure; %creates new figure
clf; %clears previous figure
hold on; %holds the multiple plots created by the if statements together
for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
    if HitIdx(i) %if statement adds condition to be whenever HitIdx is associated with the trial end value
       scatter(i,1.75,20,'b','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    elseif FAIdx(i) %if statement adds condition to be whenever FAIdx is associated with the trial end value
        scatter(i,2,20,'r','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    else MissIdx(i)%if statement adds condition to be whenever MissIdx is associated with the trial end value
       scatter(i,2.25,20,'g','|') %creates scatterplot: (x value (scalar), y value (scalar), size of "shape",  color)
    end %Don't forget to end if statements
end %Ends the forloop
hold off; % Ends the hold
title('Hits, Misses, and False Alarms in Each Trials')
xlabel('Trial Number')
ylabel('Type of Response')
ylim ([1.5 2.5]) %[lower upper] limit of values
yticks([1.75 2 2.25]) % where to show tick marks
yticklabels({'Hits', 'False Alarms', 'Misses'}) %label ticks
xticks([0:100:900])

% Same but with plot
Trials = [trials.trial]; %keep labels different (no same labels for variables)
preStimTimeMS = [Trials.preStimMS]
holdTime = preStimTimeMS + RTs

min(holdTime(FAIdx))

figure;
clf;
hold on; %holds the multiple plots created by the if statements together
for i = 1:length(trialEnd) %starts forloop. Sets i to equal the length of trialEnd
    if HitIdx(i) %if statement adds condition to be whenever HitIdx is associated with the trial end value
       plot([i i], [2 2.9], 'Color', 'b', 'LineWidth',0.3)
       plot([i i], [3 3.9], 'Color', ...
           [(file.reactMS-RTs(i))/file.reactMS (file.reactMS-RTs(i))/file.reactMS (file.reactMS-RTs(i))/file.reactMS],...
           'LineWidth', 0.3)
    elseif FAIdx(i) %if statement adds condition to be whenever FAIdx is associated with the trial end value
        plot([i i], [0 0.9], 'Color', 'r', 'LineWidth',0.3)
        plot([i i], [1 1.9], 'Color', 'y','LineWidth',0.3)
    else MissIdx(i)%if statement adds condition to be whenever MissIdx is associated with the trial end value
        plot([i i], [4 4.9], 'Color', 'g', 'LineWidth',0.3)
    end %Don't forget to end if statements
end %Ends the forloop
hold off; % Ends the hold
title('Outcomes Across Trials')
xlabel('Trial Number')
ylabel('Type of Response')
ylim ([-0.1 5]) %[lower upper] limit of values
yticks([0.5 1.5 2.5 3.5 4.5]) % where to show tick marks
yticklabels({'False Alarms', 'RT_FA','Hits', 'RT_Hits', 'Misses'}) %label ticks
xticks([0:100:900]);
box off;
set(gca, 'TickDir', 'out'); 
set(gca, 'LineWidth', 1);
set(gca, 'FontSize', 14);

%% Plotting Contrast and reaction time
%create vector for reaction time
RTs = [trials.reactTimeMS]
%create vector for visualStimValue
visualStim = [trials.visualStimValue]
%create vector for meanPowerMW
Power = [trials.meanPowerMW] 
% scatterplot RTs(specify visualstim, power,hits)
RoundedVS = floor(visualStim)%rounds down, use "ceil" for round up
   
%unstimulated,30 contrast, hits
x = 1:length(RTs(Power~=0 & RoundedVS==30 & HitIdx))%must be 1:something so not just #, but vector
RoundedVS = floor(visualStim)%rounds down, use "ceil" for round up
scatter(x,RTs(Power~=0 & RoundedVS==30 & HitIdx))%unstimulated,50 contrast, hits; ";" so it doesn't run #s

%unstimulated,30 contrast, miss
x = 1:length(RTs(Power~=0 & RoundedVS==30 & MissIdx))
RoundedVS = floor(visualStim)
scatter(x,RTs(Power~=0 & RoundedVS==30 & MissIdx));%unstimulated,50 contrast, miss; ";" so it doesn't run #s

%unstimulated, 30 contrast, FA
x = 1:length(RTs(Power~=0 & RoundedVS==30 & FAIdx))
RoundedVS = floor(visualStim)
scatter(x,RTs(Power~=0 & RoundedVS==30 & FAIdx));

%stimulated, 30 contrast, hits
x = 1:length(RTs(Power==0 & RoundedVS==30 & HitIdx))
RoundedVS = floor(visualStim)
scatter(x,RTs(Power==0 & RoundedVS==30 & HitIdx)) %unstimulated,50 contrast, miss; ";" so it doesn't run #s

%stimulated, 30 contrast, miss
x = 1:length(RTs(Power==0 & RoundedVS==30 & MissIdx))
RoundedVS = floor(visualStim)
scatter(x,RTs(Power==0 & RoundedVS==30 & MissIdx));%unstimulated,50 contrast, miss; ";" so it doesn't run #s

%stimulated, 30 contrast, FA
x = 1:length(RTs(Power==0 & RoundedVS==30 & FAIdx));
RoundedVS = floor(visualStim);
scatter(x,RTs(Power==0 & RoundedVS==30 & FAIdx));

%stimulated vs unstimulated, 30 constrast, all
RoundedVS = floor(visualStim);
x_stimulated = 1:length(RTs(Power~=0 & RoundedVS==30));
x_unstimulated = 1:length(RTs(Power==0 & RoundedVS==30));

hold on;
scatter(x_stimulated,RTs(Power~=0 & RoundedVS==30),'filled')
scatter(x_unstimulated,RTs(Power==0 & RoundedVS==30))
hold off
title('Stimulated vs Unstimulated Outcomes in 30% Contrast')
xlabel('Trials')
ylabel('Reaction Time')
legend('Stimulated','Unstimulated')

%stimulated vs unstimulated, 30 constrast, Hits
RoundedVS = floor(visualStim);
x_stimulated = 1:length(RTs(Power~=0 & RoundedVS==30 & HitIdx));
x_unstimulated = 1:length(RTs(Power==0 & RoundedVS==30 & HitIdx));

hold on;
scatter(x_stimulated,RTs(Power~=0 & RoundedVS==30 & HitIdx),'filled')
scatter(x_unstimulated,RTs(Power==0 & RoundedVS==30 & HitIdx))
hold off
title('Stimulated vs Unstimulated Hit Outcomes in 30% Contrast')
xlabel('Trials')
ylabel('Reaction Time')
legend('Stimulated','Unstimulated')


%rolling average hits

%30 vs 50 contrast, stimulated, all
RoundedVS = floor(visualStim);
x_30 = 1:length(RTs(Power==0 & RoundedVS==30 ));
x_50 = 1:length(RTs(Power==0 & RoundedVS==50 ));

hold on;
scatter(x_30,RTs(Power==0 & RoundedVS==30),'filled')
scatter(x_50,RTs(Power==0 & RoundedVS==50))
hold off
title('30% vs 50% Contrast on Stimulated Outcomes')
xlabel('Trials')
ylabel('Reaction Time')
legend('30%','50%')

%30 vs 50 contrast, stimulated, Hits (How long mice take to react, 30% vs 50%; easy vs hard) 
RoundedVS = floor(visualStim);
x_30 = 1:length(RTs(Power==0 & RoundedVS==30 & HitIdx));
x_50 = 1:length(RTs(Power==0 & RoundedVS==50 & HitIdx));

hold on;
scatter(x_30,RTs(Power==0 & RoundedVS==30 & HitIdx),'filled')
scatter(x_50,RTs(Power==0 & RoundedVS==50 & HitIdx))
hold off
title('30% vs 50% Contrast on Stimulated Hit Outcomes')
xlabel('Trials')
ylabel('Reaction Time')
legend('30%','50%')


%bar graphs for 30 vs 50 contrast, stimulated, Hits
M_30 = mean(RTs(Power==0 & RoundedVS==30 & HitIdx));
STD_30 = std(RTs(Power==0 & RoundedVS==30 & HitIdx));
M_50 = mean(RTs(Power==0 & RoundedVS==50 & HitIdx));
STD_50 = std(RTs(Power==0 & RoundedVS==50 & HitIdx));
hold on;
bar (1,M_30);
plot([1 1],[M_30+STD_30 M_30-STD_30], 'k');
plot([1 1],[M_30+STD_30 M_30-STD_30], '_', 'k');
bar (2,mean(RTs(Power==0 & RoundedVS==50 & HitIdx)));
plot([2 2],[M_50+STD_50 M_50-STD_50], 'k');
plot([2 2],[M_50+STD_50 M_50-STD_50], '_', 'k');
hold off;
title(' Mean Stimulated Hit Outcomes on 30% vs 50% Contrast')
xlabel('Contrast')
ylabel('Reaction Time')
xticks([1 2])
xticklabels({'30%','50%'})
%fix width of error, change color too



%30 vs 50 contrast, stimulated, Misses (not changing, did not react till reached max time to for trial) 
RoundedVS = floor(visualStim);
x_30 = 1:length(RTs(Power==0 & RoundedVS==30 & MissIdx));
x_50 = 1:length(RTs(Power==0 & RoundedVS==50 & MissIdx));

hold on;
scatter(x_30,RTs(Power==0 & RoundedVS==30 & MissIdx),'filled')
scatter(x_50,RTs(Power==0 & RoundedVS==50 & MissIdx))
hold off
title('30% vs 50% Contrast on Stimulated Hit Outcomes')
xlabel('Trials')
ylabel('Reaction Time')
legend('30%','50%')


%stimulated, 30 contrast, hits + unstimulated,30 contrast, hits
x = 1:length(RTs(Power~=0 & RoundedVS==30 & HitIdx))
xx = 1:length(RTs(Power==0 & RoundedVS==30 & HitIdx))
RoundedVS = floor(visualStim)

hold on;
scatter(x,RTs(Power~=0 & RoundedVS==30 & HitIdx),'b');
scatter(xx,RTs(Power==0 & RoundedVS==30 & HitIdx),'r');
hold off;

%stimulated, 50 contrast, hits
x = 1:length(RTs(Power==0 & RoundedVS==50 & HitIdx))
RoundedVS = floor(visualStim)
scatter(x,RTs(Power==0 & RoundedVS==50 & HitIdx)) %unstimulated,50 contrast, miss; ";" so it doesn't run #s

%stimulated, 30 contrast, hits + timulated, 30 contrast, hits
x = 1:length(RTs(Power==0 & RoundedVS==30 & HitIdx))
xx = 1:length(RTs(Power==0 & RoundedVS==50 & HitIdx))
RoundedVS = floor(visualStim)
hold on;
scatter(x,RTs(Power==0 & RoundedVS==30 & HitIdx)) 
scatter(xx,RTs(Power==0 & RoundedVS==50 & HitIdx),'filled') 
hold off;

% stimulated, 30 contrast, hits + stimulated, 50 contrast, hits
% {documentation)
x = 1:length(RTs(Power==0 & RoundedVS==30 & HitIdx));
xx = 1:length(RTs(Power==0 & RoundedVS==50 & HitIdx));
RoundedVS = floor(visualStim); 
figure;
clf;
hold on;
scatter(x,RTs(Power==0 & RoundedVS==30 & HitIdx));
scatter(xx,RTs(Power==0 & RoundedVS==50 & HitIdx),'filled'); 
hold off;
title('Comparison of Reaction Time Between 30% vs 50% Contrast for Stimulated Trials with Hit Responses')
xlabel('Trials')
ylabel('Reaction Time')
legend('30% Contrast','50% Contrast')

%stimulated, 30 contrast, hits + unstimulated,30 contrast, hits
%(documentation)
x = 1:length(RTs(Power~=0 & RoundedVS==30 & HitIdx))
xx = 1:length(RTs(Power==0 & RoundedVS==30 & HitIdx))
RoundedVS = floor(visualStim)
figure;
clf;
hold on;
scatter(x,RTs(Power~=0 & RoundedVS==30 & HitIdx),'b');
scatter(xx,RTs(Power==0 & RoundedVS==30 & HitIdx),'r','filled');
hold off;
title('Comparison of Reaction Time Between Stimulated vs Unstimulated  for Trials with 30% Contrast')
xlabel('Trials')
ylabel('Reaction Time')
legend('Stimulated','Unstimulated')
