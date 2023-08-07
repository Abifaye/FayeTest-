function getDBScanPlots
load DBStruct.mat
load masterDataTable.mat
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
DBdata = input(strcat('Choose Data Number from DBStruct to create plot for:',32))+1;
Fields = fieldnames(DBStruct);
xVar = listdlg('PromptString',{'Select x-var'},'ListString',masterDataTable.Properties.VariableNames,'SelectionMode','single');
yVar = listdlg('PromptString',{'Select y-var'},'ListString',masterDataTable.Properties.VariableNames,'SelectionMode','single');
%
clrMat= flip({['r', 'b', 'g', 'k', 'y', 'c']; [ 'r' 'b' 'g' 'k' 'y']; ['r' 'b' 'g' 'k']; ['r' 'b' 'g']; ['r' 'b']}); 
%
clrNum = DBStruct(4).(string(Fields(DBdata)));

if clrNum < 6 
clr = cell2mat(clrMat(clrNum));
elseif clrNum > 5
    clr = hsv(clrNum);
end

figure;
gscatter(masterDataTable.(xVar),masterDataTable.(yVar),DBStruct(1).(string(Fields(DBdata))),clr)%check if using xVar and yVar works
title(string(Fields(DBdata)))
xlabel(masterDataTable.Properties.VariableNames{xVar})
ylabel(masterDataTable.Properties.VariableNames{yVar})

addPlot = input(strcat('Create another plot for current data? [Y=1/N=0]:',32));

while addPlot == 1
    xVar = listdlg('PromptString',{'Select x-var'},'ListString',masterDataTable.Properties.VariableNames,'SelectionMode','single');
    yVar = listdlg('PromptString',{'Select y-var'},'ListString',masterDataTable.Properties.VariableNames,'SelectionMode','single');
    
   figure;
gscatter(masterDataTable.(xVar),masterDataTable.(yVar),DBStruct(1).(string(Fields(DBdata))),clr)%check if using xVar and yVar works
title(string(Fields(DBdata)))
xlabel(masterDataTable.Properties.VariableNames{xVar})
ylabel(masterDataTable.Properties.VariableNames{yVar})
    addPlot = input(strcat('Create another plot for current data? [Y=1/N=0]:',32));
end

%COUNTINUE HERE uitable('Data', A.labels([1:3 5 6])) this might not work.
%Instead try going from 2:10 minpts for any of the stuff for eps_range. We
%need to double check this because the number of outliers are very small
%for such a large eps (Not sure if this is very good or not. Anyway, it
%might make very insignificant results if we replot them as kernels

end
