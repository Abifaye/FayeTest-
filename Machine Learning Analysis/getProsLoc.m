function getProsLoc
% Inputs into current folder to output RTs of all hit and miss profiles for all
% trials

%load('masterTable.mat');
load masterTable_allLuminanceTrials.mat

%Select the folder containing stim profiles for SC Luminance
cd(uigetdir());

%Select the folder containing stim profiles (WE MIGHT NOT NEED THIS PART)
%folderPath = uigetdir();

for i = 1:size(T,1)
    trialData = load(append(T.animal(i), '\', T.date(i), '.mat'));
    T.hitProfiles{i} = [trialData.stimProfiles.hitProfiles];
    T.missProfiles{i} = [trialData.stimProfiles.missProfiles];
end

  save('masterTable_allLuminanceTrials.mat',"T")
  
end

