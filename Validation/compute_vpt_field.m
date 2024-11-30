
function [vpt, lat_grid, lon_grid] = compute_vpt_field(sounding_buses,updrafts,resolution)
%   Computes the VPT field over a specified area based on updraft positions
%   and sounding data. The function returns the VPT field, latitude grid, 
%   and longitude grid. The temperature, humidity, and pressure are
%   computed using the thermal model function.
% 
%   Inputs:
%       sounding_buses - Array of sounding data structures.
%       updrafts       - Cell array of updraft data structures.
%       resolution     - Resolution of the grid.
% 
%   Outputs:
%       vpt            - Computed VPT field.
%       lat_grid       - Latitude grid.
%       lon_grid       - Longitude grid.

    % Extract updraft positions
    latitudes = zeros(1, length(updrafts));
    longitudes = zeros(1, length(updrafts));
    for i = 1:length(updrafts)
        latitudes(i) = updrafts{i}.latitude;
        longitudes(i) = updrafts{i}.longitude;
    end

    % Define the area to compute the VPT based on the updrafts
    lat_min = min(latitudes) - 0.02;
    lat_max = max(latitudes) + 0.02;
    lon_min = min(longitudes) - 0.02;
    lon_max = max(longitudes) + 0.02;

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
    [lon_grid, lat_grid] = meshgrid(linspace(lon_min, lon_max, resolution+1), linspace(lat_min, lat_max, resolution));

    % Initialize the VPT field
    vpt = zeros(size(lon_grid));

    % Get the lowest max and highest min alts among the soundings
    min_alts = zeros(1, length(sounding_buses));
    max_alts = zeros(1, length(sounding_buses));
    for i = 1:length(sounding_buses)
        min_alts(i) = min(sounding_buses(i).REPGPH);
        max_alts(i) = max(sounding_buses(i).REPGPH);
    end

    % set sample altitude such that it is not outside any sounding
    alt = min((max(min_alts) + min(max_alts))/2,1500);

    % Loop through each point in the grid
    for i = 1:size(lon_grid, 1) % i = lat
        for j = 1:size(lon_grid, 2) % j = lon
            % Get the current latitude and longitude
            lat = lat_grid(i, j);
            lon = lon_grid(i, j);

            % Call the thermal model to determine the temperature, humidity, and pressure
            [T,~,p,RH] = thermal_model(lat, lon, alt, [0 0 0], updrafts, sounding_buses);

            % Compute the virtual potential temperature
            vpt(i, j) = compute_vpt(T(1), RH(1), p(1));
        end
    end
end