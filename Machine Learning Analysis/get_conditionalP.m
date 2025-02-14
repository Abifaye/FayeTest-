function [outputArg1,outputArg2] = get_conditionalP
%creates new logical array of hits, misses, and falls alarm based on if previous
%trial was a hit

%go to folder with mastertable
cd(uigetdir());

%load master table file 
load('masterTable_complete.mat');

%init variables
hits = [T.hit];
miss = [T.miss];
fa = [T.fa];

%% P(hit|hit previous)

%preallocate variables
ptwoHits = [];
session_twoHits = {};

%loop through each session
for nSession = 1:length(hits)
    
    %preallocate logical for each session for getting hit after previous hit trial
    twoHits = [];
%loop through each trial
    for nTrial = 1:length(hits{nSession}) - 1
        if hits{nSession}(nTrial) == 1 && hits{nSession}(nTrial+1) == 1 
        twoHits(nTrial) = 1; %true
        else
              twoHits(nTrial) = 0; %false
        end
    end
    %compute hit P(hit|hit previous)
    ptwoHits(nSession) = sum(twoHits == 1)/length(hits{nSession});
    %place logical into cell
    session_twoHits{nSession} = twoHits;
end

%% P(miss|hit previous)

%preallocate variables
pHit_Miss = [];
session_Hit_Miss = {};

%loop through each session
for nSession = 1:length(hits)

    %preallocate logical for each session for getting miss after previous hit trial 
    hit_Miss = [];
    %loop through each trial
    for nTrial = 1:length(hits{nSession}) - 1
        if hits{nSession}(nTrial) == 1 && miss{nSession}(nTrial+1) == 1
            hit_Miss(nTrial) = 1; %true
        else
            hit_Miss(nTrial) = 0; %false
        end
    end
    %compute hit P(miss|hit previous)
    pHit_Miss(nSession) = sum(hit_Miss == 1)/length(hits{nSession});
    %place logical into cell
    session_Hit_Miss{nSession} = hit_Miss;
end

%% P(fa|hit previous)

%preallocate variables
pHit_Fa = [];
session_Hit_Fa = {};

%loop through each session
for nSession = 1:length(hits)
    %preallocate logical for each session for getting fa after previous hit trial
    hit_Fa = [];
    %loop through each trial
    for nTrial = 1:length(hits{nSession}) - 1
        if hits{nSession}(nTrial) == 1 && fa{nSession}(nTrial+1) == 1
            hit_Fa(nTrial) = 1; %true
        else
            hit_Fa(nTrial) = 0; %false
        end
    end
    %compute hit P(fa|hit previous)
    pHit_Fa(nSession) = sum(hit_Fa == 1)/length(hits{nSession});
    %place logical into cell
    session_Hit_Fa{nSession} = hit_Fa;
end

%% nSession (condition|hit previous) plots

%nSession two_hit plot
figure;
scatter(1:length(session_twoHits{1}),session_twoHits{1},10,"filled")
yticks(-0.5:0.5:1.5);
ylim([-0.5 1.5]);
xticks([min(1:length(session_twoHits{1})):50:max(1:length(session_twoHits{1}))])
title('nSession two hit plot 1')

figure;
scatter(1:length(session_twoHits{375}),session_twoHits{375},10,"filled")
yticks(-0.5:0.5:1.5);
ylim([-0.5 1.5]);
xticks([min(1:length(session_twoHits{375})):50:max(1:length(session_twoHits{375}))])
title('nSession two hit plot 375')

figure;
scatter(1:length(session_twoHits{204}),session_twoHits{204},10,"filled")
yticks(-0.5:0.5:1.5);
ylim([-0.5 1.5]);
xticks([min(1:length(session_twoHits{204})):50:max(1:length(session_twoHits{204}))])
title('nSession two hit plot 204')

%nSession hit_miss plot
figure;
scatter(1:length(session_Hit_Miss{1}),session_Hit_Miss{1},10,"filled")
yticks(-0.5:0.5:1.5);
ylim([-0.5 1.5]);
xticks([min(1:length(session_Hit_Miss{1})):50:max(1:length(session_Hit_Miss{1}))])
title('nSession hit-miss plot 1')

figure;
scatter(1:length(session_Hit_Miss{375}),session_Hit_Miss{375},10,"filled")
yticks(-0.5:0.5:1.5);
ylim([-0.5 1.5]);
xticks([min(1:length(session_Hit_Miss{375})):50:max(1:length(session_Hit_Miss{375}))])
title('nSession hit-miss plot 375')

figure;
scatter(1:length(session_Hit_Miss{204}),session_Hit_Miss{204},10,"filled")
yticks(-0.5:0.5:1.5);
ylim([-0.5 1.5]);
xticks([min(1:length(session_Hit_Miss{204})):50:max(1:length(session_Hit_Miss{204}))])
title('nSession hit-miss plot 204')


%nSession hit_fa plot
figure;
scatter(1:length(session_Hit_Fa{1}),session_Hit_Fa{1},10,"filled")
yticks(-0.5:0.5:1.5);
ylim([-0.5 1.5]);
xticks([min(1:length(session_Hit_Fa{1})):50:max(1:length(session_Hit_Fa{1}))])
title('nSession hit-fa plot 1')

figure;
scatter(1:length(session_Hit_Fa{375}),session_Hit_Fa{375},10,"filled")
yticks(-0.5:0.5:1.5);
ylim([-0.5 1.5]);
xticks([min(1:length(session_Hit_Fa{375})):50:max(1:length(session_Hit_Fa{375}))])
title('nSession hit-fa plot 375')

figure;
scatter(1:length(session_Hit_Fa{204}),session_Hit_Fa{204},10,"filled")
yticks(-0.5:0.5:1.5);
ylim([-0.5 1.5]);
xticks([min(1:length(session_Hit_Fa{204})):50:max(1:length(session_Hit_Fa{204}))])
title('nSession hit-fa plot 204')

%% Probability plots
figure;
hold on
plot(pHit_Fa)
plot(pHit_Miss)
plot(ptwoHits)
legend('fa|hit','miss|hit', 'hit|hit')


end



