%% Initializing Variables

%Go to folder with the master table
cd(uigetdir([],'Select Folder Containing Master Table'));

%% Initialize varibles
%get all functions that provides data
masterRollAve = getrollingAverage; %select rewards and allRTs
masterRollRates = getrollingrates; %select fa, miss, and hit

%concatinate table 
masterDataTable = horzcat(masterRollAve,masterRollRates);

save('masterDataTable.mat',"masterDataTable")

%Normalize Data
normData = normalize(masterDataTable{:,:},1); %used z-score
save('normData.mat',"normData")

%sample
sampleData = datasample(normData,10,'Replace',false);

%% Attempt to see which epsilon is best (not directly though), just using samples
holder = [];
for  nDraw = 1:100
sampleData = datasample(normData,10000,'Replace',false);
holder(nDraw) = clusterDBSCAN.estimateEpsilon(sampleData,2,10);
end
toc;
meanEps = mean(holder); 

%more attempts
kdist = clusterDBSCAN.estimateEpsilon(normData,50,100);
Vdist = pdist2(normData,normData,'euclidean');
logicalMat = triu(ones(500,500));
C = normData';
kdist = triu(pdist2(normData,normData,'euclidean'));
triu(ones(250000,250000));
for dp1 = 1:length(normData)
    for dp2 = 1:length(normData)
        if logicalMat == 1
            output = pdist(normData(dp1,:),'euclidean');
        else
            continue
        end
    end
end

%% Minpt Determination
%distance of k-nearest neighbours k = 50
kdist = pdist2(normData,normData,'euc','Smallest', 50);
%distance of k-nearest neighbours k = 100
kdist = pdist2(normData,normData,'euc','Smallest', 100);
%distance of k-nearest neighbours k = 10
kdist = pdist2(normData,normData,'euc','Smallest', 10);
%distance of k-nearest neighbours k = 1000
kdist = pdist2(normData,normData,'euc','Smallest', 1000);
%all these distances converges with a dp of ~1

%all kdist data sorted into 1 vector
Vdist = sort(kdist(:));
%x-coordinate start of knee
Vstart = length(Vdist) - length(normData(:));
%x-coordinate end of knee
Vstop = length(Vdist);
%y-coordinate start of knee
y1 = Vdist(Vstart);
%y-coordinate end of knee
y2 = Vdist(Vstop);
%line going through Vstart and Vstop points
A1 = (y2-y1)/(Vstop-Vstart);
B1 = y1-(A1*Vstart);
LINE = @(x) (A1*x)+B1;
%Line corresponding to abrupt increase of distances
A2 = -A1;
B2 = A1*(Vstart+Vstop)+B1;
LINE2 = @(x) (A2*x)+B2;

%find coordinate of point corresponding to abrupt increase of distances
%estimate equation for Vdist
f = @(x) interp1(1:length(Vdist),Vdist, x, 'linear');
%estimate aprox x-coordinate of point
x0 = 2000000; 
%find x-coordinate
intersect_pts = fsolve(@(x) (f(x) - LINE2(x)), x0);
%y-coordinate 
y3 = Vdist(int64(intersect_pts));

%combine x and y coordinates and initialize as corresponding pts
p1 = [Vstart y1];
p2 = [Vstop y2];
p3 = [intersect_pts y3];

%distance btwn pt 2 and 3
dp23 = pdist2(p1,p2,"euclidean");
%distance btwn pt 1 and 3
dp13 = pdist2(p1,p3,"euclidean");
%comparison factor btwn the two distances calculated
dp = dp23/dp13;

%plot
figure;
hold on
plot(Vdist);
plot(Vstart,y1,'.')
plot(Vstop,y2,'.')
plot(intersect_pts,y3,'.')
grid

%minpt to use?
round(dp - 0.5)

%minpts

%% DBscan
DBStruct = getDBScanner(normData);

delete normData.mat

save DBStruct

plot(DBStruct(1).data25,'Color','b')
%clusters = dbscan(normData,0.5,50); %using mean eps from sample


%% Extra
F = dbscan(normData,0.5,40); %20 minpts yielded 6 clusters, 30 minpts yielded 
% 5 clusters, 50 minpts yielded 3 clusters; moving 50 minpts with 0.5
% instead of 0.48 radius reduced it to 2 clusters, using 0.5 eps for 40
% trials also yield 2 clusters; I think 0.48 was better

%figure data 5 clustering
clr = hsv(DBStruct(4).data5); 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingrewards,DBStruct(1).data5,clr)
title('Data 5')
xlabel('Rolling Hit Rate')
ylabel('Rolling Rewards')

%N
clr = hsv(max(N)); 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingrewards,N,clr)
title('N')
xlabel('Rolling Hit Rate')
ylabel('Rolling Rewards')


%figure data 29 clustering
clr = ['r','b','g','k']; 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingrewards,DBStruct(1).data29,clr)
title('Data 29')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')

%figure data 30 clustering
clr = ['r','b','g','k']; 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingrewards,DBStruct(1).data30,clr)
title('Data 30')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')

%figure data 40 clustering
clr = ['r','b','g','k','y','c','m']; 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingrewards,DBStruct(1).data40,clr)
title('Data 40')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')


%rolling rates with rolling rts
%figure data 29 w hit rate
clr = ['r','b','g','k']; 
figure;
gscatter(masterDataTable.rollingallRTs,masterDataTable.rollinghitrate,DBStruct(1).data29,clr)
title('Data 29 Hits')
xlabel('Rolling RTs')
ylabel('Rolling Hit Rate')

%figure data 29 w miss rate
clr = ['r','b','g','k']; 
figure;
gscatter(masterDataTable.rollingallRTs,masterDataTable.rollingmissrate,DBStruct(1).data29,clr)
title('Data 29 Miss')
xlabel('Rolling RTs')
ylabel('Rolling Miss Rate')

%figure data 29 w fa rate
clr = ['r','b','g','k']; 
figure;
gscatter(masterDataTable.rollingallRTs,masterDataTable.rollingfarate,DBStruct(1).data29,clr)
title('Data 29 FA')
xlabel('Rolling RTs')
ylabel('Rolling FA')

%Something I need to use later on for revising code for rolling averages 
Vdist = 'no';
if strcmp(Vdist,'yes')
    C = 'yay~';
elseif strcmp(Vdist,'no')
    C ='aww';
end

%% Total Number of Trials
for nData = 1:size(T,1);
    SessionSize(nData) = size(T.optoPowerMW{nData,1},2);
end

totalTrials = sum(SessionSize);
