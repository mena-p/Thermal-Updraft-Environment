% This script was used to tune the sensor parameters. It requires the
% Global Optimization Toolbox.

close all
clear
% Load data
load('sounding_buses.mat')
sounding = sounding_buses(1);

sensorData = importSensorData('Raw data/pedro_csv.csv');
%sensorData = sensorData(1:20000,:);
%sensorData = sensorData(46151:46151+27551,:);
% sensorData_descent = sensorData(1:19401,:);
altitude = sensorData.gps_altitude;
latitude = sensorData.gps_y/111000;
longitude = sensorData.gps_x/111000;
time = sensorData.time;
%% Prepare data for SensorTuner model
% convert times to duration since start
times = sensorData.time - sensorData.time(1);
times.Format = 's';

% Create timetables
alt = timetable(times, sensorData.gps_altitude);
temp = timetable(times, sensorData.temperature + 273.15);
press = timetable(times, sensorData.pressure);
RH = timetable(times, sensorData.humidity);

%% Cut data to 50km from sounding to tune
% find indices where the wsg84 distance to the sounding station is less than 50km
dists = distance(latitude,longitude,sounding.lat,sounding.lon,wgs84Ellipsoid('m'));
dist_idx = find(dists < 50000);

% Restrict all data to the part where the distance is less than 50km
sensorData = sensorData(dists < 50000,:);
altitude = altitude(dists < 50000);
latitude = latitude(dists < 50000);
longitude = longitude(dists < 50000);
time = time(dists < 50000);

%% Tune Temperature
% Declare anonymous error function
fun = @(x) avg_error_temp(x(1),x(2),x(3),sensorData,sounding_buses);

% Create global optim problem
problem = createOptimProblem('fmincon','objective',...
    @(x) avg_error_temp(x(1),x(2),x(3),sensorData,sounding_buses), 'x0',[200,0.5,5],...
    'lb',[1,0,3],'ub',[1000,1,10],...
    'options', optimoptions(@fmincon,'Algorithm','sqp','Display','off'));

% Solve
gs = GlobalSearch('Display','iter');
rng(14,'twister')
[parameters_temp,avg_error_temp] = run(gs,problem);

%% Tune Humidity
fun = @(x) avg_error_hum(x(1),sensorData,sounding_buses);

problem = createOptimProblem('fmincon','objective',...
    @(x) avg_error_hum(x(1),sensorData,sounding_buses), 'x0',-16,...
    'lb',-50,'ub',0,'options',...
    optimoptions(@fmincon,'Algorithm','sqp','Display','off'));

gs = GlobalSearch('Display','iter');
rng(14,'twister')
[hum_sensor_const,hum_avg_error] = run(gs,problem);

%% Tune Pressure
fun = @(x) avg_error_press(x(1),x(2),sensorData,sounding_buses);

problem = createOptimProblem('fmincon','objective',...
    @(x) avg_error_press(x(1),x(2),sensorData,sounding_buses), 'x0',[7,0],...
    'lb',[0,0],'ub',[300,1],'options',...
    optimoptions(@fmincon,'Algorithm','sqp','Display','off'));

gs = GlobalSearch('Display','iter');
rng(14,'twister')
[press_sensor_consts_with_vel,press_avg_error_with_vel] = run(gs,problem);

%% Calculate humidity profile on descent
% Get indices in altitude where the altitude is decreasing (smaller than the previous value)
diffs = diff(altitude);

% Restrict the sensor data and altitude to the descent phase
sensorDataDescent = sensorData(diffs<0,:);
latitudeDescent = latitude(diffs<0);
longitudeDescent = longitude(diffs<0);
altitudeDescent = altitude(diffs<0);

[profile, altitude_bins] = get_humidity_profile(sensorDataDescent);

%% Plots
close all
% Plot the trajectory and station location
figure
geoplot(latitudeDescent, longitudeDescent)
title('Flight Segment')
hold on
geoplot(sounding.lat,sounding.lon,'b^',"LineStyle","none")
legend('Trajectory','Station')

% Plot the humidity profiles
figure
plot(profile, altitude_bins,'Color','b')
hold on
plot(sounding.REPRH(750:1320),sounding.REPGPH(750:1320),"Color","#0072BD")
grid on
xlabel('Humidity [%]')
ylabel('Altitude [m]')
title('Humidity Profile')
legend('Sensor','Sounding','Location','southeast')
