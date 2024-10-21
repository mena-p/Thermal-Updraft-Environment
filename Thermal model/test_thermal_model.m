% test_thermal_model.m
% This script tests the thermal_model function in a loop

% Extract lat, lon, and alt from the flight.trajectory timeseries
lat = flight.trajectory.lat.lat;
lon = flight.trajectory.lon.lon;
alt = flight.trajectory.alt.alt;

% Number of iterations for testing
num_iterations = length(lat);

% Loop to test the thermal_model function
for i = 1:num_iterations
    [T, q, p] = updraft_model(lat(i), lon(i), alt(i), sounding_buses, updraft_locations);
    fprintf('Iteration %d: alt = %f, T = %f, q = %f, p = %f\n', i, alt(i), T, q, p);
    %fprintf('Iteration %d: alt = %f, w1 = %f, w2 = %f, sum = %f\n', i, alt(i), w(1), w(2), w(1)+w(2))
end

function [T, q, p] = updraft_model(lat, lon, alt, sounding_buses, updraft_locations)
    num_updrafts = size(updraft_locations, 1);
    updrafts = cell(1, num_updrafts);
    
    if num_updrafts
        latitudes = updraft_locations(:, 1);
        longitudes = updraft_locations(:, 2);
    
        for i = 1:num_updrafts
            updrafts{i} = Updraft(latitudes(i), longitudes(i));
        end
        [T, q, p] = thermal_model(lat, lon, alt, updrafts, sounding_buses);
    else
        % Suppress Simulink coder error
        T = 0;
        p = 0;
        q = 0;
    end
end