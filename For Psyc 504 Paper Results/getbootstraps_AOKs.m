function [outputArg1,outputArg2] = getbootstraps_AOKs
%% Summary
%inserts function for metric of interest to grab its bootstrap and AOK and
%plots them

%% Define Variable
[leftProfiles, rightProfiles] = getdelta_d_profiles_abov_bel_mean; %replace with function that grabs profiles for metrics of interest

%% Bootstrap

% Filter SetUp
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

% Bootstrap

% Compute below mean w/ SEM
bootleft_AOK = bootstrp(1000,@mean,leftProfiles);
leftPCs = prctile(bootleft_AOK, [15.9, 50, 84.1]); % +/- 1 SEM
leftPCMeans = mean(leftPCs, 2);
leftCIs = zeros(3, size(leftProfiles, 2));
for c = 1:3
    leftCIs(c,:) = filtfilt(filterLP, leftPCs(c,:) - leftPCMeans(c)) + leftPCMeans(c);
end
leftx = 1:size(leftCIs, 2);
x2 = [leftx, fliplr(leftx)];
bins = size(leftCIs,2);

%above mean w/ SEM
bootright_AOK = bootstrp(1000,@mean,rightProfiles);
rightPCs = prctile(bootright_AOK, [15.9, 50, 84.1]); % +/- 1 SEM
rightPCMeans = mean(rightPCs, 2);
rightCIs = zeros(3, size(rightProfiles, 2));
for c = 1:3
    rightCIs(c,:) = filtfilt(filterLP, rightPCs(c,:) - rightPCMeans(c)) + rightPCMeans(c);
end
rightx = 1:size(rightCIs, 2);

%% Get AOK

% Get Kernels for AOK
leftAOK_KDE = leftProfiles(:,401:500);
rightAOK_KDE = rightProfiles(:,401:500);

% Compute left AOK
bootleft_AOK = bootstrp(100,@mean,leftAOK_KDE);
bootleft_AOK = -(bootleft_AOK); %makes values positive
leftAOK = sum(bootleft_AOK,2);

%right AOK
bootright_AOK = bootstrp(100,@mean,rightAOK_KDE);
bootright_AOK = -(bootright_AOK); %makes values positive
rightAOK = sum(bootright_AOK,2);

%% Plots

%create tiled layout for all plots
figure;
t= tiledlayout(2,2);
title(t,'Delta dprime Kernels and AOK') %replace title with correct metric of interest

%Bootstrap w/ SEM

%below mean
ax1 = nexttile;
hold on
plot(leftCIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
leftfillCI = [leftCIs(1, :), fliplr(leftCIs(3, :))]; % This sets up the fill for the errors
fill(x2, leftfillCI, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
yline(0,'--k')
hold off
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [-0.04 0.02]);
ay.FontSize = 8;
title('Kernel of Below Mean Profiles','FontSize',8);

%above mean
ax2 = nexttile (3);
hold on
plot(rightx, rightCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
rightfillCI = [rightCIs(1, :), fliplr(rightCIs(3, :))]; % This sets up the fill for the errors
fill(x2, rightfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
yline(0,'--k')
hold off
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XMinorGrid = "on";
ax.XTick = [0:200:800];
ax.XTickLabel = {'-400', '-200', '0', '200', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [-0.04 0.02]);
ay.FontSize = 8;
title('Kernel of Above Mean Profiles','FontSize',8); 

%Axes Label
xlabel([ax1 ax2],'Time Relative to Stimulus Onset (ms)','FontSize',8)
ylabel([ax1 ax2],'Normalized Power','FontSize',8) 




%AOK

%Left
nexttile;
hold on
histogram(leftAOK,'Normalization','probability',FaceColor="b")
xline(0,'--k')
hold off
title('AOK of Below Mean Profiles','FontSize',8);
ay = gca;
ylim(ay, [0 0.4]); %adjust to correct limits
ay.FontSize = 8;
ylabel('Probability','FontSize',8)
ax = gca;
xlim(ax, [-4, 4]);
ax.XTick = [-4:1:4];
ax.XTickLabel = {'-4', '', '-2', '', '0', '', '2', '', '4'};
ax.FontSize = 7;
ax.TickDir = "out";
xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)

%Right
nexttile;
hold on
histogram (rightAOK,'Normalization','probability',FaceColor="r")
xline(0,'--k')
hold off
title('AOK of Above Mean Profiles','FontSize',8);
ay = gca;
ylim(ay, [0 0.4]); %adjust to  correct limits
ay.FontSize = 8;
ylabel('Probability',FontSize=8)
ax = gca;
xlim(ax, [-4, 4]);
ax.XTick = [-4:1:4];
ax.XTickLabel = {'-4', '', '-2', '', '0', '', '2', '', '4'};
ax.FontSize = 7;
ax.TickDir = "out";
xlabel('Area Over the Kernel (normalized power*ms)',FontSize=8)

end