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
vel_squared = timetable(times, sensorData.velocity.^2);

fun = @(x) avg_error_press(x(1),x(2),sensorData,sounding_buses);

problem = createOptimProblem('fmincon','objective',...
    @(x) avg_error_press(x(1),x(2),sensorData,sounding_buses), 'x0',[7,0],...
    'lb',[0,0],'ub',[30,0.1],'options',...
    optimoptions(@fmincon,'Algorithm','sqp','Display','off'));

gs = GlobalSearch('Display','iter');
rng(14,'twister')
[press_sensor_consts_with_vel,press_avg_error_with_vel] = run(gs,problem);
