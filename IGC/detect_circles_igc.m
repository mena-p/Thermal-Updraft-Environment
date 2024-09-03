function [positions, diameters] = detect_circles_igc(data)
    
    positions = [];
    diameters = [];
    % Make a table of lat, lon, and alt
    table = [data.trajectory.lat.lat, data.trajectory.lon.lon, data.trajectory.alt.alt];

    % Remove rows where the plane is on the ground
    table = table(table(:,3) > 400, :);
    
    % Extract the latitude and longitude coordinates from the flight object
    lat = table(:,1);
    lon = table(:,2);
    alt = table(:,3);
    
    % Convert the latitude and longitude coordinates to Cartesian coordinates
    wgs84 = wgs84Ellipsoid('meter');
    [x, y, ~] = geodetic2ned(lat, lon, alt, lat(1), lon(1), alt(1),wgs84);

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
        avg_position = [mean(x_segment), mean(y_segment)];
        diameter = sqrt((max(x_segment)-min(x_segment))^2 + (max(y_segment)-min(y_segment))^2);
        if diameter > 30
            positions = [positions; avg_position];
            diameters = [diameters; diameter];
        end
    end
    % Convert the circle positions to latitude and longitude coordinates
    [positions(:,1), positions(:,2), ~] = ned2geodetic(positions(:,1), positions(:,2), 0, lat(1), lon(1), alt(1),wgs84);    
end
