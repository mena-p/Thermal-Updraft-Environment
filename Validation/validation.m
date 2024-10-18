close all
% Load data
sensorData = importSensorData('pedro_csv.csv');
load("sounding_buses.mat","sounding_buses");
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

for i = 1:length(flight.trajectory.press_alt.press_alt)
    igc_press(i) = 1013.25 * (1 - flight.trajectory.press_alt.press_alt(i)/44307.694)^5.25530;
end 

n = length(sensorData.time);%20001; % tune on first 400 seconds, max 15km from aerodrome

%% Humidity sensor model

modeled_humidity = zeros(1,n);    
hum_err = zeros(1,n);
c = -20.4560; % humidity sensor model constant

for i = 1:n
    alt = sensorData.gps_altitude(i);

    % Round aircraft height to nearest integer
    alt = round(alt);
    alt_top = alt + 0.01;
    alt_bottom = alt - 0.01;

    numLevels = sounding_buses.numLevels;
    logical_mask = false(numLevels,1);
    used_soundings = false(1,1);

    % Initialize logical mask (1 if aircraft height is in sounding data, 0 otherwise)
    logical_mask = (sounding_buses.REPGPH <= alt_top & sounding_buses.REPGPH >= alt_bottom);
    % Check if no soundings contains the aircraft height
    if ~any(logical_mask)
        warning off backtrace
        warning('Aircraft height is not in sounding data');
        warning on backtrace
        return;
    end
    RH_sounding = sounding_buses.REPRH(logical_mask);
    modeled_humidity(i) = RH_sounding(1,1) + c;
end

hum_err = ((modeled_humidity-sensorData.humidity(1:n)').^2).^(1/2);

hum_comparison_vec = [modeled_humidity' sensorData.humidity(1:n)];

correlation_hum = corrcoef(hum_comparison_vec);

%% Temperature sensor model
p1 = 5.9083;
modeled_press = zeros(1,n);
for i = 1:n
    alt = sensorData.gps_altitude(i);

    % Round aircraft height to nearest integer
    alt = round(alt);
    alt_top = alt + 0.01;
    alt_bottom = alt - 0.01;
    
    numLevels = sounding_buses.numLevels;
    logical_mask = false(numLevels,1);
    used_soundings = false(1,1);
    
    % Initialize logical mask (1 if aircraft height is in sounding data, 0 otherwise)
    logical_mask = (sounding_buses.REPGPH <= alt_top & sounding_buses.REPGPH >= alt_bottom);
    % Check if no soundings contains the aircraft height
    if ~any(logical_mask)
        warning off backtrace
        warning('Aircraft height is not in sounding data');
        warning on backtrace
        return;
    end
    p = sounding_buses.PRESS(logical_mask)/100;
    modeled_press(i) = p(1,1) + p1;
end
press_error = ((modeled_press(i)-sensorData.pressure(1:n)').^2).^(1/2);
press_comparison_vec = [modeled_press' sensorData.pressure(1:n)];

correlation_press = corrcoef(press_comparison_vec);

%% Pressure sensor model
    T_aircraft = zeros(1,n);
    modeled_temp = zeros(1,n);
    err = zeros(1,n);
    tau = 231.6819;
    f = 1;
    T_aircraft(1) = 292.130400000000;
    for i = 2:n
        T_air = 300.9147 - 9.8 * (sensorData.gps_altitude(i) - 385)/1000;
        T_aircraft(i) = T_aircraft(i-1) + 0.02/(tau+0.02) * (T_air - T_aircraft(i-1));
        modeled_temp(i) = T_air*(1-f) + f*T_aircraft(i);

        err(i) = sqrt((modeled_temp(i) - (sensorData.temperature(i)+273.15))^2);
    end
    temp_err = ((modeled_temp(2:end)' - sensorData.temperature(2:n) - 273.15 ).^2).^(1/2);
    temp_comparison_vec = [modeled_temp(2:n)' sensorData.temperature(2:n)+273.15];

    correlation_temp = corrcoef(temp_comparison_vec);

%% Plots
times_igc = flight.trajectory.press_alt.durations - seconds(898);
figure
plot(times,press.Var1)
hold on
plot(times_igc,igc_press)
plot(times,modeled_press)
legend('sensor','igc','modeled')