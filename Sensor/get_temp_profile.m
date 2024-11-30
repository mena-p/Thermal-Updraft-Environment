function [profile,altitude_bins] = get_temp_profile(sensorData)
%   This function computes the vertical profile of temperature from the measured sensor data
%   by binning the data into altitude bins and computing the mean temperature in each bin.
%   The function returns the altitude bins and the mean temperature in each bin.
%   The data is binned into 1m bins.


temp = sensorData.temperature + 273.15;
altitude = sensorData.gps_altitude;

% Compute the altitude bins
altitude_bins = 0:1:max(altitude);

% Compute the mean humidity in each bin
profile = zeros(1, length(altitude_bins));
for i = 1:length(altitude_bins)
    bin = altitude_bins(i);
    temp_in_bin = temp(altitude >= bin -0.1 & altitude < bin + 0.9);
    profile(i) = mean(temp_in_bin);
end

% Plot the temperature profile
figure
plot(profile, altitude_bins)
xlabel('Temperature (K)')
ylabel('Altitude (m)')
title('Temperature Profile')

end

