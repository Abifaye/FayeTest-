%% First Initialization
c = -1:0.5:1; % vector for criterion
signalMean = 0:0.5:4; % Vector for Mean of Signal Distribution
Var = 1; % Variance
nSimTrials = 500; %number of trials
MasterStruct = struct('signal', [], 'c', [], 'hitRates', [], 'missRates', [], 'faRates', [], 'crRates', []); %contains
%the criterion and dprimes of different tRounds (need to come up with
%better field names)
 outcomeContainer = zeros(nSimTrials,1);%contains outcomes for each number round of trials
counter = 0;

%% Nested Simulation loop
for  ndprimeRound = 1:length(signalMean) %for loop that will run different rounds of dprimes

    for nCriterionRound = 1:length(c) %loop that will run diffierent rounds of criterion
        counter = counter+1;

        %initialization for each Round

        signal = normrnd(0, Var,[1,nSimTrials]);
        pCatch = 0.2; % proportion of catch trials
        trialType = rand(1,nSimTrials); % uniform distribtion
        signalTrialIdx = trialType > pCatch; % Idx of where signal occurs
        signal(signalTrialIdx) = normrnd(signalMean(ndprimeRound), Var, [1, sum(signalTrialIdx)]);
        % Vector of the signal, the signal the animal sees whether or not there was
        % a stimulus
        for trialNum = 1:nSimTrials %for loop for going through each nSimtrial #


            %Outcome legend

            %Hit = 1
            %Miss = 2
            %FA = 3
            %CR = 4

            % Not a catch trial
            if signalTrialIdx(trialNum) == 1 %if stimulus present
                if signal(trialNum) > c(nCriterionRound) %If greater than the the criterion of this round
                    outcomeContainer(trialNum)  = 1; %Hit
                elseif signal(trialNum) <= c(nCriterionRound) %If less than/= to criterion of this round
                    outcomeContainer(trialNum)  = 2; %Miss
                end

                % Catch Trial
            elseif signalTrialIdx(trialNum) == 0
                if signal(trialNum) > c(nCriterionRound)
                    outcomeContainer(trialNum)  = 3; %FA
                elseif signal(trialNum) <= c(nCriterionRound)
                    outcomeContainer(trialNum)  = 4; %CR
                end
            end
            % Summary stats

            % Propotion hits (hit rate)
            num_hits = sum(outcomeContainer==1);
            denom_hits = sum(outcomeContainer==1) + ...
                sum(outcomeContainer==2);

            % Propotion miss (miss rate)
            num_miss = sum(outcomeContainer==2);
            denom_miss = sum(outcomeContainer==1) + ...
                sum(outcomeContainer==2);

            % Propotion FA (FA rate)
            num_fa = sum(outcomeContainer==3);
            denom_fa = sum(outcomeContainer==3) + ...
                sum(outcomeContainer==4);

            % Propotion CR (CR rate)
            num_cr = sum(outcomeContainer==4);
            denom_cr = sum(outcomeContainer==1) + ...
                sum(outcomeContainer==2);

            % compute outcomes rates
            hitRate = num_hits./denom_hits;
            missRate = num_miss./denom_miss;
            faRate = num_fa./denom_fa;
            crRate = num_cr./denom_cr;

            %Output Results
        MasterStruct(counter).hitRates = hitRate;
        MasterStruct(counter).missRates = missRate;
        MasterStruct(counter).faRates = faRate;
        MasterStruct(counter).crRates = crRate;
        end
        % Output Results
        %MasterStruct(end+1).dprime = outcomeContainer(nCriterionRound);

        MasterStruct(counter).c = c(nCriterionRound);
        MasterStruct(counter).signal = signalMean(ndprimeRound);
    end
     
end


%% Plots

% hitRate
figure;
plot([MasterStruct.hitRates]) 

%plot hit rate as function of both d' and c

%plot function
x1 =[MasterStruct.signal];
y1 =[MasterStruct.hitRates];
x2 = [MasterStruct.c];
y2 = [MasterStruct.hitRates];
t = tiledlayout(1,1); %Create a 1-by-1 tiled chart layout t
ax1 = axes(t);%Create an axes object ax1 by calling the axes function and 
%specifying t as the parent object
plot(ax1,x1,y1,'-r') %Plot x1 and y1 as a red line, and specify ax1 as the target axes
ax1.XColor = 'r'; %Change the color of the x-axis to match the plotted line
ax1.YColor = 'r';% Change the color of the y-axis to match the plotted line
ax1.XLabel.String = 'dprime';
ax1.XLabel.Color = 'k';
ax1.YLabel.String = 'Hit Rate';
ax1.YLabel.Color = 'k';
ax2 = axes(t);
plot(ax2,x2,y2,'-k')
ax2.XAxisLocation = 'top';%Move the x-axis to the top
ax2.YAxisLocation = 'right';%move the y-axis to the right
ax2.Color = 'none'; %Set the color of the axes object to 'none' so that the
%underlying plot is visible
ax2.XLabel.String = 'c';
ax1.Box = 'off';%turn off the plot boxes to prevent the box edges from obscuring the x-axes
ax2.Box = 'off';%turn off the plot boxes to prevent the box edges from obscuring the y-axes
ax1.FontSize(gca,13,"pixels");
% ax1.Title.String ='Hit Rate as Function of dprime and c';
% ax1.TitleHorizontalAlignment = 'left'


