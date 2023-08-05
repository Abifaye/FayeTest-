function [outputArg1,outputArg2] = getDBScanPlots
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
DBdata = DBStruct(1).(strcat('data',num2str(input(strcat('Choose Data Number from DBStruct to create plot for:',32)))));
input(strcat('Number of clusters:',32));
%here add a matrix before the input for numbers 1 - 5 clusters, then if
%statement for if it is greater than 5 (start with the if statement seeing
clr = ['r','b','g','k']; 
%if it is 1 - 5 which would apply the matrix, if not use the hsv 
xVar = listdlg('PromptString',{'Select x-var'},'ListString',masterDataTable.Properties.VariableNames,'SelectionMode','single');
yVar = listdlg('PromptString',{'Select y-var'},'ListString',masterDataTable.Properties.VariableNames,'SelectionMode','single');

figure;
gscatter(masterDataTable.xVar,masterDataTable.yVar,DBdata,clr)%check if using xVar and yVar works
title('Data 29 Hits')
xlabel('Rolling RTs')
ylabel('Rolling Hit Rate')

input(strcat('Create another plot for current data? [Y=1/N=0]:',32));
%create while loop for every time we say yes it asks for xVar and yVar
%dialogue again and also make a plot otherwise end the run

masterDataTable.Properties.VariableNames
end