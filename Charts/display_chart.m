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



% Load updrafts objects from the workspace if they exist
if evalin('base', 'exist(''updrafts'', ''var'')')
    updrafts = evalin('base', 'updrafts');
else
    updrafts = [];
    assignin('base', 'updrafts', updrafts)
end



% Create a figure
figure
% Create a geographic plot of the aircraft trajectory
geoplot(traj_lat, traj_lon, 'b-')
% Add a title
title('Aircraft Trajectory')
% Add a legend
legend('Aircraft Trajectory')

% Add updraft locations to the plot
if ~isempty(updrafts)
    hold on
    for i = 1:size(updrafts)
        geoscatter(updrafts(i).xPosition, updrafts(i).yPosition, 'r', 'filled')
    end
    hold off
end

% Create button to enter updraft locations
uicontrol('Style', 'pushbutton', 'String', 'Add Updraft', 'Position', [20 20 100 30], 'Callback', @add_updraft)

% Create button to delete an updraft
uicontrol('Style', 'pushbutton', 'String', 'Reset', 'Position', [140 20 100 30], 'Callback', @delete_updrafts)

% Callback function to add updraft locations
    function add_updraft(src, event)
        % Allow the user to select a point on the map
        [lat, lon] = ginput(1);

        updrafts = evalin('base', 'updrafts');

        updraft = Updraft(lat, lon, 1);

        % Append the updraft location in the output variable
        updrafts = [updrafts; updraft];

        % Save the changes to the workspace variable
        assignin('base', 'updrafts', updrafts)

        % Re-plot the updraft locations
        hold on
        geoscatter(updraft.xPosition, updraft.yPosition, 'r', 'filled')
        hold off
    end
end

% Callback function to delete an updraft
function delete_updrafts(src, event)
    % Load updrafts objects from the workspace
    updrafts = [];
    assignin('base', 'updrafts', updrafts)

    % Clear updrafr locations from the plot
    delete(findobj('Type', 'Scatter'))
    
end

