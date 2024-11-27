function [profile,altitude_bins] = get_humidity_profile(sensorData)
%GET_HUMIDITY_PROFILE This function extracts the humidity profile from measured sensor data
%   This function computes the vertical profile of humidity from the measured sensor data
%   by binning the data into altitude bins and computing the mean humidity in each bin.
%   The function returns the altitude bins and the mean humidity in each bin.
%   The data is binned into 1m bins.


humidity = sensorData.humidity;
altitude = sensorData.gps_altitude;

% Compute the altitude bins
altitude_bins = 0:1:max(altitude);

% Compute the mean humidity in each bin
profile = zeros(1, length(altitude_bins));
for i = 1:length(altitude_bins)
    bin = altitude_bins(i);
    humidity_in_bin = humidity(altitude >= bin -0.1 & altitude < bin + 0.9);
    profile(i) = mean(humidity_in_bin);
end

profile = movmean(profile,2);
end

