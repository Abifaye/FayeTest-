function getquintile
%Splits RTs into tertile and takes the corresponding
%hit profiles and plot it. It then bootsraps each tertile and grabs the AOK for each tertile and create a plot
%of it

%% Initialize variables

%Go to folder with the master table
cd(uigetdir('', 'Choose folder containing master table'));

%load master table of interest
load(uigetfile('','Choose master table of interest'));

%init locations for profiles in each tertile
firstQuintile= [];
secondQuintile = [];
thirdQuintile = [];
fourthQuintile = [];
fifthQuintile = [];

%% Create loop for getting hit profiles and putting them in each Tertile matrix

%loop through all sessions
for nSession = 1:height(T)

    %create variables for hit profiles and reaction times from the master
    %table
    RTs = cell2mat(T.stimCorrectRTs(nSession));
    hitPros = cell2mat(T.hitProfiles(nSession));

    %creates range for each tertile
    firstIdx = (RTs >= min(prctile(RTs,[0 20])) & RTs <= max(prctile(RTs,[0 20])));
    secondIdx = (RTs > min(prctile(RTs,[20 40])) & RTs <= max(prctile(RTs,[20 40])));
    thirdIdx = (RTs > min(prctile(RTs,[40 60])) & RTs <= max(prctile(RTs,[40 60])));
    fourthIdx = (RTs > min(prctile(RTs,[60 80])) & RTs <= max(prctile(RTs,[60 80])));
    fifthIdx = (RTs > min(prctile(RTs,[80 100])) & RTs <= max(prctile(RTs,[80 100])));

    %Grabs all trials in current session and appends them to the
    %appropriate matrix
    firstQuintile = [firstQuintile; hitPros(firstIdx,:)];
    secondQuintile = [secondQuintile; hitPros(secondIdx,:)];
    thirdQuintile = [thirdQuintile; hitPros(thirdIdx,:)];
    fourthQuintile = [fourthQuintile; hitPros(fourthIdx,:)];
    fifthQuintile = [fifthQuintile; hitPros(fifthIdx,:)];
end

% Correct the values since we aren't including the misses
firstQuintile = firstQuintile/2 + 0.5;
secondQuintile = secondQuintile/2 + 0.5;
thirdQuintile = thirdQuintile/2 + 0.5;
fourthQuintile = fourthQuintile/2 + 0.5;
fifthQuintile = fifthQuintile/2 + 0.5;

%find the mean
MFirstQuint = mean(firstQuintile);
MSecondQuint = mean(secondQuintile);
MthirdQuint = mean(thirdQuintile);
MfourthQuint = mean(fourthQuintile);
MfifthQuint = mean(fifthQuintile);

%
quintStruct = struct('firstQuint',firstQuintile, 'secondQuint', secondQuintile, 'thirdQuint', thirdQuintile, 'fourthQuint', fourthQuintile, 'fifthQuint', fifthQuintile);
quintFields = fieldnames(quintStruct);

%% HeatMap Plot
varNames = ['Quintile', string(1:800)];
sz = [5 801];
timeVar = repmat({'double'},1,800);
varTypes = ['string', timeVar];
TheatMap = table('size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
TheatMap.Quintile = {'FirstQuint','secondQuint','thirdQuint','fourthQuint','fifthQuint'}';
TheatMap(:,2:end) = array2table(vertcat(MFirstQuint,MSecondQuint,MthirdQuint,MthirdQuint,MfifthQuint));
xvar = TheatMap.Properties.VariableNames(2:end);
yvar = string(TheatMap.(1));
cvar = TheatMap{:,2:end};
%plot
figure;
heatmap(xvar,yvar,cvar)



%% Kernel Bootstrap

% Filter SetUp

% Set Up Filter for Profiles
sampleFreqHz = 1000;
filterLP = designfilt('lowpassfir', 'PassbandFrequency', 90 / sampleFreqHz, ...
    'StopbandFrequency', 2 * 90 / sampleFreqHz, 'PassbandRipple', 1, 'StopbandAttenuation', 60, ...
    'DesignMethod','equiripple');

% Compute quintiles w/ SEM

%init vars for loop
CIsCell = {};
x = [];
x2 = [];
bins = [];

%loop through each quintile in the struct
for nQuint = 1:length(quintFields)
    boot = bootstrp(1000,@mean,quintStruct.(string(quintFields(nQuint))));
    PCs = prctile(boot, [15.9, 50, 84.1]); % +/- 1 SEM
    PCMeans = mean(PCs, 2);
    CIs = zeros(3, size(quintStruct.(string(quintFields(nQuint))), 2));
    for c = 1:3
        CIs(c,:) = filtfilt(filterLP, PCs(c,:) - PCMeans(c)) + PCMeans(c);
    end

    x(nQuint,:) = 1:size(CIs, 2);
    x2(nQuint,:) = [x, fliplr(x)];
    bins(nQuint) = size(CIs,2);
    CIsCell{nQuint} = CIs;

end



end