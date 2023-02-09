function [firstTertile,secondTertile,thirdTertile,fourthTertile] = getQuartile
%Splits RTs into top and bottom half percentile and takes the corresponding
%hit profiles

%% Initialize variables
cd 'C:\Users\afbar\OneDrive - University of Calgary\Documents\GitHub\FayeTest-'
%load master table with hit profiles file 
load('TablewithHitProfiles.mat');
%getmasterRTs
%init locations for top + btm profiles
firstTertile = [];
secondTertile = [];
thirdTertile = [];
fourthTertile = [];
%% Create loop for getting hit profiles and putting them in topPros/btmPros matrix
%loop through all sessions
for nSession = 1:height(TablewithHitProfiles)
    %create variables for hit profiles and reaction times from the master
    %table
    RTs = cell2mat(TablewithHitProfiles.stimCorrectRTs(nSession));
    hitPros = cell2mat(struct2cell(TablewithHitProfiles.HitProfiles(nSession)));
    %Create logical index for the top + btm percentile of RTs. prctile function
   
    %creates range for top and bottom percentile
     firstIdx = (RTs >= min(prctile(RTs,[0 25])) & RTs <= max(prctile(RTs,[0 25])));
    secondIdx =(RTs > min(prctile(RTs,[25.01 50])) & RTs <= max(prctile(RTs,[25.01 50])));
    thirdIdx = (RTs > min(prctile(RTs,[50.01 75])) & RTs <= max(prctile(RTs,[50.01 75])));
    fourthIdx = (RTs > min(prctile(RTs,[75.01 100])) & RTs <= max(prctile(RTs,[75.01 100])));
    
    %Grabs all trials in current session and appends them to the matrix
    firstTertile = [firstTertile; hitPros(firstIdx,:)];
    secondTertile = [secondTertile; hitPros(secondIdx,:)];
    thirdTertile = [thirdTertile; hitPros(thirdIdx,:)];
    fourthTertile = [fourthTertile; hitPros(fourthIdx,:)];
end
%% Graph 1
clf;
quartileGraphs = tiledlayout(4,1,"TileSpacing","tight","Padding","tight");
title(quartileGraphs,'Quartile of Mean Hit Profiles')
%1
nexttile
plot(mean(firstTertile/2 + 0.5,1),color='b')
title('First Quartile')
ylim([0.475 0.515])
%2
nexttile
plot(mean(secondTertile/2 + 0.5,1),Color='r')
title('Second Quartile')
ylim([0.475 0.515])
%3
nexttile
plot(mean(thirdTertile/2 + 0.5,1),Color='g')
title('Third Quartile')
ylim([0.475 0.515])
%4
nexttile
plot(mean(fourthTertile/2 + 0.5,1),Color='m')
title('Fourth Quartile')
ylim([0.475 0.515])

%Graph 
figure;
hold on
plot(mean(firstTertile/2 + 0.5,1),color='b')
plot(mean(secondTertile/2 + 0.5,1),Color='r')
plot(mean(thirdTertile/2 + 0.5,1),Color='g')
plot(mean(fourthTertile/2 + 0.5,1),Color='m')
hold off
title('Quartile of Mean Hit Profiles')

%% Bootstrapping

%First Tertile
for reps = 1:1000
    bootfirstTertile(reps,1:800) = mean(datasample(firstTertile,size(firstTertile,1),"Replace",true));
end

%2nd Tertile
for reps = 1:1000
    bootsecondTertile(reps,1:800) = mean(datasample(secondTertile,size(secondTertile,1),"Replace",true));
end

%3rd Tertile
for reps = 1:1000
    bootthirdTertile(reps,1:800) = mean(datasample(thirdTertile,size(thirdTertile,1),"Replace",true));
end

%3rd Tertile
for reps = 1:1000
    bootfourthTertile(reps,1:800) = mean(datasample(fourthTertile,size(fourthTertile,1),"Replace",true));
end

%plot
quartileGraphs = tiledlayout(4,1,"TileSpacing","tight","Padding","tight");
title(quartileGraphs,'Quartile of Mean Hit Profiles')
%1
nexttile
plot(mean(bootfirstTertile),color='b')
title('First Quartile')
ylim([0.475 0.515])
%2
nexttile
plot(mean(bootsecondTertile),Color='r')
title('Second Quartile')
ylim([0.475 0.515])
%3
nexttile
plot(mean(bootthirdTertile),Color='g')
title('Third Quartile')
ylim([0.475 0.515])
%4
nexttile
plot(mean(bootfourthTertile),Color='m')
title('Fourth Quartile')
ylim([0.475 0.515])

end

