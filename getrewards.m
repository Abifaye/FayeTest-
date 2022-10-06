function [rewards] = getrewards(trials)
% Written by Faye 220928
%Function takes session data from OKernel "trials" as input
%returns an array of rewards 
rewards = [trials.reward];
end