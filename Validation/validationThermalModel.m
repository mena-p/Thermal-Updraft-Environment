%% Thermal model (humidity profile generated from sensor data)
% The profile is extracted from a portion of the flight where the glider
% is descending. The thermal model is evaluated against the ascending 
% portion that follows it, once with and once without a thermal. The
% correlations are compared. Temperature and pressure come from the
% sounding.

close all
% Load data
sensorData = importSensorData('pedro_csv.csv');
load("sounding_buses.mat","sounding_buses");

% Get data from the descent
dataDescent = sensorData(46151:46151+19401,:);
humidity_profile = get_humidity_profile(dataDescent);
humidity_descent = dataDescent.humidity;
alt_descent = dataDescent.gps_altitude;

% Plot humidity profile of sounding and the calculated profile
figure
plot(sounding_buses.REPRH, sounding_buses.REPGPH)
hold on
plot(humidity_profile, 0:1:max(alt_descent))
hold off
xlabel('Humidity (%)')
ylabel('Altitude (m)')
title('Humidity Profile of Sounding')


% Calculate humidity on descent based on profile
humidity_descent_profile = zeros(size(humidity_descent));
for i = 1:size(humidity_descent,1)
    alt = alt_descent(i);
    alt = int32(round(alt));
    humidity_descent_profile(i) = humidity_profile(alt);
end

% Plot the descent humidity and the altitude in subplots
figure
subplot(2,1,1)
plot(dataDescent.time, humidity_descent)
hold on
plot(dataDescent.time, humidity_descent_profile)
hold off
xlabel('Time')
ylabel('Humidity (%)')
title('Humidity in descent')
legend('raw data','calculated from profile')
subplot(2,1,2)
plot(dataDescent.time,alt_descent)
xlabel('Time')
ylabel('Altitude (m)')
title('Altitude from descent')


% Replace the sounding humidity by this profile
humidity_profile = humidity_profile';
sounding_buses.REPRH = humidity_profile;

% Get trajectory data for ascent portion
dataAscent = sensorData(46151+19401:46151+27551,:);
alt_ascent = dataAscent.gps_altitude;
lat_ascent = dataAscent.gps_y/111000;
lon_ascent = dataAscent.gps_x/111000;
humidity_ascent = dataAscent.humidity;

% Calculate humidity on ascent based on profile
humidity_ascent_profile = zeros(size(humidity_ascent));
for i = 1:size(humidity_ascent,1)
    alt = alt_ascent(i);
    alt = int32(round(alt));
    humidity_ascent_profile(i) = humidity_profile(alt);
end

% Plot the ascent humidity and the altitude in subplots
figure
subplot(2,1,1)
plot(dataAscent.time, humidity_ascent)
hold on
plot(dataAscent.time, humidity_ascent_profile)
hold off
xlabel('Time')
ylabel('Humidity (%)')
title('Humidity in ascent')
legend('raw data','calculated from profile')
subplot(2,1,2)
plot(dataAscent.time,alt_ascent)
xlabel('Time')
ylabel('Altitude (m)')
title('Altitude from ascent')

% Initialize updraft
updraft = Updraft(49.0247,12.6251);
updraft.gain = 1;

% Initialize dummy updraft
dummyUpdraft = Updraft(0,0);

% Size of iteration
n = size(alt_ascent,1);

% Pre-allocate arrays
Twith = zeros(n,1);
Twithout = zeros(n,1);
Pwith = zeros(n,1);
Pwithout = zeros(n,1);
RHwith = zeros(n,1);
RHwithout = zeros(n,1);

% Get temp/press/hum predicted by model without and with thermals
for i = 1:n

    % with updraft
    [T,~,p,RH] = thermal_model(lat_ascent(i),lon_ascent(i),alt_ascent(i),{updraft},sounding_buses);
    Twith(i) = T;
    Pwith(i) = p;
    RHwith(i) = RH;

    % without updraft
    [T,~,p,RH] = thermal_model(lat_ascent(i),lon_ascent(i),alt_ascent(i),{dummyUpdraft},sounding_buses);
    Twithout(i) = T;
    Pwithout(i) = p;
    RHwithout(i) = RH;
end

% plot humidity from the ascent, and RH with and without updraft
figure
plot(dataAscent.time,humidity_ascent)
hold on
plot(dataAscent.time,RHwith)
plot(dataAscent.time,RHwithout)
legend('Measured','With updraft','Without updraft')
xlabel('Time')
ylabel('Humidity (%)')
title('Humidity from ascent and RH with and without updraft')


% Compute correlation coefficients between measured humidity and modelled
% humidity with and without updraft
corr_with = corrcoef(humidity_ascent,RHwith);
corr_without = corrcoef(humidity_ascent,RHwithout);
