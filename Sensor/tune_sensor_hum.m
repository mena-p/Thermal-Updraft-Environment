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

fun = @(x) avg_error_hum(x(1),sensorData,sounding_buses);

problem = createOptimProblem('fmincon','objective',...
    @(x) avg_error_hum(x(1),sensorData,sounding_buses), 'x0',-16,...
    'lb',-50,'ub',0,'options',...
    optimoptions(@fmincon,'Algorithm','sqp','Display','off'));

gs = GlobalSearch('Display','iter');
rng(14,'twister')
[hum_sensor_const,hum_avg_error] = run(gs,problem);
