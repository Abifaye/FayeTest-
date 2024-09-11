function [leftIdx,rightIdx] = getRate_abovBel_mean(T)
%Sort kernels for V1/SC of Gabor/Luminance trials using false alarm/hit rate.
%Trials are categorized as below or above mean of false rate for each
%session

% %Go to folder with the rolling rate function
% cd(uigetdir('', 'Choose folder containing getrollingrates function'));

%get the rolling rate of desired variable specified as "session by session averages"
%and indicate the desired window length for the rolling rate
[masterRollRates] = getrollingrates(T);

%% Sort trials using above/below rate mean

%Init vars for indices
leftIdx = {}; % for trials below mean
rightIdx = {}; %above mean

%loop through each session
for nSession = 1:size(T,1)

    % init vars
    sessRate = masterRollRates.(1){nSession};

    %find the mean fa rate for the session
    M = mean(sessRate);

    %classify each trial based on whether their FA rate is above or below the
    %mean FA rate of the session
    leftIdx{nSession} = sessRate<M;
    rightIdx{nSession} = sessRate>M;

end

%% for checking if it works

%Init matrices for profiles below (leftprofiles) and above (rightprofiles)
%mean
% leftProfiles = [];
% rightProfiles = [];
%init matrices for hit profiles for left and right of mean
% hitsLeft = [];
% hitsRight = [];


% loop through all sessions
% for nSession = 1:size(T,1)
% 
%     %Init Vars
%     hitPros = [T.hitProfiles{nSession}];
%     missPros = [T.missProfiles{nSession}];
%     comboPros = [hitPros;-missPros];
%     sessHits = [T.hit{nSession}];
%     sessMiss = [T.miss{nSession}];
%     sessPower = [T.optoPowerMW{nSession}];
%     sessLeftIdx = [leftIdx{nSession}];
%     sessRightIdx = [rightIdx{nSession}];

    % filter each session so that only stimulated hits/misses trials are
    %included for further classification
    % leftIdx_hits = sessLeftIdx(sessHits==1 & sessPower~=0);
    % lefttIdx_miss = sessLeftIdx(sessMiss==1 & sessPower~=0);
    % leftIdx_combo = [leftIdx_hits';lefttIdx_miss'];
    % rightIdx_hits = sessRightIdx(sessHits==1 & sessPower~=0);
    % rightIdx_miss = sessRightIdx(sessMiss==1 & sessPower~=0);
    % rightIdx_combo = [rightIdx_hits';rightIdx_miss'];

    %grab the miss+hits profiles and hit outcomes corresponding to the indices
%     leftProfiles = [leftProfiles;comboPros(leftIdx_combo==1,:)];
%     rightProfiles = [rightProfiles;comboPros(rightIdx_combo==1,:)];
%     hitsLeft = [hitsLeft; hitPros(leftIdx_hits==1,:)];
%     hitsRight = [hitsRight; hitPros(rightIdx_hits==1,:)];
% 
% end
% 
% 
% figure;
% hold on
% plot(mean(leftProfiles))
% plot(mean(rightProfiles))
% hold off
% legend('Below FA Mean', 'Above FA Mean')





end