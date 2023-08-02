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

%more attempt 2
kD = pdist2(normData,normData,'euc','Smallest',20);

figure;
plot(sort(kD(end,:)));
title('k-distance graph')
xlabel('Points sorted with 50th nearest distances')
ylabel('50th nearest distances')
ylim([0 3])
grid

%more attempt 3
clusterDBSCAN.estimateEpsilon(normData,50,100)

%% Minpt Determination
load normData.mat
%distance of k-nearest neighbours k = 50
kdist = pdist2(normData,normData,'euc','Smallest', 51); %offset by 1 because first dist = 0 (dist against itself)
%distance of k-nearest neighbours k = 100
kdist = pdist2(normData,normData,'euc','Smallest', 101);
%distance of k-nearest neighbours k = 10
kdist = pdist2(normData,normData,'euc','Smallest', 11);
%distance of k-nearest neighbours k = 1000
kdist = pdist2(normData,normData,'euc','Smallest', 1001);
%all these distances converges with a dp of ~1

%
kdist1 = kdist(2:end,:)';

%all kdist data sorted into 1 vector
Vdist = sort(kdist(:));
%x-coordinate start of knee
p1(1) = length(Vdist) - length(normData(:));
%x-coordinate end of knee
p2(1) = length(Vdist);
%y-coordinate start of knee
p1(2) = Vdist(p1(1));
%y-coordinate end of knee
p2(2) = Vdist(p2(1));

%line going through Vstart and Vstop points
A1 = (p2(2)-p1(2))/(p2(1)-p1(1));
B1 = p1(2)-(A1*p1(1));
LINE = @(x) (A1*x)+B1;

%Line corresponding to abrupt increase of distances
A2 = -A1;
B2 = A1*(p1(1)+p2(1))+B1;
LINE2 = @(x) (A2*x)+B2;

%find coordinate of point of intersection between Vdist and LINE2
p3 = [];
for x = 1:length(Vdist);

    % Calculate the y-coordinate using the line equation
    calculated_y = LINE2(x);

    % Define a tolerance value to account for floating-point precision errors
    tolerance = 1e-5;
    % Check if the y-coordinates are close (within tolerance) to consider it an intersection point
    if abs(calculated_y - Vdist(x)) < tolerance
        p3 = [p3; x,Vdist(x)];
    end
end
%another way to possibly compute p3
%estimate equation for Vdist
%f = @(x) interp1(1:length(Vdist),Vdist, x, 'linear');
%estimate aprox x-coordinate of point
% x0 = 20000; 
%find x-coordinate
% intersect_pts = fsolve(@(x) (f(x) - LINE2(x)), x0);
%y-coordinate 
%y3 = Vdist(int64(intersect_pts));
%p3 = [intersect_pts y3];

%point near p3
pt = [p3(1)+1 Vdist(p3(1)+1)]; %point very near p3

%line 3: tangent line coming from point 3
A3 = (pt(2) - p3(2))/(pt(1) - p3(1)); %slope
B3 = p3(2) - (A3*p3(1)); %intercept
LINE3 = @(x) (A3*x)+B3;
%% dp point
%distance btwn pt 2 and 3
%dp23 = pdist2(p2,p3,"euclidean");
%distance btwn pt 1 and 3
%dp13 = pdist2(p1,p3,"euclidean");
%comparison factor btwn the two distances calculated
%dp = dp23/dp13;

%% More attempts for Epsilon 


%delta d: dif btwn values of Vdist and LINE3
delta_D = @(x) Vdist(x)-LINE3(x)';
%delta d from x-value of p3 to x-value of p2 i.e. x2 = 1, x3 = 3, therefore
%1:3
M = delta_D(p3(1):p2(1));
mean_M = mean(M); %mean of M
%find coordinates of point a (coordinates of mean M)
pa = [];
for x = 1:length(M);
    % Define a tolerance value to account for floating-point precision errors
    tolerance = 1e-3;
    % Check if the y-coordinates are close (within tolerance) to consider it an intersection point
    if abs(M(x) - mean_M) < tolerance
        pa = [pa; x,M(x)];
    end
end

%another way of computing intersection_pt
%estimate function for M
% Mfunc = @(x) interp1(1:length(M),M, x, 'linear');
%initial guess for x-coordinate
% x0 = 25657;
%increase tolerance for finding x-coordinate
% options = optimoptions('fsolve', 'TolX',1e-25); 
%find x-coordinate
% pAx = fsolve(@(x) (Mfunc(x) - mean_M), x0,options);

epsilon_trial = Vdist(p3(1)+pa(1,1)); %note to self: run DBScanner for all pa x values 
clusterTrial = dbscan(normData,epsilon_trial,50);


figure;
hold on
plot(Vdist)
plot(p1(1,1),p1(1,2),'.')
plot(p2(1,1),p2(1,2),'.')
plot(p3(1,1),p3(1,2),'.')
plot(LINE(1:length(Vdist)))
plot(LINE2(1:length(Vdist)),'--')
ylim([0 p2(1,2)+5])

