function [dprime, c] = getdprime_embedded(trials)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
dprime = norminv(gethitRate(trials).hitRate_30US) - norminv(gethitRate(trials).faRate);
end

% Experiment using the embedded function (helper fnc)
function [hitRate_30US, hitRate_30S, hitRate_50US, faRate] = gethitRate(trials);
%written by Faye 221020
%   Detailed explanation goes here
hits = [trials.trialEnd]==0;
FA = [trials.trialEnd]==1;
miss = [trials.trialEnd]==2;
visualStim30 = floor([trials.visualStimValue])==30;
meanPowerPresent = [trials.meanPowerMW]~=0;

% 30% Unstimulated Hit Rate
num = sum(hits & visualStim30 & ~meanPowerPresent);
denom = sum(or(hits, miss) & visualStim30 & ~meanPowerPresent);
hitRate_30US = num/denom;

% 30% Stimulated Hit Rate
num = sum(hits & visualStim30 & meanPowerPresent);
denom = sum(or(hits, miss) & visualStim30 & meanPowerPresent);
hitRate_30S = num/denom;

% 50% Unstimulated Hit Rate
num = sum(hits & ~visualStim30 & ~meanPowerPresent);
denom = sum(or(hits, miss) & ~visualStim30 & ~meanPowerPresent);
hitRate_50US = num/denom;

% FA Rate
num = sum(FA);
denom = length([trials]);
faRate = num/denom;
end
