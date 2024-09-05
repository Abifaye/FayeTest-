function [delta_C] = getdelta_C(T)
% Grabs stimulated and non stimulated C from master table and subtract them
% from each other for each session to calculate the average effect of
% inhibition in SC and V1.

%allocate the variables
stimC = [T.stimC];
noStimC = [T.noStimC];

%% Mean Effect of Inhibition on d'
for nSession = 1:length(stimC)
   delta_C(nSession,1) = stimC(nSession) - noStimC(nSession);
end

end