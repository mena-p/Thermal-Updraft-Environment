function [T,q,p] = thermal_model(lat,lon,alt,updrafts,sounding_data)
    % This function calculates the temperature, specific humidity, and
    % pressure at the aircraft's position.
    % It checks if the aircraft is in an updraft and computes the
    % temperature, specific humidity, and pressure accordingly. If
    % the aircraft is not in an updraft, it uses the values from the
    % atmospheric sounding. If it is in an updraft, it assumes constant
    % potential and virtual potential temperature to calculate the
    % temperature and specific humidity.
    %
    % Inputs:
    % lat = Aircraft latitude (degrees)
    % lon = Aircraft longitude (degrees)
    % alt = Aircraft height above ground (m)
    % updrafts = A CELL array of updraft objects (code generation
    %            requires this to be a cell array)
    %
    % Outputs:
    % T = Temperature (K)
    % q = Specific humidity (kg/kg)
    % p = Pressure (Pa)
    
    % Initialize variables for code generation
    T = 0.0;
    q = 0.0;
    p = 0.0;

    % Get the number of updrafts
    num_updrafts = length(updrafts);
    
    % Check if there are no updrafts
    if num_updrafts == 0
        error('No updrafts were provided. Use the Updrafts panel to place updrafts on the map.');
    end

    % Make an array with the positions of the updrafts
    updraft_positions = zeros(length(updrafts),2);
    for i = 1:num_updrafts
        updraft_positions(i,1) = updrafts{i}.latitude;
        updraft_positions(i,2) = updrafts{i}.longitude;
    end

    % Calculate distance to each updraft
    dist = zeros(num_updrafts,1);
    for i = 1:num_updrafts
        dist(i) = updrafts{i}.distance_to(lat,lon);
    end

    % Find the nearest updraft
    min_dist = min(dist);
    indices = find(dist == min_dist);
    updraft_index = indices(1,1);

    % Round aircraft height to nearest integer
    alt = round(alt);
    alt_top = alt + 0.01;
    alt_bottom = alt - 0.01;

    % Find indices with geopotential height equal to aircraft height
    % The comparison is made in this manner to account for floating- 
    % point precision
    logical_mask = (sounding_data.REPGPH <= alt_top & sounding_data.REPGPH >= alt_bottom);

    % Check if logical mask contains only zeros
    if ~any(logical_mask)
        error('Aircraft height is not in sounding data');
    end

    % Get the sounding's pressure, temperature and specific humidity at that height
    p = sounding_data.PRESS(logical_mask,1);
    T = sounding_data.TEMP(logical_mask,1);
    vap_press = sounding_data.VAPPRESS(logical_mask,1);
    r = 0.622 * vap_press/(p - vap_press); % mixing ratio (kg water/kg dry air)
    q = r/(1 + r); % specific humidity (kg water/kg moist air)

    p = p(1,1);
    T = T(1,1);
    q = q(1,1);

    % Add the updraft's potential temperature and specific humidity excess to the
    % sounding data's values
    T = T + updrafts{updraft_index}.ptemp_diff(lat,lon);
    q = q + updrafts{updraft_index}.humidity_diff(lat,lon)/1000;

    % Check if the aircraft is inside the nearest updraft
    %if is_inside(updrafts{updraft_index},x,y,z,sounding_data.zi)
        % We add the updraft's potential temperature and specific humidity excess to the
        % sounding data's values
        
        %% Get (virtual) potential temperature values at the aircrafts height
        %Tp = sounding_data.PTEMP(1,1);
        %Tv = sounding_data.VTEMP(1,1);

        %% Calculate the temperature inside the updraft (Stull)
        %T = Tp * (p/100000)^0.286;
        
        %% Calculate mixing ratio inside the updraft (kg water/kg dry air)
        %r = 1/0.61 * (Tv/T - 1);

        %% Calculate specific humidity inside the updraft (kg water/kg moist air)
        %q = r/(1 + r);

        %T = T + updrafts{updraft_index}.ptemp_diff(x,y);
        %q = q + updrafts{updraft_index}.humidity_diff(x,y)/1000;
        
    %end
end