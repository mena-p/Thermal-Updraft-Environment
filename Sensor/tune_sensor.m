clear
% Load data
sensorData = importSensorData('pedro_csv.csv');
%load('Flights/29-Jul-2024_Schlautmann Nils.mat','flight');
load('sounding_buses.mat');
numLevels = sounding_buses.numLevels;

% convert times to duration since start
times = sensorData.time - sensorData.time(1);
times.Format = 's';

% Create timetables
alt = timetable(times, sensorData.gps_altitude);
temp = timetable(times, sensorData.temperature + 273.15);
press = timetable(times, sensorData.pressure);
hum = timetable(times, sensorData.humidity);


fun = @(x) avg_error_f(x(1),x(2),sensorData);

problem = createOptimProblem('fmincon','objective',...
    @(x) avg_error_f(x(1),x(2),sensorData), 'x0',[500,0.5],...
    'lb',[1,0],'ub',[500,1],...
    'options', optimoptions(@fmincon,'Algorithm','sqp','Display','off'));

gs = GlobalSearch('Display','iter');
rng(14,'twister')
[x,fval] = run(gs,problem);
% % Create linear space where tau is between 0.01 and 10000 and f is between 0 and 1
% numF = 2;
% numTau = 2;
% f0 = linspace(0,1,numF);
% tau0 = linspace(1,500,numTau);
% 
% % Create a meshgrid
% [X,Y] = meshgrid(tau0,f0);
% Z = zeros(numTau,numF);
% tau = zeros(numTau,numF);
% f = zeros(numTau,numF);
% 
% % Compute the optimal values for tau and f based on the starting values tau0 and f0
% for i = 1:numTau
%     for j = 1:numF
%         [xmin,error] = fminsearch(fun,[tau0(i),f0(j)]);
%         Z(i,j) = error;
%         tau(i,j) = xmin(1);
%         f(i,j) = xmin(2);
%     end
% end
% 
% % Plot the optimal tau and f found based on the starting values tau0 and f0
% figure
% plot(tau,f,'o')
% xlabel('tau0')
% ylabel('f0')
% 
% % Plot the meshgrid
% figure
% surf(X,Y,tau)
% xlabel('tau0')
% ylabel('f0')
% zlabel('error')
% 
% % Find the minimum error
% min_error = min(min(Z));
% [i,j] = find(Z == min_error);
% taumin = tau(i,j);
% fmin = f(i,j);
% k = 1;
