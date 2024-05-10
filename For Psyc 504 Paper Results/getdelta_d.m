function [delta_d] = getdelta_d
% Grabs stimulated and non stimulated d' master table and subtract them
% from each other for each session to calculate the average effect of
% inhibition in V1. 

%load master table file containing stimulated/non d'
load(uigetfile('','Select desired master table'));

%allocate the variables
stimDPrimes = [T.stimDPrime];
noStimDPrimes = [T.noStimDPrime];

%% Mean Effect of Inhibition on d'
for nSession = 1:length(stimDPrimes)
   delta_d(nSession,1) = stimDPrimes(nSession) - noStimDPrimes(nSession);
end

end