%heatmap of hit rate
tsignal =[MasterStruct.signal];
tHit =[MasterStruct.hitRates];
tC = [MasterStruct.c];
tbl = table(tsignal(:),tHit(:),tC(:));
tbl.Properties.VariableNames{1} = 'dprime';
tbl.Properties.VariableNames{2} = 'Hits';
tbl.Properties.VariableNames{3} = 'Criterion';
h = heatmap(tbl,'dprime','Criterion','ColorVariable','Hits','ColorMethod','none');
h.Title = 'Hit Rate as a Function of dprime and Criterion';

%missRate
figure;
plot([MasterStruct.missRates])

%misses as function of dprime and criterion
x1 =[MasterStruct.signal];
y1 =[MasterStruct.missRates];
x2 = [MasterStruct.c];
y2 = [MasterStruct.missRates];
t = tiledlayout(1,1); %Create a 1-by-1 tiled chart layout t
ax1 = axes(t);%Create an axes object ax1 by calling the axes function and 
%specifying t as the parent object
plot(ax1,x1,y1,'-r') %Plot x1 and y1 as a red line, and specify ax1 as the target axes
ax1.XColor = 'r'; %Change the color of the x-axis to match the plotted line
ax1.YColor = 'r';% Change the color of the y-axis to match the plotted line
ax1.XLabel.String = 'dprime';
ax1.XLabel.Color = 'r';
ax1.YLabel.String = 'Miss Rate';
ax1.YLabel.Color = 'r';
ax2 = axes(t);
plot(ax2,x2,y2,'-k')
ax2.XAxisLocation = 'top';%Move the x-axis to the top
ax2.YAxisLocation = 'right';%move the y-axis to the right
ax2.Color = 'none'; %Set the color of the axes object to 'none' so that the
%underlying plot is visible
ax2.XLabel.String = 'c';
ax1.Box = 'off';%turn off the plot boxes to prevent the box edges from obscuring the x-axes
ax2.Box = 'off';%turn off the plot boxes to prevent the box edges from obscuring the y-axes
ax1.FontSize(gca,13,"pixels");

%heatmap of fa rate
tsignal =[MasterStruct.signal];
tmiss =[MasterStruct.missRates];
tC = [MasterStruct.c];
tbl = table(tsignal(:),tmiss(:),tC(:));
tbl.Properties.VariableNames{1} = 'dprime';
tbl.Properties.VariableNames{2} = 'Misses';
tbl.Properties.VariableNames{3} = 'Criterion';
h = heatmap(tbl,'dprime','Criterion','ColorVariable','Misses','ColorMethod','none');
h.Title = 'Miss Rate as a Function of dprime and Criterion';

%faRate
figure;
plot([MasterStruct.faRates])

%fa as function of dprime and criterion
x1 =[MasterStruct.signal];
y1 =[MasterStruct.faRates];
x2 = [MasterStruct.c];
y2 = [MasterStruct.faRates];
t = tiledlayout(1,1); %Create a 1-by-1 tiled chart layout t
ax1 = axes(t);%Create an axes object ax1 by calling the axes function and 
%specifying t as the parent object
plot(ax1,x1,y1,'-r') %Plot x1 and y1 as a red line, and specify ax1 as the target axes
ax1.XColor = 'r'; %Change the color of the x-axis to match the plotted line
ax1.YColor = 'r';% Change the color of the y-axis to match the plotted line
ax1.XLabel.String = 'dprime';
ax1.XLabel.Color = 'r';
ax1.YLabel.String = 'False Alarm Rate';
ax1.YLabel.Color = 'r';
ax2 = axes(t);
plot(ax2,x2,y2,'-k')
ax2.XAxisLocation = 'top';%Move the x-axis to the top
ax2.YAxisLocation = 'right';%move the y-axis to the right
ax2.Color = 'none'; %Set the color of the axes object to 'none' so that the
%underlying plot is visible
ax2.XLabel.String = 'c';
ax1.Box = 'off';%turn off the plot boxes to prevent the box edges from obscuring the x-axes
ax2.Box = 'off';%turn off the plot boxes to prevent the box edges from obscuring the y-axes
ax1.FontSize(gca,13,"pixels");

