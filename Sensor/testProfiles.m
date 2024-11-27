% This script was used to determine if tuning the sensor model on a
% humidity profile calculated from the sensor data is feasible. The results
% show that no single profile is enough to accurately predict the humidity
% over the entire flight.

close all
clear

% Load data
load('sounding_buses_tuning.mat') 
sounding = sounding_buses(1); % the ptemp is extrapolated above zi 
% in this sounding, just like it is in the actual simulation environment

sensorData = importSensorData('Raw data/pedro_csv.csv');
altitude = sensorData.gps_altitude;
time = sensorData.time - sensorData.time(1);
time.Format = 's';

diffH = diff(altitude)./0.02;

%% Test substitute humidity profiles
close all
section1 = sensorData(1:60000,:); % 0 to 20 mins
section2 = sensorData(60001:120001,:); % 20 to 40 mins
[profile, altitude_bins] = get_humidity_profile(section1(diffH(1:60000) < 0,:));
[profile2, altitude_bins2] = get_humidity_profile(section2(diffH(60001:120001) < 0,:));

figure
plot(profile, altitude_bins)
hold on
plot(profile2, altitude_bins2)
xlabel('Relative Humidity [%]')
ylabel('Altitude [m]')
title('Humidity Profiles')
legend('Profile 1 (Segment 1)','Profile 2 (Segment 2)')
%saveas(gcf,'Images/Sensor/Humidity profiles for segments 1 and 2','png')

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

n = size(sensorData.humidity,1);
pred_rh2 = zeros(n,1);
for i =1:n
    idx = int32(sensorData.gps_altitude(i));
    if idx > size(profile2,2)
        continue
    end
    pred_rh2(i) = profile2(idx);
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

figure('Position', [10 10 900 300])
plot(time(1:120001),pred_rh(1:120001))
hold on
plot(time(1:120001),pred_rh2(1:120001))
plot(time(1:120001),sensorData.humidity(1:120001))
xlabel('Flight Time [s]')
ylabel('Relative Humidity [%]')
xline(1200,'--','HandleVisibility','off')
ylim([40 65])
legend('Profile 1','Profile 2','Flight Test',"Location","northwest")
%saveas(gcf,'Images/Sensor/Predicted humidity by profiles 1 and 2','png')
