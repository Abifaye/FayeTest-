function [hitProsLoc] = gethitProsloc(pwd);
% Inputs into current folder to output RTs of all hit profiles for all
% trials
%I want to doublec check if my input is correct? use uigetdir
%% Create a Matrix of Hit Profiles for All Trials
% State folder that has all subfolders of profiles as parent directory
parentdir = cd('C:\Users\afbar\OneDrive - University of Calgary\Documents\OneDrive\Documents\Psyc 504\Coding\FayeTest-\Stim Profiles');
%Go through each subfolders and take all .mat files; this corresponds to
%stim profile files
matFilesIdx = dir('**/*.mat');
%start a counter to indicate where to put hit profiles
Counter = 0;
%init location to place hit profiles
hitProsLoc = zeros();
%loop through each file
for File = 1:length(matFilesIdx)
    %concatinate subfolder name + file name and connect with '/' to access
    %file path then load file
    trialFilePath = load([matFilesIdx(File).folder '\' matFilesIdx(File).name]);
    %access hit profiles
    hitPros = [trialFilePath.stimProfiles.hitProfiles];
    %create variable to adjust length of hitProsLoc
    nbins = height(hitPros);
    %Put hitPros in hitProsLoc. Column indicated by counter(starts at last
    %location of previous hitPros) upto nbins(length of current hitPros).1
    %is added because counter starts at 0. Row indicated by length of
    %hitPros
    hitProsLoc(Counter + 1:Counter + nbins,1:length(hitPros)) = hitPros;
    %adjust where to put hit profiles using the counter and nbins
    Counter = Counter + nbins;
end
end


