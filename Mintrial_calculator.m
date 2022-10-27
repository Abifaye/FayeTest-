%% Pre-Define Future Inputs to your sim fnc
% Number of trials to simulate
%number of trials will vary

% state criterion
c = 2;
Var = 1; % Variance of signal and noise Distribution
signalStrength = 3; %aka d'
noiseMean = 3;
CTpropn = 0.2; % set catch trial proportion
tRound_container =  cell(5000,10);%contains outcomes for each number round of trials
tRound = 100:100:1000 %vector for dif trial rounds

%% Simulation loop

for  nSimTrials = 1:length(tRound)%creates for loop that will run different rounds of trials
 
    %Initialization Stuff

        %Draw nSimTrials random number from a normal distribution of noise with m = 3 s =1
        NDnoise_rnd = normrnd(3,Var, [1,tRound(nSimTrials)]);
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
num_hits = sum(strcmp('hit',outcomes));
denom_hits = sum(strcmp('hit',outcomes)|strcmp('miss',outcomes));
hitRate= num_hits/denom_hits;

% Propotion FA (FA rate)
num_fa= sum(strcmp('fa',outcomes));
denom_fa= sum(strcmp('fa',outcomes)|strcmp('cr',outcomes));
faRate = num_fa/denom_fa;

% note to compute accurate hit rate, we need to track stimulus occurances
% Compute d' and c based on the inverse Z-Transform of the hit and fa rate

%dprime computation
dprime = norminv(hitRate) - norminv(faRate);

%when norminv of either hit/fa results in inf set it to +/- 100 
if dprime == Inf
    dprime = 100;
elseif dprime == -Inf
    dprime = -100;
end

%criterion computation
criterion = -(1/2*(norminv(hitRate) + norminv(faRate)));

%when norminv of either hit/fa results in inf set it to +/- 100 
if criterion == Inf 
    criterion = 100;
elseif criterion == -Inf
    criterion = -100;
end







