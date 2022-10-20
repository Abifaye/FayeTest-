function [dprime, c] = getdprime_general(pHit, pFA)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
dprime = norminv(gethitRate(trials).hitRate_30US) - norminv(gethitRate(trials).faRate);
c = 1; % will need to compute c later
end

% Keep this a general function