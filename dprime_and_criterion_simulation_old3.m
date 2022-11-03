
%% Pre-Define Future Inputs to your sim fnc
% Number of trials to simulate
nSimTrials = 1000000;
% state criterion
c = 2;
Var = 1; % Variance of signal and noise Distribution
signalStrength = 3;
noiseMean = 3; 
CTpropn = 0.2; % set catch trial proportion

%init a randomdraw that will contain the response type for each trial
outcomes = cell(1,nSimTrials); %Q:I used zeroes before, what is the difference btwn using cell and zeroes

%% Initialization Stuff 

%Draw nSimTrials random number from a normal distribution of noise with m = 3 s =1
NDnoise_rnd = normrnd(3,Var, [1,nSimTrials]);

%Draw nSimTrials random numbers from a normal distribution of signal with m = 10 s = 1
NDsignal_rnd = normrnd(noiseMean+signalStrength,Var, [1,nSimTrials]);

% Draw numbers between 0 - 1 for 100 trials
trial_Type = rand(1,nSimTrials); 

%% Simulation loop


for trialNum = 1:nSimTrials
    %set if statement when number drawn is greater than 0.2, will run stimulus present trial

    % Not a catch trial
    if trial_Type(trialNum)>CTpropn
        if NDsignal_rnd(trialNum) > c
            outcomes{trialNum} = 'hit';
        elseif NDsignal_rnd(trialNum)<= c
            outcomes{trialNum} = 'miss';
        end

        % Catch Trial
    elseif trial_Type(trialNum)<=CTpropn
        if NDnoise_rnd(trialNum) > c
            outcomes{trialNum} = 'fa';
        elseif NDnoise_rnd(trialNum) <= c
            outcomes{trialNum} = 'cr';
        end
    end
end


%% Summary Stats
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

% How many trials do you need to get to a accurate estimate of d' 


% Future Additions

% Passed a vector of d's to fnc, and wanted the results for all the d's?
%embed the current simulation into the new fnc. Adjust simulation so that it doesn't have 1 d' (make it flexible).
% The new fnc will create a set of d' (maybe an interval of it?) and for
% each d' it will run the simulation. The new fnc will also output a
% struct(?) with each field being the d' and it will contain the outcomes
% for the corresponding d'

% Check the outcomes rates (H,M,FA,CR) as a function of c?
%Adjust simulation similar to d'(like thoughts above) only this time set it
%to change criterions. Also need to adjust simulation to create track for
%# of times stimulus was presented so that proportion of each outcomes can
%be calculated. Then track the # of times each outcome happens for each
%criterion and see how it changes (i.e. visually through graphs)

% Summarize with a bar plot or a histogram (counts of outcome by type)
    

    





