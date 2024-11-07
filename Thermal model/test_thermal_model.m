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
    [T, q, p,RH] = updraft_model(lat(i), lon(i), alt(i), [pi/4,0,0], sounding_buses, updrafts);
    fprintf('Iteration %d: alt = %f, 1 = %f,2 = %f,3 = %f\n', i, alt(i), RH(1),RH(2),RH(3));
    %fprintf('Iteration %d: alt = %f, w1 = %f, w2 = %f, sum = %f\n', i, alt(i), w(1), w(2), w(1)+w(2))
end

function [T, q, p,RH] = updraft_model(lat, lon, alt, euler_angles, sounding_buses, updrafts)
    
    if size(updrafts,1)
        [T, q, p,RH] = thermal_model(lat, lon, alt, euler_angles, updrafts, sounding_buses);
    else
        % Suppress Simulink coder error
        T = 0;
        p = 0;
        q = 0;
    end
end