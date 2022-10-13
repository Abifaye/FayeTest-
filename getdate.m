function [date] = getdate(pwd);
%created by Faye 2210113
% inputs to the current folder, finds file name, and take only the date from file name
%pwd accesses current folder
 %access file name
date = erase(dir('*.mat').name,'.mat');

end
