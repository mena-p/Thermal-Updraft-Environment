function [T,q,p] = thermal_model(x,y,z,updrafts,sounding_data)
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
    % x = Aircraft x position (m)
    % y = Aircraft y position (m)
    % z = Aircraft height above ground (m)
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
        error('No updrafts were provided');
    end

    % Make an array with the positions of the updrafts
    updraft_positions = zeros(length(updrafts),2);
    for i = 1:num_updrafts
        updraft_positions(i,1) = updrafts{i}.xPosition;
        updraft_positions(i,2) = updrafts{i}.yPosition;
    end

    % Calculate distance to each updraft
    dist = zeros(num_updrafts,1);
    for i = 1:num_updrafts
        dist(i) = updrafts{i}.distance_to(x,y);
    end

    % Find the nearest updraft
    min_dist = min(dist);
    indices = find(dist == min_dist);
    updraft_index = indices(1,1);

    % Round aircraft height to nearest integer
    z = round(z);
    z_top = z + 0.01;
    z_bottom = z - 0.01;

    % Find indices with geopotential height equal to aircraft height
    % The comparison is made in this manner to account for floating- 
    % point precision
    logical_mask = (sounding_data.REPGPH <= z_top & sounding_data.REPGPH >= z_bottom);

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

    % Check if the aircraft is inside the nearest updraft
    if is_inside(updrafts{updraft_index},x,y,z,sounding_data.zi)
        % We assume that the potential and virtual potential temperature
        % are constant inside the updraft, since they are conserved
        % quatities for adiabatic processes.
        
        % Get (virtual) potential temperature values at the surface
        Tp = sounding_data.PTEMP(1,1);
        Tv = sounding_data.VTEMP(1,1);

        % Calculate the temperature inside the updraft (Stull)
        T = Tp * (p/100000)^0.286;

        % T = T + updrafts{updraft_index}.ptemp_diff(x,y);
        % q = q + updrafts{updraft_index}.humidity_diff(x,y);
        
        % Calculate mixing ratio inside the updraft (kg water/kg dry air)
        r = 1/0.61 * (Tv/T - 1);

        % Calculate specific humidity inside the updraft (kg water/kg moist air)
        q = r/(1 + r);
        
    end
end