%Summary: Adds the hit and miss kernel profiles to the master table for all
%trials and sessions in a specific brain area (either V1 or SC)

%change path to the folder containing the profiles
cd(uigetdir('','Select folder containing the profiles'));

%list the names of the subfolders and files containing the profiles
listing = dir ('**/*.mat');

%loop through the list of files
for nFile = 1:length(listing)

    %load the file
    load(append(listing(nFile).folder,'\',listing(nFile).name))

    %put the hit and miss profiles into temporary arrays
    hitProfiles(nFile) = {stimProfiles.hitProfiles};
    missProfiles(nFile) = {stimProfiles.missProfiles};

end
%Choose the folder path containing the master table
cd(uigetdir('', 'Choose the folder path containing the master table'));

%load the data table you want to append the profiles to
load(uigetfile('', 'Choose the master table you want to append the profiles to'));

%place the hit and miss profile cells into the table
T.hitProfiles = [hitProfiles'];
T.missProfiles = [missProfiles'];

%save the new table
%save("masterTable_SCAllWithProfiles.mat","T")