%clusterTrial plots
%
clr = ['r','b','g','k']; 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingrewards,clusterTrial,clr)
title('ClusterTrial')
xlabel('Rolling Hit Rate')
ylabel('Rolling Rewards')
%
clr = ['r','b','g','k']; 
figure;
gscatter(masterDataTable.rollingallRTs,masterDataTable.rollinghitrate,clusterTrial,clr)
title('ClusterTrial')
xlabel('Rolling RTs')
ylabel('Rolling Hit Rate')


%%
figure;
hold on
plot(M)
yline(mean_M)
plot(Z,mean_M,'.')


%plot
figure;
hold on
plot(Vdist);
plot(Vstart,y1,'.')
plot(Vstop,y2,'.')
plot(intersect_pts,y3,'.')
xlim([0 13000000])
ylim([0 32])
grid

%minpt to use?
round(dp - 0.5)

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

%R RTs
clr = ['r','b','g']; 
figure;
gscatter(masterDataTable.rollingallRTs,masterDataTable.rollinghitrate,R,clr)
title('Data R')
xlabel('Rolling RTs')
ylabel('Rolling Hit Rate')
%R rewards
clr = ['r','b','g']; 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingrewards,R,clr)
title('Data R')
xlabel('Rolling Hit Rate')
ylabel('Rolling RTs')

%clusterTrial RTs
clr = ['r','b','g']; 
figure;
gscatter(masterDataTable.rollingallRTs,masterDataTable.rollinghitrate,clusterTrial,clr)
title('Data R')
xlabel('Rolling RTs')
ylabel('Rolling Hit Rate')
%clusterTrial rewards
clr = ['r','b','g']; 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingrewards,clusterTrial,clr)
title('Data R')
xlabel('Rolling Hit Rate')
ylabel('Rolling RTs')


%figure data 19 fa vs hit
clr = ['r','b','g']; 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingfarate,R,clr)
title('Data R')
xlabel('Rolling Hit Rate')
ylabel('Rolling FA Rate')

%figure data 19 RTs
clr = ['r','b','g','k','y']; 
figure;
gscatter(masterDataTable.rollingallRTs,masterDataTable.rollinghitrate,DBStruct(1).data19,clr)
title('Data 19')
xlabel('Rolling RTs')
ylabel('Rolling Hit Rate')
%figure data 19 Rewards
clr = ['r','b','g','k','y']; 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingrewards,DBStruct(1).data19,clr)
title('Data 19')
xlabel('Rolling Hit Rate')
ylabel('Rolling rewards')

%figure data 19 fa vs hit
clr = ['r','b','g','k','y']; 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingfarate,DBStruct(1).data19,clr)
title('Data 19')
xlabel('Rolling Hit Rate')
ylabel('Rolling FA Rate')

%figure data 20 RTs
clr = ['r','b','g','k']; 
figure;
gscatter(masterDataTable.rollingallRTs,masterDataTable.rollinghitrate,DBStruct(1).data20,clr)
title('Data 20')
xlabel('Rolling RTs')
ylabel('Rolling Hit Rate')

%figure data 29 clustering
clr = ['r','b','g','k']; 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingrewards,DBStruct(1).data29,clr)
title('Data 29')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')
%figure data 29 RTs
clr = ['r','b','g','k']; 
figure;
gscatter(masterDataTable.rollingallRTs,masterDataTable.rollinghitrate,DBStruct(1).data29,clr)
title('Data 29')
xlabel('Rolling RTs')
ylabel('Rolling Hit Rate')
%figure data 29 fa vs hit
clr = ['r','b','g','k','y']; 
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingfarate,DBStruct(1).data29,clr)
title('Data 29')
xlabel('Rolling Hit Rate')
ylabel('Rolling FA Rate')


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

%69
clr = hsv(DBStruct(4).data69); 
figure;
gscatter(masterDataTable.rollingallRTs,masterDataTable.rollinghitrate,DBStruct(1).data69,clr)
title('Data 69 RTs')
xlabel('Rolling Rolling RTs')
ylabel('Rolling Hit Rate')

%78
clr = ['r','b','g','k'];
figure;
gscatter(masterDataTable.rollingallRTs,masterDataTable.rollinghitrate,DBStruct(1).data78,clr)
title('Data 78 RTs')
xlabel('Rolling Rolling RTs')
ylabel('Rolling Hit Rate')

%78
clr = ['r','b','g','k'];
figure;
gscatter(masterDataTable.rollinghitrate,masterDataTable.rollingrewards,DBStruct(1).data78,clr)
title('Data 78')
xlabel('Rolling hit Rate')
ylabel('Rolling Rewards')

%% Total Number of Trials
for nData = 1:size(T,1);
    SessionSize(nData) = size(T.optoPowerMW{nData,1},2);
end
%Something I need to use later on for revising code for rolling averages 
Vdist = 'no';
if strcmp(Vdist,'yes')
    C = 'yay~';
elseif strcmp(Vdist,'no')
    C ='aww';
end

%lapse rate graph against fa and hits

%% remove uncessary pts
for dp1 = 1:length(normData)
    for dp2 = 1:length(normData)
        output(dp1,dp2) = pdist2(normData(dp1),normData(dp2),'euclidean');
    end
end

distMat = triu(output);
totalTrials = sum(SessionSize);
