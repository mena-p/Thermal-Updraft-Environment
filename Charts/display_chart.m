function display_chart(trajectory, stations)
%DISPLAY_CHART Plots the aircraft trajectory and allows selection of updraft locations
%   Detailed explanation goes here
clc
close all

% Extract latitude, longitude and altitude coordinates from the trajectory
traj_lat = trajectory.lat.lat;
traj_lon = trajectory.lon.lon;
%alt = trajectory(3,:);


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



% Plot trajectory
figure
g = geoplot(traj_lat, traj_lon, 'b-');
title('Aircraft Trajectory')

% Set axis limits to fit the trajectory
geolimits([min(traj_lat) max(traj_lat)], [min(traj_lon) max(traj_lon)])

% Add stations to the plot
hold on
geoscatter(stations, "lat", "lon","Marker","^","MarkerEdgeColor","g")
hold off

% Show station names when hovering over the markers wohooooooooooooo
dcm_obj = datacursormode(gcf);
set(dcm_obj ,'UpdateFcn',@data_cursor_updatefcn)
% Callback function to display station names
function output_txt = data_cursor_updatefcn(~, event_obj)
    % Display the position of the data cursor
    pos = event_obj.Position;
    idx = event_obj.DataIndex;
    try
        % Check if the data cursor is not on an updraft
        updraft_locations = evalin(mdlWks, 'updraft_locations');
        if isempty(updraft_locations) || ~any(sqrt((updraft_locations(:,1)-pos(1)).^2 + (updraft_locations(:,2)-pos(2)).^2) < 0.1)
            output_txt = {['Station: ' stations.code{idx}]};
        else
            output_txt = {'Updraft'};
        end
    catch
        output_txt = {''};
    end
end

% Add updraft locations to the plot
if ~isempty(updraft_locations)
    hold on
    for i = 1:size(updraft_locations,1)
        geoscatter(updraft_locations(i,1), updraft_locations(i,2), 'r',"Marker",'o')
    end
    hold off
end



% Create button to automatically detect updrafts
uicontrol('Style', 'pushbutton', 'String', 'Detect Updrafts', 'Position', [20 20 100 30], 'Callback', @detect_updrafts)

% Create button to enter updraft locations
uicontrol('Style', 'pushbutton', 'String', 'Add Updraft', 'Position', [140 20 100 30], 'Callback', @add_updraft)

% Create button to delete just one updraft
uicontrol('Style', 'pushbutton', 'String', 'Delete Updraft', 'Position', [260 20 100 30], 'Callback', @delete_updraft)

% Create button to delete all updrafts
uicontrol('Style', 'pushbutton', 'String', 'Delete All', 'Position', [380 20 100 30], 'Callback', @delete_all)





% Callback function to automatically detect updrafts
    function detect_updrafts(src, event)

        updraft_locations = evalin(mdlWks, 'updraft_locations');

        % Call detect_thermals_igc function
        new_locations = detect_thermals_igc(trajectory);

        updraft_locations = [updraft_locations; new_locations];

        % Remove duplicates (in case the user spams the button)
        [~, idx] = unique(updraft_locations, 'rows');
        updraft_locations = updraft_locations(idx,:);
        
        assignin(mdlWks, 'updraft_locations', updraft_locations)

        % Re-plot the updraft locations
        hold on
        for i = 1:size(new_locations,1)
            geoscatter(new_locations(i,1), new_locations(i,2),'r',"Marker",'o')
        end
        hold off
    end



% Callback function to add updraft locations
    function add_updraft(src, event)

        % Get latitude and longitude from user input
        [lat, lon] = ginput(1);

        % Load updrafts locations from model workspace
        updraft_locations = evalin(mdlWks, 'updraft_locations');

        % Append the updraft to the array
        updraft_locations(end+1,:) = [lat lon];

        % Save the changes to the workspace variable
        assignin(mdlWks, 'updraft_locations', updraft_locations)

        % Re-plot the updraft locations
        hold on
        geoscatter(lat, lon, 'r',"Marker",'o')
        hold off
    end

    % Callback function to delete one updraft
    function delete_updraft(src, event)
        % Load updrafts objects from the workspace
        updraft_locations = evalin(mdlWks, 'updraft_locations');

        % Get latitude and longitude from user input
        [lat, lon] = ginput(1);

        % Find the index of the updraft to delete
        max_distance = 0.1;
        idx = find(sqrt((updraft_locations(:,1)-lat).^2 + (updraft_locations(:,2)-lon).^2) < max_distance, 1);

        % Delete the updraft
        updraft_locations(idx,:) = [];

        % Save the changes to the workspace variable
        assignin(mdlWks, 'updraft_locations', updraft_locations)

        % Re-plot the updraft locations
        delete(findobj('Type', 'Scatter'))
        hold on
        for i = 1:size(updraft_locations,1)
            geoscatter(updraft_locations(i,1), updraft_locations(i,2), 'r',"Marker",'o')
        end
        hold off
    end

    % Callback function to delete all updrafts
    function delete_all(src, event)
        % Load updrafts objects from the workspace
        assignin(mdlWks, 'updraft_locations',[]);
    
        % Clear updrafr locations from the plot
        delete(findobj('Type', 'Scatter'))
    end
end