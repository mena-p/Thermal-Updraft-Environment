close all
clear
% Load data
sensorData = importSensorData('pedro_csv.csv');
load("sounding_buses.mat","sounding_buses");
sounding = sounding_buses(1);
load('Flights/29-Jul-2024_Schlautmann Nils.mat')
numLevels = sounding_buses.numLevels;

% convert times to duration since start
times = sensorData.time - sensorData.time(1);
times.Format = 's';

latitude = sensorData.gps_y/111000;
latitude = latitude(1:50:609101);
longitude = sensorData.gps_x/111000;
longitude = longitude(1:50:609101);

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

% Setup the simulation and run the sensor tuner model with the
% full simulation environment model now. Make sure to set the simulation
% step size to 1s as the sensor model constants have been adjusted to this
% rate.

%% Extract simulation results (with thermals)
load('Validation/simulation_out_sensor_model.mat')

% Extrac model results
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

%% Extract simulation results (without thermals)
load('Validation/simulation_out_sensor_model_no_thermal.mat')

% Extrac model results
temps = out_no_thermal.yout{1}.Values.Data;
RHs = out_no_thermal.yout{2}.Values.Data;
ps = out_no_thermal.yout{3}.Values.Data;
simalts = out_no_thermal.yout{4}.Values.Data;
simtimes = out_no_thermal.tout;

realT = squeeze(temps(1,1,:));
thermalT2 = squeeze(temps(1,2,:));
sensorT2 = squeeze(temps(1,5,:));
realRH = squeeze(RHs(1,1,:));
thermalRH2 = squeeze(RHs(1,2,:));
sensorRH2 = squeeze(RHs(1,5,:));
realp = squeeze(ps(1,1,:));
thermalp = squeeze(ps(1,2,:));
sensorp = squeeze(ps(1,5,:));
alts = simalts;

difference = thermalT - thermalT2;
%% Make a mask for the thermals
dists = distance(latitude,longitude,sounding.lat,sounding.lon,wgs84Ellipsoid('m'));
%dists = dists(1:50:609101); % Sample dists in 1s intervals
diffs = diff(alts);
mask = diffs>0 & dists(1:end-1) < 39400 & dists(1:end-1) > 38700;% 

% Plot the trajectory and station location
close all
figure
%geoplot(latitude,longitude)
title('Flight Segment')

%geoplot(sounding.lat,sounding.lon,'b^',"LineStyle","none")
%hold on
geoplot(latitude(mask), longitude(mask))
legend('Full','Station','Section')
%% Calculate correlation coeffs on entire flight
corr_temp = corrcoef(realT,sensorT);
corr_hum = corrcoef(realRH,sensorRH);
corr_p = corrcoef(realp,sensorp);

%% Calculate correlations coeffs on thermals
corr_temp = corrcoef(realT(mask),sensorT(mask));
corr_hum = corrcoef(realRH(mask),sensorRH(mask));
corr_p = corrcoef(realp(mask),sensorp(mask));

corr_temp2 = corrcoef(realT(mask),sensorT2(mask));
corr_hum2 = corrcoef(realRH(mask),sensorRH2(mask));
corr_p2 = corrcoef(realp(mask),sensorp(mask));
%% Calculate correlation coeffs excluding surges
corr_temp2 = corrcoef(realT(alts<2004),sensorT(alts<2004));
corr_hum2 = corrcoef(realRH(alts<2004),sensorRH(alts<2004));
corr_p2 = corrcoef(realp(alts<2004),sensorp(alts<2004));

%% Plot values inside the thermal only
zi = 2004;

close all
f1 = figure('Position', [10 10 900 300]);
plot(simtimes(mask), realT(mask),"Color","b")
hold on
plot(simtimes(mask), thermalT(mask),'Color','#0072BD')
plot(simtimes(mask),sensorT(mask))
plot(simtimes(mask), thermalT2(mask),'Color','#0072BD')
plot(simtimes(mask),sensorT2(mask))
legend('Flight Test', 'Thermal Model','Sensor Model',"Location","southeast")
xlabel('Flight Time [s]')
ylabel("Temperature [K]")
xlim([0 12183])
%xline(idx, '--','HandleVisibility','off')
grid on
%saveas(f1,"Images/Validation/comparison-temp",'png')

f2 = figure('Position', [10 10 900 300]);
plot(simtimes(mask),realRH(mask),"Color","b")
hold on
plot(simtimes(mask),thermalRH(mask),'Color','#0072BD')
plot(simtimes(mask),sensorRH(mask))
legend('Flight Test', 'Thermal Model',"Sensor Model","location","southeast")
xlabel('Flight Time [s]')
ylabel("Relative Humidity [%]")
xlim([0 12183])
%xline(idx, '--','HandleVisibility','off')
grid on
%saveas(f2,"Images/Validation/comparison-hum",'png')
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


