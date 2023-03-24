function [outputArg1,outputArg2] = getbootstraps_AOKs
%% Summary

%% Define Variable
[leftProfiles, rightProfiles] = getTopUp_profiles; %replace with function for measurement of interest

%% Bootstrap

% Filter SetUp
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

% Bootstrap

% Compute below mean w/ SEM
bootleft = bootstrp(1000,@mean,leftProfiles);
leftPCs = prctile(bootleft, [15.9, 50, 84.1]); % +/- 1 SEM
leftPCMeans = mean(leftPCs, 2);
leftCIs = zeros(3, size(leftProfiles, 2));
for c = 1:3
    leftCIs(c,:) = filtfilt(filterLP, leftPCs(c,:) - leftPCMeans(c)) + leftPCMeans(c);
end
leftx = 1:size(leftCIs, 2);
x2 = [leftx, fliplr(leftx)];
bins = size(leftCIs,2);

%above mean w/ SEM
bootright = bootstrp(1000,@mean,rightProfiles);
rightPCs = prctile(bootright, [15.9, 50, 84.1]); % +/- 1 SEM
rightPCMeans = mean(rightPCs, 2);
rightCIs = zeros(3, size(rightProfiles, 2));
for c = 1:3
    rightCIs(c,:) = filtfilt(filterLP, rightPCs(c,:) - rightPCMeans(c)) + rightPCMeans(c);
end
rightx = 1:size(rightCIs, 2);

%% Get AOK

% Compute left AOK
bootleft = bootstrp(100,@mean,leftProfiles);
bootleft = -(bootleft);
for nBoot = 1:size(bootleft,1)
    nAOK = sum(bootleft(nBoot,401:500));
    leftAOK(nBoot) = nAOK;
end

%right AOK
bootright = bootstrp(100,@mean,rightProfiles);
bootright = -(bootright);
for nBoot = 1:size(bootright,1)
    nAOK = sum(bootright(nBoot,401:500)); 
    rightAOK(nBoot) = nAOK;
end

%% Plots

%
figure;
t = tiledlayout(2,2);
ax1 = axes(t);
xlabel(ax1, 'First Interval') %i was gonna relabel it
%xlabel(aokgraphs,'Area Over the Kernel (normalized power*ms)')
%ylabel(aokgraphs,'Probability')

%Bootstrap w/ SEM

%below mean
ax1 = nexttile;
hold on
plot(leftx, leftCIs(2, :), 'b', 'LineWidth', 1.5); % This plots the mean of the bootstrap
leftfillCI = [leftCIs(1, :), fliplr(leftCIs(3, :))]; % This sets up the fill for the errors
fill(x2, leftfillCI, 'b', 'lineStyle', '-', 'edgeColor', 'b', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
hold off
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XTick = [0, 100, 200, 300, 400, 500, 600, 700, 800];
ax.XTickLabel = {'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [-0.04 0.02]);
ay.FontSize = 8;
title('Kernel of Below Mean Profiles','FontSize',8);

%above mean
ax1 = nexttile(3);
hold on
plot(rightx, rightCIs(2, :), 'r', 'LineWidth', 1.5); % This plots the mean of the bootstrap
rightfillCI = [rightCIs(1, :), fliplr(rightCIs(3, :))]; % This sets up the fill for the errors
fill(x2, rightfillCI, 'r', 'lineStyle', '-', 'edgeColor', 'r', 'edgeAlpha', 0.5, 'faceAlpha', 0.10); % add fill
hold off
ax = gca;
xlim(ax, [0, bins]);
ax.XGrid = 'on';
ax.XTick = [0, 100, 200, 300, 400, 500, 600, 700, 800];
ax.XTickLabel = {'-400', '-300', '-200', '-100', '0', '100', '200', '300', '400'};
ax.FontSize = 8;
ax.TickDir = "out";
ay = gca;
ylim(ay, [-0.04 0.02]);
ay.FontSize = 8;
title('Kernel of Above Mean Profiles','FontSize',8); 

xlabel(ax1,'Time Relative to Stimulus Onset (ms)')
ylabel(ax1,'Normalized Power')


%AOK

%Left
nexttile 
hold on
histogram(leftAOK,'Normalization','probability',FaceColor="b")
xline(0,'--k')
hold off
title('AOK of Below Mean Profiles','FontSize',8);
ay = gca;
ylim(ay, [0 0.5]); %adjust to have same y-axis
ay.FontSize = 8;
ax = gca;
xlim(ax, [-2.5, 2.5]);
ax.XTick = [-2.5:0.5:2.5];
ax.XTickLabel = {'', '-2', '', '-1', '', '0', '', '1', '', '2',''};
ax.FontSize = 7;
ax.TickDir = "out";

%Right
nexttile
hold on
histogram (rightAOK,'Normalization','probability',FaceColor="r")
xline(0,'--k')
hold off
title('AOK of Above Mean Profiles','FontSize',8);
ay = gca;
ylim(ay, [0 0.5]); %adjust to have same y-axis
ay.FontSize = 8;
ax = gca;
xlim(ax, [-2.5, 2.5]);
ax.XTick = [-2.5:0.5:2.5];
ax.XTickLabel = {'', '-2', '', '-1', '', '0', '', '1', '', '2',''};
ax.FontSize = 7;
ax.TickDir = "out";

end