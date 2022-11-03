%% Combined Distribution Simulator

%First Initialization
c = 0.5; % criterion
signalMean = 2; % Mean of Signal Distribution
Var = 1; % Variance
tRound = 100:100:1000; %vector for dif trial rounds
MasterStruct = struct('dprimes', [], 'criterions',[]); %contains the criterion and dprimes of different tRounds
tRound_container = cell(max(tRound),10);%contains outcomes for each number round of trials

%% Simulation loop
for  nSimTrials = 1:length(tRound) %creates for loop that will run different rounds of trials

    %initialization for each tRound

    signal = normrnd(0, Var,[1,tRound(nSimTrials)]);
    pCatch = 0.2; % proportion of catch trials
    trialType = rand(1,tRound(nSimTrials)); % uniform distribtion
    signalTrialIdx = trialType > pCatch; % Idx of where signal occurs
    signal(signalTrialIdx) = normrnd(signalMean, Var, [1, sum(signalTrialIdx)]);
    % Vector of the signal, the signal the animal sees whether or not there was
    % a stimulus

    for trialNum = 1:tRound(nSimTrials) %for loop for generating outcomes

        % Not a catch trial
        if signalTrialIdx(trialNum) == 1
            if signal(trialNum) > c
                tRound_container{trialNum,nSimTrials} = 'hit';
            elseif signal(trialNum) <= c
                tRound_container{trialNum,nSimTrials} = 'miss';
            end

            % Catch Trial
        elseif signalTrialIdx(trialNum) == 0
            if signal(trialNum) > c
                tRound_container{trialNum,nSimTrials}= 'fa';
            elseif signal(trialNum) <= c
                tRound_container{trialNum,nSimTrials} = 'cr';
            end
        end
    end
end

  %% Summary stats

% Propotion hits (hit rate) 
num_hits = sum(cellfun(@(x) strcmp('hit',x), tRound_container));
denom_hits = sum(cellfun(@(x) strcmp('hit',x), tRound_container)) + ...
    sum(cellfun(@(x) strcmp('miss',x), tRound_container));
% Propotion miss (miss rate) 
num_miss = sum(cellfun(@(x) strcmp('miss',x), tRound_container));
denom_miss = sum(cellfun(@(x) strcmp('hit',x), tRound_container)) + ...
    sum(cellfun(@(x) strcmp('miss',x), tRound_container));
% Propotion FA (FA rate)
num_fa = sum(cellfun(@(x) strcmp('fa',x), tRound_container));
denom_fa = sum(cellfun(@(x) strcmp('fa',x), tRound_container)) + ...
    sum(cellfun(@(x) strcmp('cr',x), tRound_container));
% Propotion CR (CR rate)
num_cr = sum(cellfun(@(x) strcmp('cr',x), tRound_container));
denom_cr = sum(cellfun(@(x) strcmp('fa',x), tRound_container)) + ...
    sum(cellfun(@(x) strcmp('cr',x), tRound_container));

% compute outcomes rates
hitRate = num_hits./denom_hits;
faRate = num_fa./denom_fa;
missRate = num_miss./denom_miss;
crRate = num_cr./denom_cr;


for simRound = 1:length(hitRate)
    if hitRate(simRound) == 1
        hitRate(simRound) = 0.999;
    end
    if faRate(simRound) == 1
        faRate(simRound) = 0.999;
    end
end

%dprime computation
dprime = norminv(hitRate) - norminv(faRate);
%criterion computation
criterion = -(1/2*(norminv(hitRate) + norminv(faRate)));

% Output Results
for simRound = 1:length(dprime)
    MasterStruct.dprimes(simRound) = dprime(simRound);
    MasterStruct.criterions(simRound) = criterion(simRound);
end

%% Plots
%Compares dprimes and criterions across rounds of simulation trials

figure;
plot(tRound,MasterStruct.dprimes,'-o')
hold on
plot(tRound,MasterStruct.criterions,'-o')
hold off
title('dprime and Criterion as a Function of number of Trials')
xlabel('Trial Number')
ylabel('Outcome')
legend_dprime = legend('dprimes','criterions')
fontsize(gca,13,"pixels")

%Compares outcome probabilities across rounds of simulation trials

figure;
hold on
plot(tRound,hitRate);
plot(tRound,faRate);
plot(tRound,missRate);
plot(tRound,crRate);
hold off
title('Outcome Probability as a Function of Trial Round')
xlabel('Trial Round')
ylabel('Outcome Probability')
legend_dprime = legend('Hits','False Alarms','Misses','Correct Rejections')
legend_dprime.Location = "bestoutside"
fontsize(gca,13,"pixels")


%Compares outcome probabilities across dprimes and criterions
%bar graph version

% figure;
% bar(hitRate,missRate,faRate)
% hist(faRate(1))
% hist(missRate(1))
% hist(crRate(1))
% hold off

%plot graph version

%dprime

figure;
plot(MasterStruct.dprimes,hitRate,'-o',MasterStruct.dprimes, ...
    faRate,'-o', MasterStruct.dprimes,missRate,'-o', MasterStruct.dprimes,crRate,'-o'); 
title('Outcome Probability as a Function of dprime')
xlabel('dprime')
ylabel('Outcome probability')
legend_dprime = legend('Hits','False Alarms','Misses','Correct Rejections')
legend_dprime.Location = "bestoutside"
fontsize(gca,13,"pixels")


%criterion

figure;
plot(MasterStruct.criterions,hitRate,'-o',MasterStruct.criterions, ...
    faRate,'-o', MasterStruct.criterions,missRate,'-o', MasterStruct.criterions,crRate,'-o'); 
title('Outcome Probability as a Function of Criterion')
xlabel('criterion')
ylabel('Outcome probability')
legend_criterion = legend('Hits','False Alarms','Misses','Correct Rejections')
legend_criterion.Location = "bestoutside"
fontsize(gca,13,"pixels")




%% 
% We don't gain much after 500 trials per simulation

% Run sims with 500 trials

% sweep a range of d' and c
%range for d' = 0 : 4  for 0.5 interval
%range of criterion = -1 : 1 for 0.5 interval

% nested for loops (for d, for c)

% for each round of simulation
% Proportion of hits, miss, fa, cr

% Experiment with visualization
% One plot for each measure (hit plot, miss plot)
% one axes is d', one is going be c
% 3d plots, usually are heatmap

% Bar Graph
% with d' and c (2 rows on bottom of bar)
% could make one bar graph per outcome type (H, M, FA, CR)
% You could combine, and color code bars by outcome
% show each type together for each, d'; c









