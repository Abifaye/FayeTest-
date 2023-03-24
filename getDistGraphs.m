function [outputArg1,outputArg2] = getDistGraphs
%UNTITLED3 Summary of this function goes here

%% AveC

%load master table with profiles
load('TablewithProfiles.mat');

%
stimC = [TablewithProfiles.stimC];
unStimC = [TablewithProfiles.noStimC];
aveC = (stimC + unStimC)/2;
%measurements for curve fitting 
aveC_histcounts = histcounts(aveC,-5:0.17:5);
aveC_range = -4.9:0.17:4.9;

%curvefitting variables
amp = 136.7;
mu = 0.6774;
sigma = 0.4078;


%gaussian graph
y = normpdf(aveC,mu,sigma);
y2=  amp*exp(-((aveC-mu).^2/sigma.^2));
plot(aveC,y2)
end