%heatmap of miss rate
tsignal =[MasterStruct.signal];
tmiss =[MasterStruct.missRates];
tC = [MasterStruct.c];
tbl = table(tsignal(:),tmiss(:),tC(:));
tbl.Properties.VariableNames{1} = 'dprime';
tbl.Properties.VariableNames{2} = 'Misses';
tbl.Properties.VariableNames{3} = 'Criterion';
h = heatmap(tbl,'dprime','Criterion','ColorVariable','Misses','ColorMethod','none');
h.Title = 'Miss Rate as a Function of dprime and Criterion';


%heatmap of fa rate
tsignal =[MasterStruct.signal];
tfa =[MasterStruct.faRates];
tC = [MasterStruct.c];
tbl = table(tsignal(:),tfa(:),tC(:));
tbl.Properties.VariableNames{1} = 'dprime';
tbl.Properties.VariableNames{2} = 'False Alarm';
tbl.Properties.VariableNames{3} = 'Criterion';
h = heatmap(tbl,'dprime','Criterion','ColorVariable','False Alarm','ColorMethod','none');
h.Title = 'False Alarm Rate as a Function of dprime and Criterion';

%crRAte
figure;
plot([MasterStruct.crRates])

%heatmap of miss rate
tsignal =[MasterStruct.signal];
tmiss =[MasterStruct.missRates];
tC = [MasterStruct.c];
tbl = table(tsignal(:),tmiss(:),tC(:));
tbl.Properties.VariableNames{1} = 'dprime';
tbl.Properties.VariableNames{2} = 'Misses';
tbl.Properties.VariableNames{3} = 'Criterion';
h = heatmap(tbl,'dprime','Criterion','ColorVariable','Misses','ColorMethod','none');
h.Title = 'Miss Rate as a Function of dprime and Criterion';

%faRate
figure;
plot([MasterStruct.faRates])

%cr as function of dprime and criterion
x1 =[MasterStruct.signal];
y1 =[MasterStruct.crRates];
x2 = [MasterStruct.c];
y2 = [MasterStruct.crRates];
t = tiledlayout(1,1); %Create a 1-by-1 tiled chart layout t
ax1 = axes(t);%Create an axes object ax1 by calling the axes function and 
%specifying t as the parent object
plot(ax1,x1,y1,'-r') %Plot x1 and y1 as a red line, and specify ax1 as the target axes
ax1.XColor = 'r'; %Change the color of the x-axis to match the plotted line
ax1.YColor = 'r';% Change the color of the y-axis to match the plotted line
ax1.XLabel.String = 'dprime';
ax1.XLabel.Color = 'r';
ax1.YLabel.String = 'False Alarm Rate';
ax1.YLabel.Color = 'r';
ax2 = axes(t);
plot(ax2,x2,y2,'-k')
ax2.XAxisLocation = 'top';%Move the x-axis to the top
ax2.YAxisLocation = 'right';%move the y-axis to the right
ax2.Color = 'none'; %Set the color of the axes object to 'none' so that the
%underlying plot is visible
ax2.XLabel.String = 'c';
ax1.Box = 'off';%turn off the plot boxes to prevent the box edges from obscuring the x-axes
ax2.Box = 'off';%turn off the plot boxes to prevent the box edges from obscuring the y-axes
ax1.FontSize(gca,13,"pixels");


%heatmap of cr rate
tsignal =[MasterStruct.signal];
tcr =[MasterStruct.crRates];
tC = [MasterStruct.c];
tbl = table(tsignal(:),tcr(:),tC(:));
tbl.Properties.VariableNames{1} = 'dprime';
tbl.Properties.VariableNames{2} = 'Correct Rejection';
tbl.Properties.VariableNames{3} = 'Criterion';
h = heatmap(tbl,'dprime','Criterion','ColorVariable','Correct Rejection','ColorMethod','none');
h.Title = 'Correct Rejection Rate as a Function of dprime and Criterion';

%%
% We don't gain much after 500 trials per simulation

% Run sims with 500 trials

% sweep a range of d' and c
%range for d' = 0 : 4  for 0.5 interval
%range of criterion = -1 : 1 for 0.5 interval

% nested for loops (for d, for c)

% for each round of simulation
% Proportion of hits, miss, fa, cr

% Experiment with visualization
% One plot for each measure (hit plot, miss plot)
% one axes is d', one is going be c
% 3d plots, usually are heatmap

% Bar Graph
% with d' and c (2 rows on bottom of bar)
% could make one bar graph per outcome type (H, M, FA, CR)
% You could combine, and color code bars by outcome
% show each type together for each, d'; c


