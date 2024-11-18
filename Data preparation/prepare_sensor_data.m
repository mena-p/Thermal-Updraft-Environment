%% Prepare sensor data
% This script is used to prepare sensor data for the simulink model
% when you want to run it using data collected in flight. The data should
% be provided in the same format as the file 'pedro_csv.csv' created by 
% Leo.

% Load data
sensorData = importSensorData('Raw data/pedro_csv.csv');
numLevels = sounding_buses.numLevels;

% convert times to duration since start
times = sensorData.time - sensorData.time(1);
times.Format = 's';

% Create timetables
alt = timetable(times, sensorData.gps_altitude);
temp = timetable(times, sensorData.temperature + 273.15);
press = timetable(times, sensorData.pressure);
hum = timetable(times, sensorData.humidity);