%% Pre-Define Future Inputs to your sim fnc
% Number of trials to simulate
%number of trials will vary

noiseMean = 3;
signalStrength = 3; %aka d'
Var = 1; % Variance of signal and noise Distribution

% state criterion
c =1+  noiseMean;

CTpropn = 0.2; % set catch trial proportion
tRound = 100:100:1000; %vector for dif trial rounds
tRound_container =  cell(max(tRound),10);%contains outcomes for each number round of trials
MasterStruct = struct('dprimes', [], 'criterions',[]);

%% Simulation loop

for  nSimTrials = 1:length(tRound) %creates for loop that will run different rounds of trials
 
    %Initialization Stuff

        %Draw nSimTrials random number from a normal distribution of noise with m = 3 s =1
        NDnoise_rnd = normrnd(noiseMean,Var, [1,tRound(nSimTrials)]);
        %Draw nSimTrials random numbers from a normal distribution of signal with m = 10 s = 1
        NDsignal_rnd = normrnd(noiseMean+signalStrength,Var, [1,tRound(nSimTrials)]);
        % Draw numbers between 0 - 1 for 100 trials
        trial_Type = rand(1,tRound(nSimTrials));

    for trialNum = 1:tRound(nSimTrials) %for loop for generating outcomes
       
        % Not a catch trial
        if trial_Type(trialNum)>CTpropn
            if NDsignal_rnd(trialNum) > c
                tRound_container{trialNum,nSimTrials} = 'hit';
            elseif NDsignal_rnd(trialNum)<= c
                tRound_container{trialNum,nSimTrials} = 'miss';
            end

            % Catch Trial
        elseif trial_Type(trialNum)<=CTpropn
            if NDnoise_rnd(trialNum) > c
                 tRound_container{trialNum,nSimTrials}= 'fa';
            elseif NDnoise_rnd(trialNum) <= c
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
clf;
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
clf;
figure;
hold on
plot(tRound,hitRate);
plot(tRound,faRate);
plot(tRound,missRate);
plot(tRound,crRate);
hold off

%Compares outcome probabilities across dprimes and criterions
%bar graph version
clf;
figure;
bar(hitRate,missRate,faRate)
hist(faRate(1))
hist(missRate(1))
hist(crRate(1))
hold off

%plot graph version

%dprime
clf;
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
clf;
figure;
plot(MasterStruct.criterions,hitRate,'-o',MasterStruct.criterions, ...
    faRate,'-o', MasterStruct.criterions,missRate,'-o', MasterStruct.criterions,crRate,'-o'); 
title('Outcome Probability as a Function of Criterion')
xlabel('criterion')
ylabel('Outcome probability')
legend_criterion = legend('Hits','False Alarms','Misses','Correct Rejections')
legend_criterion.Location = "bestoutside"
fontsize(gca,13,"pixels")







