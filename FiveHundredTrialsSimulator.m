%% First Initialization
c = -1:0.5:1; % vector for criterion
signalMean = 0:0.5:4; % Vector for Mean of Signal Distribution
Var = 1; % Variance
nSimTrial = 500; %number of trials
MasterStruct = struct('dprime A',[],'dprime B',[],'dprime C',[],'dprime D',[],'dprime E',[],'dprime F',[],'dprime G',[],'dprime H',[],'dprime I',[]); %contains the criterion and dprimes of different tRounds
%tRound_container = cell(max(tRound),10);%contains outcomes for each number round of trials



%% Nested Simulation loop
for  ndprimeRound = 1:length(signalMean) %for loop that will run different rounds of dprimes
    for nCriterionRound = 1:length(c) %loop that will run diffierent rounds of criterion
        for trialNum = 1:length(nSimtrials) %these 2 will run for each trial of nSimtrials

            %initialization for each tRound

            signal = normrnd(0, Var,[1,nCriterionRound(trialNum)]);
            pCatch = 0.2; % proportion of catch trials
            trialType = rand(1,tRound(nSimTrials)); % uniform distribtion
            signalTrialIdx = trialType > pCatch; % Idx of where signal occurs
            signal(signalTrialIdx) = normrnd(signalMean, Var, [1, sum(signalTrialIdx)]);
            % Vector of the signal, the signal the animal sees whether or not there was
            % a stimulus

            for trialNum = 1:tRound(nSimTrials) %for loop for generating outcomes

                %Outcome legend

                %Hit = 1
                %Miss = 2
                %FA = 3
                %CR = 4

                % Not a catch trial
                if signalTrialIdx(trialNum) == 1
                    if signal(trialNum) > c
                        tRound_container{trialNum,nSimTrials} = 1;
                    elseif signal(trialNum) <= c
                        tRound_container{trialNum,nSimTrials} = 2;
                    end

                    % Catch Trial
                elseif signalTrialIdx(trialNum) == 0
                    if signal(trialNum) > c
                        tRound_container{trialNum,nSimTrials}= 3;
                    elseif signal(trialNum) <= c
                        tRound_container{trialNum,nSimTrials} = 4;
                    end
                end
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


