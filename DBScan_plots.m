%% Plots: roll ave RTs
%set tiled layout
figure;
t= tiledlayout(3,2);
title(t,'Rolling Averages for Reaction Times')

%ax = gca;
%xlim(ax, [0, bins]);
%ax.XGrid = 'on';
%ax.XMinorGrid = "on";
%ax.XTick = [0:200:800];
%ax.XTickLabel = {'-400', '-200', '0', '600', '800'};
%ax.FontSize = 8;
%ax.TickDir = "out";
%ay = gca;
%ylim(ay, [0.47 0.52]);
%ay.FontSize = 8;

%plots
ax1 = nexttile;
plot(cellRT{362})
title('Session 362',8);

ax2 = nexttile;
plot(cellRT{233})
title('Session 233',8);

ax3 = nexttile;
plot(cellRT{192})
title('Session 192',8);


ax4 = nexttile;
plot(cellRT{395})
title('Session 395',8);

ax5 = nexttile;
plot(cellRT{8})
title('Session 8',8);

ax6 = nexttile;
plot(cellRT{213})
title('Session 213',8);

%xlabels
xlim([ax1,ax2,ax3,ax4,ax5,ax6],[0 150])

%ylabels
ylim([ax1,ax2,ax3,ax4,ax5,ax6],[200 450]) 
yticks([ax1,ax2,ax3,ax4,ax5,ax6], [100:100:450])



%% Plots: roll ave rwd
%set tiled layout
figure;
t= tiledlayout(3,2);
title(t,'Rolling Averages for RTs')

%ax = gca;
%xlim(ax, [0, bins]);
%ax.XGrid = 'on';
%ax.XMinorGrid = "on";
%ax.XTick = [0:200:800];
%ax.XTickLabel = {'-400', '-200', '0', '600', '800'};
%ax.FontSize = 8;
%ax.TickDir = "out";
%ay = gca;
%ylim(ay, [0.47 0.52]);
%ay.FontSize = 8;

%plots
ax1 = nexttile;
plot(cellRwd{302})
title('Session 302',8);

ax2 = nexttile;
plot(cellRwd{16})
title('Session 16',8);

ax3 = nexttile;
plot(cellRwd{9})
title('Session 9',8);


ax4 = nexttile;
plot(cellRwd{165})
title('Session 165',8);

ax5 = nexttile;
plot(cellRwd{215})
title('Session 215',8);

ax6 = nexttile;
plot(cellRwd{156})
title('Session 156',8);

%xlabels
xlim([ax1,ax2,ax3,ax4,ax5,ax6],[0 700])

%ylabels
ylim([ax1,ax2,ax3,ax4,ax5,ax6],[0 2.5]) 
yticks([ax1,ax2,ax3,ax4,ax5,ax6],[0:1:2.5])

%% Plots: rolling hit rate
figure;
t= tiledlayout(3,2);
title(t,'Rolling Hit Rate')

%ax = gca;
%xlim(ax, [0, bins]);
%ax.XGrid = 'on';
%ax.XMinorGrid = "on";
%ax.XTick = [0:200:800];
%ax.XTickLabel = {'-400', '-200', '0', '600', '800'};
%ax.FontSize = 8;
%ax.TickDir = "out";
%ay = gca;
%ylim(ay, [0.47 0.52]);
%ay.FontSize = 8;

ax1 = nexttile;
plot(cellHitRate{362})
title('Session 362',FontSize=8);

ax2 = nexttile;
plot(cellHitRate{233})
title('Session 233',FontSize=8);

ax3 = nexttile;
plot(cellHitRate{192})
title('Session 192',FontSize=8);

ax4 = nexttile;
plot(cellHitRate{395})
title('Session 395',FontSize=8);

ax5 = nexttile;
plot(cellHitRate{8})
title('Session 8',FontSize=8);

ax6 = nexttile;
plot(cellHitRate{213})
title('Session 213',FontSize=8);

%xlabels
xlim([ax1,ax2,ax3,ax4,ax5,ax6],[0 600])

%ylabels
ylim([ax1,ax2,ax3,ax4,ax5,ax6],[0 80]) 
yticks([ax1,ax2,ax3,ax4,ax5,ax6], [0:20:80])