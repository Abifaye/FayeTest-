function [plot_delta_d,plot_delta_C,plot_topUpDPrimes_delta_d,plot_topUpC_delta_C,plot_topUpDPrimes,plot_topUpC] = getcriterions_dprimes_plots
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
folderPath = uigetdir();

%load file containing stimulated/non d'
load('TablewithHitProfiles.mat');

%allocate the variables
stimDPrimes = [TablewithHitProfiles.stimDPrime];
noStimDPrimes = [TablewithHitProfiles.noStimDPrime];
topUpDPrimes = [TablewithHitProfiles.topUpDPrime];
stimC = [TablewithHitProfiles.stimC];
noStimC = [TablewithHitProfiles.noStimC];
topUpC = [TablewithHitProfiles.topUpC];

%% Mean Effect of Inhibition on d'
delta_d = getdelta_d;

%% Mean Effect of Inhibition on C
for nSession = 1:length(stimC)
    delta_C(nSession,1) = stimC(nSession) - noStimDPrimes(nSession);
end


%% plots (make into another function)

%mean effect d'
figure;
plot_delta_d = histogram(delta_d);
title('Distribution of delta dprime')
xlabel('dprime')

%mean effect C
figure;
plot_delta_C = histogram(delta_C);
title('Distribution of delta Criterion')
xlabel('Criterion')

% topUp d' versus delta d'
figure;
plot_topUpDPrimes_delta_d = scatter(topUpDPrimes,delta_d);
title('topup dprime versus delta dprime')
xlabel('Top Up dprime')
ylabel('Delta dprime')

% topUp C versus delta C
figure;
plot_topUpC_delta_C = scatter(topUpC,delta_C);
title('Distribution of Mean Effect of Inhibition on Criterion')
xlabel('Top Up Criterion')
ylabel('Delta Criterion')

%top up d' distribution
figure;
plot_topUpDPrimes = histogram(topUpDPrimes);

%top up C distribution
figure;
plot_topUpC = histogram(topUpC);
end