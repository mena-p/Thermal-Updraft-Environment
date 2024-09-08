function stations = find_nearby_stations(flight, stations, max_dist)
    % FIND_NEARBY_STATIONS - Filter stations based on flight date and position range
    %
    %   Syntax:
    %       stations = find_nearby_stations(flight, stations, max_dist)
    %
    %   Input Arguments:
    %       - flight: Structure containing flight information, including the flight date and trajectory.
    %       - stations: Table containing information about available stations, including latitude, longitude, and observation years.
    %       - max_dist: Maximum distance (in meters) allowed between a station and the flight trajectory.
    %
    %   Output Argument:
    %       - stations: Filtered table of stations that meet the criteria.

    % Get flight date
    date = flight.date; % datetime object
    date = year(date);

    % Get flight position bounding box
    trajectory = flight.trajectory;
    max_lat = max(trajectory.lat.lat);
    max_lon = max(trajectory.lon.lon);
    min_lat = min(trajectory.lat.lat);
    min_lon = min(trajectory.lon.lon);
    
    % Only keep stations working during the flight year
    mask = [stations.firstYear] <= datenum(date) & [stations.lastYear] ...
        >= datenum(date);
    stations = stations(mask, :);
    
    % Filter out stations further away than max_dist
    dist1 = distance([stations.lat], [stations.lon], max_lat, max_lon,...
        wgs84Ellipsoid);
    dist2 = distance([stations.lat], [stations.lon], max_lat, min_lon,...
        wgs84Ellipsoid);
    dist3 = distance([stations.lat], [stations.lon], min_lat, max_lon,...
        wgs84Ellipsoid);
    dist4 = distance([stations.lat], [stations.lon], min_lat, min_lon,...
        wgs84Ellipsoid);

    mask = dist1 < max_dist | dist2 < max_dist | dist3 < max_dist | ...
        dist4 < max_dist;
    stations = stations(mask,:);
end