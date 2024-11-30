% This script was used to validate the full simulation environment. If you
% want to verify the validation, run every section and the sensor tuner
% model (follow the instructions in the comments). Or you can skip
% the first and second sections by uncommenting the load command on line 46
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

%% Run the SensorTuner.slx model
% Run the sensor tuner model with the
% full simulation environment model now. Make sure to set the simulation
% step size to 1s as the cockpit sensor model constants have been adjusted 
% for this rate.

%% Extract simulation results
%load('Validation/simulation_out_sensor_model.mat') % <- Uncomment this line to skip the simulation

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

% Remove the first 12 seconds of data (time it takes for velocity to 
% converge due to filtered derivative)
realT = realT(12:end);
thermalT = thermalT(12:end);
sensorT = sensorT(12:end);
realRH = realRH(12:end);
thermalRH = thermalRH(12:end);
sensorRH = sensorRH(12:end);
realp = realp(12:end);
thermalp = thermalp(12:end);
sensorp = sensorp(12:end);
alts = simalts(12:end);
simtimes = simtimes(12:end);
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