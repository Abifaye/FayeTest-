function [RewardsOverTime] = getRewardsOverTime
%UNTITLED Summary of this function goes here
%
masterRollAve = getrollingAverage;

%
rollingRwds = [masterRollAve.rollingrewards];

%fix this to code for choosing the time frame

%ms time
rollingRTs = [masterRollAve.rollingallRTs];

%convert time from ms to min
RTs_min = rollingRTs./60000;

%convert time from ms to secs
RTs_sec = rollingRTs./1000;

%
RewardsOverTime = rollingRwds./rollingRTs;

%% plots

%rewards/min plot
figure;
scatter(1:length(RewardsOverTime),RewardsOverTime)
title('Rolling Average Rewards/min')
xlabel('Trials')

%rewards/sec
figure;
scatter(1:length(RewardsOverTime),RewardsOverTime)
title('Rolling Average Rewards/sec')
xlabel('Trials')

%reward/ms plot
figure;
scatter(1:length(RewardsOverTime),RewardsOverTime)
title('Rolling Average Rewards/ms')
xlabel('Trials')

%rewards plotted against time
figure;
scatter(RTs_sec,rollingRwds)
title('Rewards Against Time')
xlabel('Rolling Reaction Time (sec)')
ylabel('Rolling Rewards')

%Rewards over time distribution plot
figure;
histogram(rollingRwds)
title('Rolling Rewards Over Time')
xlabel('Bins')
ylabel('Rewards/time(ms)')




A  = [0 100];

figure;
plot(A)

end