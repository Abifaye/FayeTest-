function [delta_d] = getdelta_d
% Grabs stimulated and non stimulated d' master table and subtract them
% from each other for each session to calculate the average effect of
% inhibition in V1. A histogram of the distribution of the mean effect is
% plotted.

%Go to folder containing master table
folderPath = uigetdir();

%load file containing stimulated/non d'
load('TablewithHitProfiles.mat');

%allocate the variables
stimDPrimes = [TablewithHitProfiles.stimDPrime];
noStimDPrimes = [TablewithHitProfiles.noStimDPrime];

%% Mean Effect of Inhibition on d'
for nSession = 1:length(stimDPrimes)
   delta_d(nSession,1) = stimDPrimes(nSession) - noStimDPrimes(nSession);
end

end