function [delta_C] = getdelta_C
% Grabs stimulated and non stimulated C from master table and subtract them
% from each other for each session to calculate the average effect of
% inhibition in V1.

%Go to folder containing master table
folderPath = uigetdir();

%load file containing stimulated/non d'
load('TablewithProfiles.mat');

%allocate the variables
stimC = [TablewithProfiles.stimC];
noStimC = [TablewithProfiles.noStimC];

%% Mean Effect of Inhibition on d'
for nSession = 1:length(stimC)
   delta_C(nSession,1) = stimC(nSession) - noStimC(nSession);
end

end