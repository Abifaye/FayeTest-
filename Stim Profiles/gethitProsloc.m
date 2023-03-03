function [hitProsLoc] = gethitProsLoc
% Inputs into current folder to output RTs of all hit profiles for all
% trials
%go to folder where masterTable is
folderPath = uigetdir('','Select Folder Containing Master Table');
load masterTable.mat; 
%load('masterTable.mat');
cd ('C:\FayeTest-\Stim Profiles');
%create index of all .mat files which contains hit profiles
matFilesIdx = dir('**/*.mat');
%tableDates = [T.date];
%init location to place hit profiles
hitProsLoc = struct();
%%loop through each file
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
%Concatinate struct as a row in master table
    %T.HitProfiles = hitProsLoc(:);
    %rename master table to save as a new table
   % TablewithHitProfiles = T;
end

