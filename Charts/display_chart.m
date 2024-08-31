function display_chart(trajectory)
%DISPLAY_CHART Plots the aircraft trajectory and allows selection of updraft locations
%   Detailed explanation goes here
clc
close all

% Extract latitude, longitude and altitude coordinates from the trajectory
traj_lat = trajectory(1,:);
traj_lon = trajectory(2,:);
%alt = trajectory(3,:);

% save the trajectory to the workspace
assignin('base', 'traj_lat', traj_lat)
assignin('base', 'traj_lon', traj_lon)

% Get handle for simulink workspace
mdlWks = get_param('model','ModelWorkspace');

% Load updrafts objects from the workspace if they exist
if evalin(mdlWks, 'exist(''updraft_locations'', ''var'')')
    updraft_locations = evalin(mdlWks, 'updraft_locations');
else
    % Create empty 2d array for updrafts
    updraft_locations = zeros(0, 0);
    assignin(mdlWks, 'updraft_locations', updraft_locations)
end


% Plot trajectory and updrafts
figure
% Create a geographic plot of the aircraft trajectory
geoplot(traj_lat, traj_lon, 'b-')
title('Aircraft Trajectory')
legend('Aircraft Trajectory')

% Add updraft locations to the plot
if ~isempty(updraft_locations)
    hold on
    for i = 1:size(updraft_locations,2)
        geoscatter(updraft_locations(1,i), updraft_locations(2,i), 'r', 'filled')
    end
    hold off
end

% Create button to enter updraft locations
uicontrol('Style', 'pushbutton', 'String', 'Add Updraft', 'Position', [20 20 100 30], 'Callback', @add_updraft)

% Create button to delete all updrafts
uicontrol('Style', 'pushbutton', 'String', 'Reset', 'Position', [140 20 100 30], 'Callback', @delete_updrafts)

% Callback function to add updraft locations
    function add_updraft(src, event)

        % Get latitude and longitude from user input
        [lat, lon] = ginput(1);

        % Load updrafts locations from model workspace
        updraft_locations = evalin(mdlWks, 'updraft_locations');

        % Append the updraft to the array
        updraft_locations(:,end+1) = [lat lon];

        % Save the changes to the workspace variable
        assignin(mdlWks, 'updraft_locations', updraft_locations)

        % Re-plot the updraft locations
        hold on
        geoscatter(lat, lon, 'r', 'filled')
        hold off
    end

    % Callback function to delete an updraft
    function delete_updrafts(src, event)
        % Load updrafts objects from the workspace
        assignin(mdlWks, 'updraft_locations',[]);
    
        % Clear updrafr locations from the plot
        delete(findobj('Type', 'Scatter'))
    end
end