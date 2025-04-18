% This script tests the thermal_model function in a loop

% ATTENTION: Set up a simulation with the GUI first, choosing a flight,
% sounding and updrafts. Run the script from the root directory.
gui()

%% Run after setting up with the GUI
% Extract lat, lon, and alt from the flight.trajectory timeseries
lat = flight.trajectory.lat.lat;
lon = flight.trajectory.lon.lon;
alt = flight.trajectory.alt.alt;

% Number of iterations for testing
num_iterations = length(lat);

% Loop to test the thermal_model function
for i = 1:num_iterations
    [T, q, p,RH] = updraft_model(lat(i), lon(i), alt(i), [pi/4,0,0], sounding_buses, updrafts);
    fprintf('Iteration %d: alt = %f, C = %f, L = %f, R = %f\n', i, alt(i), T(1),T(2),T(3));
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