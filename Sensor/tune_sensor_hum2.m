close all
% Load data
sensorData = importSensorData('pedro_csv.csv');

sensorData = sensorData(46151:46151+27551,:);
sensorData_descent = sensorData(1:19401,:);
altitude = sensorData.gps_altitude;
latitude = sensorData.gps_y/111000;
longitude = sensorData.gps_x/111000;
time = sensorData.time;

% Plot trajectory
figure
geoplot(latitude, longitude)
title('Trajectory')

% Plot altitude vs time with peaks
figure
plot(time, altitude)
xlabel('Time')
ylabel('Altitude (m)')
title('Altitude vs Time')


% find wehre the altitude first reaches 1700m
idx = find(altitude == 1720);
profile = get_humidity_profile(sensorData);

load('sounding_buses.mat')