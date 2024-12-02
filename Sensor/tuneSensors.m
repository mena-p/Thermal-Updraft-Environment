% This script was used to tune the sensor parameters. It also plots
% the comparison between the sounding profile and the profile obtained
% from sensor data shown in chapter 6. It requires the
% Global Optimization Toolbox.

% You must run the first two sections (up to line 58), but afterwards you
% can run the temperature, humidity and pressure sections separately
% depending on what you want to tune.

close all
clear

% Load data
load('sounding_buses_tuning.mat') % <- use the GUI to select other soundings if you wish
% the ptemp is extrapolated above zi in this sounding, 
% just like it is in the actual simulation environment

sounding = sounding_buses(1);

sensorData = importSensorData('Raw data/pedro_csv.csv'); % <- change this to the path of the sensor data

altitude = sensorData.gps_altitude;
latitude = sensorData.gps_y/111000;
longitude = sensorData.gps_x/111000;
time = sensorData.time;

% Fix Leo velocity (this step was needed due to errors in the sensor data)
diffX = diff(sensorData.gps_x)./0.02;
diffY = diff(sensorData.gps_y)./0.02;
diffH = diff(sensorData.gps_altitude)./0.02;
vel = zeros(size(sensorData.velocity));
vel(2:end) = sqrt(diffX.^2 + diffY.^2 + diffH.^2);
vel(1) = vel(2);
sensorData.velocity = vel;

%% Prepare data for tuning
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

% Restrict all data to the part where the distance is less than 50km
sensorData = sensorData(dists < 50000,:);
altitude = altitude(dists < 50000);
latitude = latitude(dists < 50000);
longitude = longitude(dists < 50000);
time = time(dists < 50000);
diffH = diffH(dists < 50000);

%% Tune Temperature

% Create global optim problem
problem = createOptimProblem('fmincon','objective',...
    @(x) avg_error_temp(x(1),x(2),x(3),sensorData,sounding), 'x0',[200,0.5,5],...
    'lb',[1,0,3],'ub',[1000,1,10],...
    'options', optimoptions(@fmincon,'Algorithm','sqp','Display','off'));

% Solve
gs = GlobalSearch('Display','iter');
rng(14,'twister')
[parameters_temp,temp_avg_error] = run(gs,problem);

%% Tune Humidity

problem = createOptimProblem('fmincon','objective',...
    @(x) avg_error_hum(x(1),sensorData,sounding), 'x0',-16,...
    'lb',-50,'ub',0,'options',...
    optimoptions(@fmincon,'Algorithm','sqp','Display','off'));

gs = GlobalSearch('Display','iter');
rng(14,'twister')
[hum_sensor_const,hum_avg_error] = run(gs,problem);

%% Tune Pressure

problem = createOptimProblem('fmincon','objective',...
    @(x) avg_error_press(x(1),x(2),sensorData,sounding), 'x0',[7,0],...
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
plot(profile, altitude_bins)
hold on
plot(sounding.REPRH(750:1320),sounding.REPGPH(750:1320))
grid on
xlabel('Humidity [%]')
ylabel('Altitude [m]')
title('Humidity Profile')
legend('Sensor','Sounding','Location','southeast')
