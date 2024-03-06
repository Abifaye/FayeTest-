%% Correlation Plots

%Hits
load normData_hit.mat
load hitDataTable.mat
T_hit = array2table(normData_hit,'VariableNames',hitDataTable.Properties.VariableNames(5:8));

figure;
corrplot(T_hit)

%Miss
load normData_miss.mat
load missDataTable.mat
T_miss = array2table(normData_miss,'VariableNames',missDataTable.Properties.VariableNames(5:7));

figure;
corrplot(T_miss)

%all
load normData.mat
load masterDBDataTable.mat
T_all = array2table(normData,'VariableNames',masterDBDataTable.Properties.VariableNames(5:9));

figure;
corrplot(T_all)



