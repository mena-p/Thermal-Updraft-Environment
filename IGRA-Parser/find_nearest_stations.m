function nearby_stations = find_nearest_stations(flight, stations)
    % FIND_NEAREST_STATIONS - Find the nearest stations to a flight trajectory
    %
    %   Inputs:
    %       - flight: Structure containing flight information, including the 
    %         flight date and trajectory.
    %       - stations: Table containing information about available stations,
    %         including latitude, longitude, and observation years
    %
    %   Output:
    %       - nearby_stations: Table of stations closest to the flight trajectory.
    
    nearby_stations = table(); 
    trajectory = flight.trajectory;
    wgs84 = wgs84Ellipsoid('m');
    for i = 1:10:height(trajectory.lat)
        lat = trajectory.lat.lat(i);
        lon = trajectory.lon.lon(i);
        minDistance = Inf;
        
        for j = 1:height(stations)
            station = stations(j,:);
            d = distance(station.lat,station.lon,lat,lon,wgs84);
            
            if d < minDistance
                minDistance = d;
                closestStation = station;
            end
        end
       
        % Check if nearby_stations is empty
        if isempty(nearby_stations)
            nearby_stations = closestStation;
        end 
        % Check if any row in nearby_stations is the same as closestStation
        name = closestStation.ID;
        mask = strcmp(name, nearby_stations.ID);
        if ~any(mask)
            nearby_stations = [nearby_stations; closestStation];
        end

        
    end
end