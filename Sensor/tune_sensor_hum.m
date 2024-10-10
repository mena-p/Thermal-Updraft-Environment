% Load data
sensorData = importSensorData('pedro_csv.csv');
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
    @(x) avg_error_hum(x(1),sensorData,sounding_buses), 'x0',-20,...
    'lb',-30,'ub',30,'options',...
    optimoptions(@fmincon,'Algorithm','sqp','Display','off'));

gs = GlobalSearch('Display','iter');
rng(14,'twister')
[x,fval] = run(gs,problem);
