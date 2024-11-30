% Detects thermal positions from a given flight trajectory.
% 
%   The function takes a flight trajectory structure containing latitude, 
%   longitude, and altitude data and detects thermal positions based on 
%   circular patterns in the trajectory. The function returns the thermal
%   positions in latitude and longitude coordinates. The original algorithm
%   was developed by Leo Heller in SoarSense: A Comprehensive Measurement 
%   and Validation Platform for Thermal Models.
%
%   Input:
%       trajectory - A structure containing the a timetable with 
%                    fields 'lat', 'lon', and 'alt'.
%                    
%   Output:
%       Thermal_positions - An Nx2 matrix containing the latitude and longitude 
%                           coordinates of detected thermal positions.
function [Thermal_positions] = detect_thermals_igc(trajectory)
    
    positions = [];
    diameters = [];
    % Make a table of lat, lon, and alt
    table = [trajectory.lat.lat, trajectory.lon.lon, trajectory.alt.alt];

    % Remove rows where the plane is on the ground
    table = table(table(:,3) > 400, :);
    
    % Extract the latitude and longitude coordinates from the flight object
    lat = table(:,1);
    lon = table(:,2);
    alt = table(:,3);
    
    % Convert the latitude and longitude coordinates to Cartesian coordinates
    wgs84 = wgs84Ellipsoid('meter');
    [x, y, z] = geodetic2ned(lat, lon, alt, lat(1), lon(1), alt(1),wgs84);

    % Circle detection parameters
    look_ahead_max = 50;
    look_ahead_min = 5;

    % Create array to store circle indices
    circle_indices = [];
    
    % Detect circles in the aircraft trajectory
    n = length(x);
    for i = 1:n
        if ~isempty(circle_indices) & i < circle_indices(end,2)
            continue;
        end

        current_x = x(i);
        current_y = y(i);
        for j = i+look_ahead_min:min(i+look_ahead_max,n)
            next_x = x(j);
            next_y = y(j);
            distance = sqrt((next_x-current_x)^2 + (next_y-current_y)^2);
            if distance < 50
                circle_indices = [circle_indices; [i, j]];
                break;
            end
        end
    end
    
    % Calculate the circle positions and diameters
    positions = [];
    for i = 1:size(circle_indices,1)
        start_index = circle_indices(i,1);
        end_index = circle_indices(i,2);
        x_segment = x(start_index:end_index);
        y_segment = y(start_index:end_index);
        z_segment = z(start_index:end_index);
        avg_position = [mean(x_segment), mean(y_segment), mean(z_segment)];
        diameter = sqrt((max(x_segment)-min(x_segment))^2 + (max(y_segment)-min(y_segment))^2);
        if diameter > 30
            positions = [positions; avg_position];
            diameters = [diameters; diameter];
        end
    end

    % Group nearby circles into thermals
    thermal_positions = [];
    circle_group = [];
    for i = 1:size(positions,1)
        if isempty(circle_group) % If the circle group is empty, add the current position to it
            circle_group = [positions(i,:)];
        else % If the circle group is not empty, check if the current position is close to the last position in the group
            distance = sqrt((positions(i,1)-circle_group(end,1))^2 + (positions(i,2)-circle_group(end,2))^2);
            altitude_increase = positions(i,3) - circle_group(end,3);
            if distance < 200 && altitude_increase < 0 % smaller than zero because of NED coordinates
                circle_group = [circle_group; positions(i,:)];
            else % If the current position is not close to the last position in the group, add the mean position of the group to the thermal positions
                if size(circle_group,1) > 1
                    thermal_positions = [thermal_positions; mean(circle_group)];
                end % Clear the array
                circle_group = [];
            end
        end
    end
    if isempty(thermal_positions)
        Thermal_positions = [];
    else
        % Corvert the thermal positions to latitude and longitude coordinates
        [Thermal_positions(:,1), Thermal_positions(:,2), ~] = ned2geodetic(thermal_positions(:,1), thermal_positions(:,2), thermal_positions(:,3), lat(1), lon(1), alt(1), wgs84);
        % Convert the circle positions to latitude and longitude coordinates
        [positions(:,1), positions(:,2), positions(:,3)] = ned2geodetic(positions(:,1), positions(:,2), positions(:,3), lat(1), lon(1), alt(1), wgs84);  
    end
end