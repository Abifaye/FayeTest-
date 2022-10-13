function [date] = getdate('/Users/mouseuser/Documents/GitHub/FayeTest-');
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

fileDir = dir('*.mat');
arrayFileName = struct2cell(fileDir);
strFileName =  string(arrayFileName);
delimiters = ".mat";
date = strtok(strFileName(1),delimiters);
end