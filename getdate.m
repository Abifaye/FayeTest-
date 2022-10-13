function [date] = getdate(pwd);
%created by Faye 2210113
% inputs to the current folder, finds file name, convert it to a
% string, and finally sparse the date from file name
%pwd accesses current folder
fileDir = dir('*.mat'); %access file name
arrayFileName = struct2cell(fileDir); %converts file name from struct to cell
strFileName =  string(arrayFileName); %converts cell to string
delimiters = ".mat"; %set part to be removed from file name
date = strtok(strFileName(1),delimiters); %date is left
end
