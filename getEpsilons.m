function [epsilon_range] = getEpsilons
%UNTITLED2 Summary of this function goes here
%% kdist
choosek = input(strcat('Choose k:',32)); %32 is code for space
load normData_hit.mat
%distance of k-nearest neighbours k = 50
kdist = pdist2(normData_hit,normData_hit,'euc','Smallest', choosek+1); %offset by 1 because first dist = 0 (dist against itself)
%Remove first row which only calculates distance against self (dist = 0)
kdistminus1st = kdist(2:end,:)';
%all kdist data sorted into column vector
Vdist = sort(kdistminus1st(:));
%% LINE 1 and 2
%x-coordinate of start of knee
p1(1) = length(Vdist) - length(normData_hit(:));
%x-coordinate of end of knee
p2(1) = length(Vdist);
%y-coordinate of start of knee
p1(2) = Vdist(p1(1));
%y-coordinate of end of knee
p2(2) = Vdist(p2(1));

%line going through p1(1) and p2(1) 
A1 = (p2(2)-p1(2))/(p2(1)-p1(1));
B1 = p1(2)-(A1*p1(1));
LINE = @(x) (A1*x)+B1;
%Line corresponding to abrupt increase of distances
A2 = -A1;
B2 = A1*(p1(1)+p2(1))+B1;
LINE2 = @(x) (A2*x)+B2;

%% Line 3
%find coordinate of point right above knee
p3 = [];
for x = 1:length(Vdist)
    % Calculate the y-coordinate using LINE2
    calculated_y = LINE2(x);

    % Define a tolerance value to account for floating-point precision errors
    tolerance = 1e-6;

    % Check if the y-coordinates are within tolerance to consider
    % it an intersection point between Vdist and LINE2
    if abs(calculated_y - Vdist(x)) < tolerance
        p3 = [p3; x,Vdist(x)];
    end
end

%% another way to possibly compute p3
%estimate equation for Vdist
%f = @(x) interp1(1:length(Vdist),Vdist, x, 'linear');
%estimate aprox x-coordinate of point
% x0 = 20000; 
%find x-coordinate
% intersect_pts = fsolve(@(x) (f(x) - LINE2(x)), x0);
%y-coordinate 
%y3 = Vdist(int64(intersect_pts));
%p3 = [intersect_pts y3];

%% LINE 3
%Find point near p3
pt = [p3(1)+1 Vdist(p3(1)+1)]; %point very near p3

%line 3: tangent line coming from point 3
A3 = (pt(2) - p3(2))/(pt(1) - p3(1)); %slope
B3 = p3(2) - (A3*p3(1)); %intercept
LINE3 = @(x) (A3*x)+B3;

%%  delta distance btwn tangent line at p3 and Vdist 
%delta d: dif btwn values of Vdist and LINE3 at given x
delta_D = @(x) Vdist(x)-LINE3(x)';
%delta_D from x-value of p3 to x-value of p2 (p3x:p2x)
M = delta_D(p3(1):p2(1));
mean_M = mean(M); %mean of M

%find coordinates of point a (coordinates of mean M)
pa = [];
for x = 1:length(M);
    % Define a tolerance value to account for floating-point precision errors
    tolerance = 1e-5;
    % Check if the y-coordinates are close (within tolerance) to consider it an intersection point
    if abs(M(x) - mean_M) < tolerance
        pa = [pa; x,M(x)];
    end
end

%% another way of computing intersection_pt
%estimate function for M
% Mfunc = @(x) interp1(1:length(M),M, x, 'linear');
%initial guess for x-coordinate
% x0 = 25657;
%increase tolerance for finding x-coordinate
% options = optimoptions('fsolve', 'TolX',1e-25); 
%find x-coordinate
% pAx = fsolve(@(x) (Mfunc(x) - mean_M), x0,options);

%% Calculate all epsilons for range of pax
epsilon_range(1:length(pa)) = Vdist(p3(1)+pa(:,1)); %note to self: run DBScanner for all pa x values.NEED TO FIX THIS PART
%save('epsilon_range.mat',"epsilon_range")

end



