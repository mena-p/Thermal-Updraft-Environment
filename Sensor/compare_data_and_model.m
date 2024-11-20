% This script prepares data for the Sensor Tuner model,
% which was used to test different sensor models and to 
% compare the flight test data with the thermal model data.
%% Setup
% ATTENTION: Launch the gui first and load the flight, add thermals and 
% select a sounding! Then run the script.
load("sounding_buses.mat","sounding_buses");
sounding_buses = sounding_buses(1);
load("updrafts_full_validation.mat","updrafts")
load("Processed data/sounding_bus.mat",'sounding')
addpath 'C:\Users\Pedro\Documents\Faculdade\Bachelorarbeit\Thermal-Updraft-Model\Flights'
load('29-Jul-2024_Schlautmann Nils.mat')
rmpath 'C:\Users\Pedro\Documents\Faculdade\Bachelorarbeit\Thermal-Updraft-Model\Flights'
numLevels = sounding_buses.numLevels;

%% Load data
sensorData = importSensorData('Raw data/pedro_csv.csv');
numLevels = sounding_buses.numLevels;

% convert times to duration since start
times = sensorData.time - sensorData.time(1);
times.Format = 's';

% Create timetables
alt = timetable(times, sensorData.gps_altitude);
lat = timetable(times, sensorData.gps_x/111000);
lon = timetable(times, sensorData.gps_y/111000);
temp = timetable(times, sensorData.temperature + 273.15);
press = timetable(times, sensorData.pressure*100);
RH = timetable(times, sensorData.humidity);

% Run the sensor tuner now.

%% Extract results

% Extract model results
temps = out.yout{1}.Values.Data;
RHs = out.yout{2}.Values.Data;
ps = out.yout{3}.Values.Data;
simalts = out.yout{4}.Values.Data;
simtimes = out.tout;

realT = squeeze(temps(1,1,:));
modelT = squeeze(temps(1,2,:));
realRH = squeeze(RHs(1,1,:));
modelRH = squeeze(RHs(1,2,:));
realp = squeeze(ps(1,1,:));
modelp = squeeze(ps(1,2,:));
alts = simalts;

%% Plot altitudes
figure
plot(simtimes, alts)
legend('sim')
hold on
plot(flight.trajectory.alt.alt(896:end))
legend('igc')

%% Find surge locations

% Find all simtimes where alts is about zi (+-10m)
zi = 2004;
idx = find(alts > zi - 10 & alts < zi + 10);

% Remove indices that are too close to each other, leaving only one
idx = idx([true; diff(idx) > 10]);

% Note: manual adjustment of the idx vector is needed to remove some
% entries, the indices used in the thesis are saved to zi_indices.mat
load("zi_indices.mat")

%% Plot real and simulated values
close all
figure('Position', [10 10 900 300])
plot(simtimes, realT,"Color","b")
hold on
plot(simtimes, modelT,'Color','#0072BD')
legend('Flight Test', 'Simulation',"Location","northwest")
xlabel('Flight Time [s]')
ylabel("Temperature [K]")
xlim([0 12183])
%xline(idx, '--','HandleVisibility','off')
grid on
%saveas(gcf,"Images/Sensor/comparison-temp",'png')

figure('Position', [10 10 900 300])
plot(simtimes,realRH,"Color","b")
hold on
plot(simtimes,modelRH,'Color','#0072BD')
legend('Flight Test', 'Simulation',"Location","southeast")
xlabel('Flight Time [s]')
ylabel("Relative Humidity [%]")
xlim([0 12183])
%xline(idx, '--','HandleVisibility','off')
grid on
%saveas(gcf,"Images/Sensor/comparison-hum",'png')

figure('Position', [10 10 900 300])
plot(simtimes,realp,"Color","b")
hold on
plot(simtimes,modelp,'Color','#0072BD')
legend('Flight Test', 'Simulation',"Location","southeast")
xlabel('Flight Time [s]')
ylabel("Pressure [Pa]")
xlim([0 12183])
grid on
%saveas(gcf,"Images/Sensor/comparison-press",'png')

figure('Position', [10 10 900 300])
plot(simtimes, alts)
grid on
hold on
plot(simtimes, ones(size(simtimes))*zi, '--',"Color",'[0 0 0]','LineWidth',1)
legend('Altitude', 'Inversion Height',"Location","northwest")
xlabel('Filght Time [s]')
ylabel("Altitude [m]")
xlim([0 12183])
hold on
%xline(idx, '--','HandleVisibility','off')
%saveas(gcf,"Images/Sensor/comparison-alt",'png')

%% Plots expaining spikes
close all
low = 5500;
high = 7650;
figure
subplot(3,1,1)
plot(simtimes, modelT,'Color','#D95319')
ylabel("Temperature [K]")
xlim([low high])
xline(idx, '--','HandleVisibility','off')
grid on

subplot(3,1,2)
plot(simtimes,modelRH,'Color','#0072BD')
ylabel("Relative Humidity [%]")
xlim([low high])
xline(idx, '--','HandleVisibility','off')
grid on

subplot(3,1,3)
plot(simtimes, alts,"color","g")
grid on
hold on
plot(simtimes, ones(size(simtimes))*zi, '--',"Color",'[0 0 0]','LineWidth',0.6)
legend('', 'Mixed Layer',"Location","northwest")
xlabel('Filght Time [s]')
ylabel("Altitude [m]")
xlim([low high])
hold on
xline(idx, '--','HandleVisibility','off')
%% Plot flight and the used station in geoaxes
figure
geoplot(flight.trajectory.lat.lat, flight.trajectory.lon.lon)
hold on
plot(sounding_buses.lat(1), sounding_buses.lon(1), 'b^', 'LineStyle', 'none')
legend('Trajectory','Station')