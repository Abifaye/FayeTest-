%% First Initialization
c = -1:0.5:1; % vector for criterion
signalMean = 0:0.5:4; % Vector for Mean of Signal Distribution
Var = 1; % Variance
nSimTrials = 500; %number of trials
MasterStruct = struct('signal', [], 'c', [], 'hitRates', [], 'missRates', [], 'faRates', [], 'crRates', []); %contains
%the criterion and dprimes of different tRounds (need to come up with
%better field names)
 outcomeContainer = zeros(nSimTrials,1);%contains outcomes for each number round of trials
counter = 0;

%% Nested Simulation loop
for  ndprimeRound = 1:length(signalMean) %for loop that will run different rounds of dprimes

    for nCriterionRound = 1:length(c) %loop that will run diffierent rounds of criterion
        counter = counter+1;

        %initialization for each Round

        signal = normrnd(0, Var,[1,nSimTrials]);
        pCatch = 0.2; % proportion of catch trials
        trialType = rand(1,nSimTrials); % uniform distribtion
        signalTrialIdx = trialType > pCatch; % Idx of where signal occurs
        signal(signalTrialIdx) = normrnd(signalMean(ndprimeRound), Var, [1, sum(signalTrialIdx)]);
        % Vector of the signal, the signal the animal sees whether or not there was
        % a stimulus
        for trialNum = 1:nSimTrials %for loop for going through each nSimtrial #


            %Outcome legend

            %Hit = 1
            %Miss = 2
            %FA = 3
            %CR = 4

            % Not a catch trial
            if signalTrialIdx(trialNum) == 1 %if stimulus present
                if signal(trialNum) > c(nCriterionRound) %If greater than the the criterion of this round
                    outcomeContainer(trialNum)  = 1; %Hit
                elseif signal(trialNum) <= c(nCriterionRound) %If less than/= to criterion of this round
                    outcomeContainer(trialNum)  = 2; %Miss
                end

                % Catch Trial
            elseif signalTrialIdx(trialNum) == 0
                if signal(trialNum) > c(nCriterionRound)
                    outcomeContainer(trialNum)  = 3; %FA
                elseif signal(trialNum) <= c(nCriterionRound)
                    outcomeContainer(trialNum)  = 4; %CR
                end
            end
            % Summary stats

            % Propotion hits (hit rate)
            num_hits = sum(outcomeContainer==1);
            denom_hits = sum(outcomeContainer==1) + ...
                sum(outcomeContainer==2);

            % Propotion miss (miss rate)
            num_miss = sum(outcomeContainer==2);
            denom_miss = sum(outcomeContainer==1) + ...
                sum(outcomeContainer==2);

            % Propotion FA (FA rate)
            num_fa = sum(outcomeContainer==3);
            denom_fa = sum(outcomeContainer==3) + ...
                sum(outcomeContainer==4);

            % Propotion CR (CR rate)
            num_cr = sum(outcomeContainer==4);
            denom_cr = sum(outcomeContainer==1) + ...
                sum(outcomeContainer==2);

            % compute outcomes rates
            hitRate = num_hits./denom_hits;
            missRate = num_miss./denom_miss;
            faRate = num_fa./denom_fa;
            crRate = num_cr./denom_cr;

            %Output Results
        MasterStruct(counter).hitRates = hitRate;
        MasterStruct(counter).missRates = missRate;
        MasterStruct(counter).faRates = faRate;
        MasterStruct(counter).crRates = crRate;
        end
        % Output Results
        %MasterStruct(end+1).dprime = outcomeContainer(nCriterionRound);

        MasterStruct(counter).c = c(nCriterionRound);
        MasterStruct(counter).signal = signalMean(ndprimeRound);
    end
     
end


%% Plots

% hitRate
figure;
plot([MasterStruct.hitRates])
plot([MasterStruct.signal], [MasterStruct.hitRates])
scatter([MasterStruct.signal],[MasterStruct.hitRates])
scatter([MasterStruct.c],[MasterStruct.hitRates])
scatter3 ([MasterStruct.hitRates],[MasterStruct.signal],[MasterStruct.c])
tbl =  table ([MasterStruct.hitRates],[MasterStruct.signal],[MasterStruct.c]);
heatmap(tbl,'v1','c')

%missRate
figure;
plot([MasterStruct.missRates])
%faRate
figure;
plot([MasterStruct.faRates])
%crRAte
figure;
plot([MasterStruct.hitRates])

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


