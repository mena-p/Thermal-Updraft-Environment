function [T,q,p] = thermal_model(x,y,z,updrafts,sounding_data)
    % This function calculates the temperature, specific humidity, and
    % pressure at the aircraft's position.
    % It checks if the aircraft is in an updraft and computes the
    % temperature, specific humidity, and pressure accordingly. If
    % the aircraft is not in an updraft, it uses the values from the
    % atmospheric sounding. If it is in an updraft, it uses the values
    % from the updraft.
    %
    % Inputs:
    % x = Aircraft x position (m)
    % y = Aircraft y position (m)
    % z = Aircraft height above ground (m)
    % updrafts = Array of updraft objects
    %
    % Outputs:
    % T = Temperature (K)
    % q = Specific humidity (kg/kg)
    % p = Pressure (Pa)
    
    % Get the number of updrafts
    num_updrafts = length(updrafts);
    
    % Check if there are no updrafts
    if num_updrafts == 0
        warning('No updrafts were provided');
    end
    
    % Make an array with the positions of the updrafts
    updraft_positions = zeros(length(updrafts),2);
    for i = 1:num_updrafts
        updraft_positions(i,1) = updrafts(i).xPosition;
        updraft_positions(i,2) = updrafts(i).yPosition;
    end

    % Calculate distance to each updraft
    dist = zeros(num_updrafts,1);
    for i = 1:num_updrafts
        dist(i) = updrafts(i).distance_to(x,y);
    end

    % Find the nearest updraft
    updraft_index = find(dist == min(dist));
    if length(updraft_index) > 1
        updraft_index = updraft_index(1);
    end
    % Round aircraft height to nearest integer
    z = round(z);

    % Find index with geopotential height closest to aircraft height
    index = find(sounding_data.REPGPH == z);

    % Get the sounding's pressure, temperature and vapor pressure at that height
    p = sounding_data.PRESS(index);
    T = sounding_data.TEMP(index);
    vap_press = sounding_data.VAPPRESS(index);

    % Check if the aircraft is inside the nearest updraft
    if is_inside(updrafts(updraft_index),x,y,z)
        % Add temperature and humidity excess to environmental values

    end
    
end