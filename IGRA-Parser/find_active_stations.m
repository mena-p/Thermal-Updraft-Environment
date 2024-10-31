function active_stations = find_active_stations(flight, stations, max_dist)
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
    %       - active_stations: Filtered table of stations that meet the criteria.

    % Get flight date
    date = flight.date; % datetime object
    date.TimeZone = 'UTC';
    flightYear = year(date);

    % Get flight position bounding box
    trajectory = flight.trajectory;
    max_lat = max(trajectory.lat.lat);
    max_lon = max(trajectory.lon.lon);
    min_lat = min(trajectory.lat.lat);
    min_lon = min(trajectory.lon.lon);
    mean_lat = mean(trajectory.lat.lat);
    mean_lon = mean(trajectory.lon.lon);
    
    % Only keep stations working during the flight year
    mask = [stations.firstYear] <= datenum(flightYear) & [stations.lastYear] ...
        >= datenum(flightYear);
    stations = stations(mask, :);
    
    % Initialize output
    active_stations = [];
    while(isempty(active_stations))
        % Filter out stations further away than max_dist
        dist1 = distance([stations.lat], [stations.lon], max_lat, max_lon,...
            wgs84Ellipsoid);
        dist2 = distance([stations.lat], [stations.lon], max_lat, min_lon,...
            wgs84Ellipsoid);
        dist3 = distance([stations.lat], [stations.lon], min_lat, max_lon,...
            wgs84Ellipsoid);
        dist4 = distance([stations.lat], [stations.lon], min_lat, min_lon,...
            wgs84Ellipsoid);
        dist5 = distance([stations.lat], [stations.lon], mean_lat, mean_lon,...
            wgs84Ellipsoid);

        mask = dist1 < max_dist | dist2 < max_dist | dist3 < max_dist | ...
            dist4 < max_dist | dist5 < max_dist;
        stations = stations(mask,:);

        % Find out which stations are not up to date and update their files
        old_stations = stations(stations.lastUpdate < date, :);
        download_station_files(old_stations);

        % Find out which stations are active on the day of the flight with the cache
        active_stations = [];
        for i = 1:size(stations,1)
            station = stations(i,:);
            filename = fullfile('IGRA-Parser', 'Cache', strcat(station.ID, '-cache.mat'));
            if isfile(filename)
                load(filename, 'cache');
                if any(cache.date == date)
                    active_stations = [active_stations; station];
                end
            end
        end
        % If no stations are active, increase the distance
        max_dist = max_dist + 200000;
    end
end