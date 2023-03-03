function [amp,mu,sigma] = getTopUpDprimes_curveFitting(topUpDPrimes)
%UNTITLED3 Summary of this function goes here

%load file containing stimulated/non d'
load('TablewithHitProfiles.mat');

%allocate the variables
topUpDPrimes = [TablewithHitProfiles.topUpDPrime];
%curve fitting
dTopUp_histcounts = histcounts(topUpDPrimes,-6:0.2:6);
dTopUp_range = -5.99:0.2:5.99;

%variables
amp =  81.03;
mu = 2.462;
sigma =  0.8123;

end