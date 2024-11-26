% This script was used to validate the full simulation environment. If you
% want to verify the validation, run every section and the sensor tuner
% model (follow the instructions in the comments). Or you can skip
% the first and second sections by uncommenting the load command on line 48
% and running from there.

close all
clear
% Load data
sensorData = importSensorData('Raw data/pedro_csv.csv');
load("sounding_buses_tuning.mat","sounding_buses");
sounding_buses = sounding_buses(1);
load("updrafts_full_validation.mat","updrafts")
load("Processed data/sounding_bus.mat",'sounding')
addpath '..'/Flights/
load('29-Jul-2024_Schlautmann Nils.mat')
rmpath '..'/Flights/
numLevels = sounding_buses.numLevels;

% convert times to duration since start
times = sensorData.time - sensorData.time(1);
times.Format = 's';

latitude = sensorData.gps_y/111000;
longitude = sensorData.gps_x/111000;

% Create timetables
alt = timetable(times, sensorData.gps_altitude);
lat = timetable(times, sensorData.gps_x/111000);
lon = timetable(times, sensorData.gps_y/111000);
temp = timetable(times, sensorData.temperature + 273.15);
press = timetable(times, sensorData.pressure*100);
RH = timetable(times, sensorData.humidity);
vel_squared = timetable(times, sensorData.velocity.^2);

% Convert times to double
times = seconds(times);

%% Compute substitute humidity profile
close all
diffH = diff(sensorData.gps_altitude)./0.02;
dists = distance(latitude,longitude,sounding_buses.lat,sounding_buses.lon,wgs84Ellipsoid('m'));
[profile, altitude_bins] = get_humidity_profile(sensorData(dists(1:end-1)<50000,:));
[profile2, altitude_bins2] = get_humidity_profile(sensorData(dists(1:end-1)>50000 & dists(1:end-1)<100000,:));

figure
plot(profile, altitude_bins)
hold on
plot(profile2, altitude_bins2)
xlabel('Humidity (%)')
ylabel('Altitude (m)')
title('Humidity Profile')

% Compare humidities
n = size(sensorData.humidity,1);
pred_rh = zeros(n,1);
for i =1:n
    idx = int32(sensorData.gps_altitude(i));
    if idx > size(profile,2)
        continue
    end
    pred_rh(i) = profile(idx);
end

m = size(sounding_buses.REPGPH,1);
new_profile = zeros(m,1);
for i =1:m
    idx = int32(sounding_buses.REPGPH(i));
    if idx > size(profile,2)
        continue
    end
    new_profile(i) = profile(idx);
end

% Convert RH to vapor pressure
T = sounding_buses.PTEMP.* (100000./sounding_buses.PRESS).^(-0.286);
T = T - 273.15;
f = 1.0007 + 3.46*10^(-6) .* sounding_buses.PRESS/100;
exponent = (((18.729-T)./227.3).*T)./(T+257.87);
esat = f .* 6.1121 .* exp(exponent); % hPa
e = new_profile .* esat; % Pa
%e(isnan(e)) = sounding_buses.VAPPRESS(isnan(e));
%e(e==0) = sounding_buses.VAPPRESS(e==0);


figure
plot(e)
hold on
plot(sounding_buses.VAPPRESS)
legend('based on profile', 'sounding')
sounding_buses.VAPPRESS = e;

figure
subplot(2,1,1)
plot(sensorData.time,pred_rh)
hold on
plot(sensorData.time,sensorData.humidity)
legend('based on profile', 'actual')
subplot(2,1,2)
plot(sensorData.time,sensorData.gps_altitude);

figure
mask = diffH < -3 & dists(1:end-1) < 50000;
scatter(sensorData.humidity(mask),sensorData.gps_altitude(mask))

%% Run the SensorTuner.slx model
% Run the sensor tuner model with the
% full simulation environment model now. Make sure to set the simulation
% step size to 1s as the cockpit sensor model constants have been adjusted 
% for this rate.

%% Extract simulation results
%load('Validation/simulation_out_sensor_model.mat')

% Extract model results
temps = out.yout{1}.Values.Data;
RHs = out.yout{2}.Values.Data;
ps = out.yout{3}.Values.Data;
simalts = out.yout{4}.Values.Data;
simtimes = out.tout;

realT = squeeze(temps(1,1,:));
thermalT = squeeze(temps(1,2,:));
sensorT = squeeze(temps(1,5,:));
realRH = squeeze(RHs(1,1,:));
thermalRH = squeeze(RHs(1,2,:));
sensorRH = squeeze(RHs(1,5,:));
realp = squeeze(ps(1,1,:));
thermalp = squeeze(ps(1,2,:));
sensorp = squeeze(ps(1,5,:));
alts = simalts;

%% Calculate correlation coeffs on entire flight
corr_temp = corrcoef(realT,sensorT);
corr_hum = corrcoef(realRH,sensorRH);
corr_p = corrcoef(realp,sensorp);

%% Calculate correlation coeffs excluding surges
corr_temp2 = corrcoef(realT(alts<2004),sensorT(alts<2004));
corr_hum2 = corrcoef(realRH(alts<2004),sensorRH(alts<2004));
corr_p2 = corrcoef(realp(alts<2004),sensorp(alts<2004));

%% Plot real, thermal model, and sensor model values
zi = 2004;

close all
f1 = figure('Position', [10 10 900 300]);
plot(simtimes(2:end), realT(2:end),"Color","b")
hold on
plot(simtimes(2:end), thermalT(2:end),'Color','#0072BD')
plot(simtimes(2:end),sensorT(2:end))
legend('Flight Test', 'Thermal Model','Sensor Model',"Location","southeast")
xlabel('Flight Time [s]')
ylabel("Temperature [K]")
xlim([0 12183])
%xline(idx, '--','HandleVisibility','off')
grid on
%saveas(f1,"Images/Validation/comparison-temp",'png')

f2 = figure('Position', [10 10 900 300]);
plot(simtimes,realRH,"Color","b")
hold on
plot(simtimes,thermalRH,'Color','#0072BD')
plot(simtimes,sensorRH)
legend('Flight Test', 'Thermal Model',"Sensor Model","location","southeast")
xlabel('Flight Time [s]')
ylabel("Relative Humidity [%]")
xlim([0 12183])
%xline(idx, '--','HandleVisibility','off')
grid on
%saveas(f2,"Images/Validation/comparison-hum",'png')

f3 = figure('Position', [10 10 900 300]);
plot(simtimes,realp,"Color","b")
hold on
plot(simtimes,thermalp,'Color','#0072BD')
plot(simtimes,sensorp)
legend('Flight Test','Thermal Model',"Sensor Model","Location","southeast")
xlabel('Flight Time [s]')
ylabel("Pressure [Pa]")
xlim([0 12183])
grid on
%saveas(f3,"Images/Validation/comparison-press",'png')

figure('Position', [10 10 900 300])
plot(simtimes, alts)
grid on
hold on
plot(simtimes, ones(size(simtimes))*zi, '--',"Color",'[0 0 0]','LineWidth',1)
legend('Altitude', 'Inversion Height',"Location","northwest")
xlabel('Filght Time [s]')
ylabel("Altitude [m]")
xlim([0 12183])
%hold on
%xline(idx, '--','HandleVisibility','off')
%saveas(gcf,"Images/Sensor/comparison-alt",'png')