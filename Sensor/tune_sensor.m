
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


