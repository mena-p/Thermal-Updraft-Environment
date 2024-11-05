function [vpt, lat_grid, lon_grid] = compute_vpt_field(sounding_buses, updrafts, flight)
    % Extract the flight trajectory
    latitudes = flight.trajectory.lat.lat;
    longitudes = flight.trajectory.lon.lon;

    % Define the area to compute the VPT based on the flight trajectory
    lat_min = min(latitudes) - 0.1;
    lat_max = max(latitudes) + 0.1;
    lon_min = min(longitudes) - 0.1;
    lon_max = max(longitudes) + 0.1;

    % Set a minimum map size to 5 degrees
    if lon_max - lon_min < 0.05
        lon_max = lon_max + 0.025;
        lon_min = lon_min - 0.025;
    end
    if lat_max - lat_min < 0.05
        lat_max = lat_max + 0.025;
        lat_min = lat_min - 0.025;
    end

    % Create a grid in latitude and longitude coordinates
    [lat_grid, lon_grid] = meshgrid(linspace(lat_min, lat_max, 20), linspace(lon_min, lon_max, 10));

    % Initialize the VPT field
    vpt = zeros(size(lat_grid));

    % Get the lowest max and highest min alts among the soundings
    min_alts = zeros(1, length(sounding_buses));
    max_alts = zeros(1, length(sounding_buses));
    for i = 1:length(sounding_buses)
        min_alts(i) = min(sounding_buses(i).REPGPH);
        max_alts(i) = max(sounding_buses(i).REPGPH);
    end

    alt = (max(min_alts) + min(max_alts))/2;

    % Loop through each point in the grid
    for i = 1:size(lat_grid, 1)
        for j = 1:size(lat_grid, 2)
            % Get the current latitude and longitude
            lat = lat_grid(i, j);
            lon = lon_grid(i, j);

            % Call the thermal model to determine the temperature and humidity
            [T,~,p,RH] = thermal_model(lat, lon, alt, [0 0 0], updrafts, sounding_buses);

            % Compute the virtual potential temperature
            vpt(i, j) = compute_vpt(T(1), RH(1), p(1));
        end
    end

    % Display the VPT field as a contour map
    test = contourf(lon_grid, lat_grid, vpt);
    colorbar;
    title('Virtual Potential Temperature Contour');
    xlabel('Longitude');
    ylabel('Latitude');
end