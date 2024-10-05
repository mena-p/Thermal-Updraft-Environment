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

% average error function

function error = avg_error(tau,f,sensorData)

    n = 50000;
    T_aircraft = zeros(1,n);
    T_modeled = zeros(1,n);
    err = zeros(1,n);

    T_aircraft(1) = 292.130400000000;
    for i = 2:n
        T_air = 300.9147 - 9.8 * (sensorData.gps_altitude(i) - 385)/1000;
        T_aircraft(i) = T_aircraft(i-1) + 0.02/(tau+0.02) * (T_air - T_aircraft(i-1));
        T_modeled(i) = T_air + f * (T_aircraft(i) - T_air);

        err(i) = sqrt((T_modeled(i) - (sensorData.temperature(i)+273.15))^2);
    end
    error = sum(err)/n;
end

fun = @(x) avg_error(x(1),1,sensorData);

x0 = 240;

% Create linear space where tau is between 0.01 and 10000 and f is between 0 and 1
f0 = linspace(0,1,10);
tau0 = linspace(0.01,10000,10);

% Create a meshgrid
[X,Y] = meshgrid(tau0,f0);

% Compute the optimal values for tau and f based on the starting values tau0 and f0
for i = 1:10
    for j = 1:10
        [xmin,error] = fminsearch(fun,[tau0(i),f0(j)]);
        Z(i,j) = error;
    end
end

% Plot the meshgrid
figure
surf(X,Y,Z)
xlabel('tau')
ylabel('f')
zlabel('error')

% Find the minimum error
min_error = min(min(Z));
[i,j] = find(Z == min_error);
tau = tau0(i);
f = f0(j);
k = 1
