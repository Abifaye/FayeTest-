function getProsLoc
% Inputs into current folder to output RTs of all hit andn miss profiles for all
% trials

%load('masterTable.mat');
load masterTable_complete.mat

%go to folder where masterTable is
folderPath = cd(uigetdir());

%create index of all .mat files which contains hit profiles
matFilesIdx = dir('**/*.mat');
%tableDates = [T.date];
%init location to place hit profiles
hitProsLoc = struct();
missProsLoc = struct();

%% Hits 
%loop through each file
for File = 1:length(matFilesIdx)
    %if date in hit profile file matches date in the master table
    if erase(matFilesIdx(File).name,'.mat') == T.date(File)
        %concatinate subfolder name + file name and connect with '/' to access
        %file path then load file
        trialFilePath = load([matFilesIdx(File).folder '\' matFilesIdx(File).name]);
    % Put hit profiles inside the struct
    hitProsLoc(File).hitProfiles = [trialFilePath.stimProfiles.hitProfiles];
    end
end

%% Misses
for File = 1:length(matFilesIdx)
    %if date in hit profile file matches date in the master table
    if erase(matFilesIdx(File).name,'.mat') == T.date(File)
        %concatinate subfolder name + file name and connect with '/' to access
        %file path then load file
        trialFilePath = load([matFilesIdx(File).folder '\' matFilesIdx(File).name]);
    % Put hit profiles inside the struct
   missProsLoc(File).missProfiles = [trialFilePath.stimProfiles.missProfiles];
    end
end

%Concatinate structs as a row in master table
    T.HitProfiles = hitProsLoc(:);
    T.MissProfiles = missProsLoc(:);
    %rename master table to save as a new table
  save('masterTable_complete.mat',"T")
end

