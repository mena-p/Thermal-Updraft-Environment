close all
clear
% Load data
load('sounding_buses.mat')
sounding = sounding_buses(1);

sensorData = importSensorData('pedro_csv.csv');
%sensorData = sensorData(1:20000,:);
%sensorData = sensorData(46151:46151+27551,:);
% sensorData_descent = sensorData(1:19401,:);
altitude = sensorData.gps_altitude;
latitude = sensorData.gps_y/111000;
longitude = sensorData.gps_x/111000;
time = sensorData.time;

% find indices where the wsg84 distance to the sounding station is less than 50km
dists = distance(latitude,longitude,sounding.lat,sounding.lon,wgs84Ellipsoid('m'));
dist_idx = find(dists < 50000);

% Restrict all data to the part where the distance is less than 50km
sensorData = sensorData(dists < 50000,:);
altitude = altitude(dists < 50000);
latitude = latitude(dists < 50000);
longitude = longitude(dists < 50000);
time = time(dists < 50000);

% Get indices in altitude where the altitude is decreasing (smaller than the previous value)
diffs = diff(altitude);
descent_idx = find(diffs< 0);

% Restrict the sensor data and altitude to the descent phase
sensorData = sensorData(diffs<0,:);
latitude = latitude(diffs<0);
longitude = longitude(diffs<0);
altitude = altitude(diffs<0);

[profile, altitude_bins] = get_humidity_profile(sensorData);

%% Plots
close all
% Plot the trajectory and station location
figure
geoplot(latitude, longitude)
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

% find wehre the altitude first reaches 1700m
% idx = find(altitude == 1720);


% % Plot trajectory
% figure
% geoplot(latitude, longitude)
% title('Trajectory')

% % Plot altitude vs time with peaks
% figure
% plot(time, altitude)
% xlabel('Time')
% ylabel('Altitude (m)')
% title('Altitude vs Time')




