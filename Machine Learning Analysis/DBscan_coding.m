%% Initializing Variables

%% DBscan
[DBStructData] = getDBScanner;

save_struct = input(strcat('Save struct? [Yes=1/No=0]',32)); %decide whether to save the DBSCAN data generated

if save_struct==1
save(uiputfile('*.mat', 'Create a New File or Select a File to Overwrite'),"DBStructData") %save new/overwrite struct
end

getDBScanPlots






