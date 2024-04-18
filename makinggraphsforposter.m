figure;
t= tiledlayout(2,3);
title(t,'Single Session Example',"FontSize",15)
nexttile;
plot(cell2mat(RollAveTable.rollingrewards(1)))
title('Reward')
xlabel('Time(ms)')
ylabel('Rolling Average')
nexttile;
plot(cell2mat(RollAveTable.rollingallRTs(1)))
title('Reaction Times')
nexttile;
plot(cell2mat(masterRollRates.rollinghit(1)))
title('Hit Rate')
nexttile;
plot(cell2mat(masterRollRates.rollingmiss(1)))
title('Miss Rate')
nexttile;
plot(cell2mat(masterRollRates.rollingfa(1)))
title('False Alarm Rate')

A = table(cell2mat(masterRollRates.rollingfa(1))',cell2mat(masterRollRates.rollingmiss(1))',cell2mat(masterRollRates.rollinghit(1))',cell2mat(RollAveTable.rollingallRTs(1))',cell2mat(RollAveTable.rollingrewards(1))');

Anorm = normalize(A);

AnormMat = table2array(Anorm);

clusters = kmeans(AnormMat,5);

clr = 'rgbkm';

figure;
gscatter(A.(1),A.(2),clusters,clr)
legend('Cluster 1','Cluster 2','Cluster 3', 'Cluster 4','Cluster 5')
xlabel('Rolling False Alarm Rate')
ylabel('Rolling Miss Rate')
title('One Session Example')
