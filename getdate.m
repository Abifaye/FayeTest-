function [date] = getdate('/Users/mouseuser/Documents/GitHub/FayeTest-');
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

dir '*.mat'

date = strip('','both','.mat')
end