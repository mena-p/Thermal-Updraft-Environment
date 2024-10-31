function [T_out,q_out,p_out,RH_out] = thermal_model(lat,lon,alt,euler_angles,updrafts,sounding_buses)
    % This function calculates the temperature, specific humidity, and
    % pressure at the aircraft's position.
    % It checks if the aircraft is in an updraft and computes the
    % temperature, specific humidity, and pressure accordingly. If
    % the aircraft is not in an updraft, it uses the values from the
    % atmospheric soundings. If it is in an updraft, it adds the updraft's
    % potential temperature and specific humidity excess to the sounding
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

    glider.wingspan = 12; % wingspan of the glider (m)
    d_nose_to_center = 0.8; % distance from nose to center of the wings (m)
    
    %% Compute wingtip positions
    % Rotation matrix from body to NED frame
    roll = euler_angles(1);
    pitch = euler_angles(2);
    yaw = euler_angles(3);
    Mob = angle2dcm(yaw, pitch, roll)'; % transpose to get from body to NED frame

    % Wingtip and nose positions in body frame x (nose), y (right wing), z (down)
    % The CG/origin of the body frame is between the wings
    nose = [d_nose_to_center; 0; 0];
    left_wingtip = [0; -glider.wingspan/2; 0];
    righ_wingtip = [0; glider.wingspan/2; 0];


    % Transform to NED frame   
    nose = Mob * nose;
    left_wingtip = Mob * left_wingtip;
    righ_wingtip = Mob * righ_wingtip;


    % Add CG position in NED frame (it's zero, so we don't do anything)

    % Convert NED positions to lat/lon/alt, the NED frame's origin is at [lat; lon; alt]
    wgs84 = wgs84Ellipsoid();    
    [lat_nose, lon_nose, alt_nose] = ned2geodetic(nose(1), nose(2), nose(3), lat, lon, alt, wgs84);
    [lat_left, lon_left, alt_left] = ned2geodetic(left_wingtip(1), left_wingtip(2), left_wingtip(3), lat, lon, alt, wgs84);
    [lat_right, lon_right, alt_right] = ned2geodetic(righ_wingtip(1), righ_wingtip(2), righ_wingtip(3), lat, lon, alt, wgs84);
    
    lats = [lat_nose, lat_left, lat_right];
    lons = [lon_nose, lon_left, lon_right];
    
    % Get the number of soundings
    num_soundings = length(sounding_buses);
    
    % Initialize variables for code generation
    T = zeros(num_soundings,3); % [nose, left, right]
    q = zeros(num_soundings,3);
    p = zeros(num_soundings,3);
    RH = zeros(num_soundings,3);
    vap_press = zeros(num_soundings,3);
    
    T_out = zeros(1, 3); % [nose, left, right]
    q_out = zeros(1, 3);
    p_out = zeros(1, 3);
    RH_out = zeros(1, 3);


    % Get the number of levels in the sounding data
    numLevels = length(sounding_buses(1).REPGPH);

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

    % Calculate distance to each updraft (only one distance because we use the closest updraft)
    dist_updrafts = zeros(num_updrafts,1);
    for i = 1:num_updrafts
        dist_updrafts(i) = updrafts{i}.distance_to(lat,lon);
    end

    % Find the nearest updraft
    min_dist = min(dist_updrafts);
    indices = find(dist_updrafts == min_dist);
    updraft_index = indices(1,1);

    % Round sample point heights to nearest integer
    alts = [alt_nose, alt_left, alt_right];
    rounded_alts = round([alt_nose, alt_left, alt_right]);

    % Concatenate the sounding data
    REPGPH = [sounding_buses(:).REPGPH];
    PRESS = [sounding_buses(:).PRESS];
    TEMP = [sounding_buses(:).TEMP];
    VAPPRESS = [sounding_buses(:).VAPPRESS];

    logical_mask_below = false(numLevels,num_soundings,3);
    logical_mask_above = false(numLevels,num_soundings,3);
    % Create logical mask for the heights below and above the aircraft height
    for k = 1:3
        logical_mask_below(:,:,k) = REPGPH < rounded_alts(k);
        logical_mask_above(:,:,k) = REPGPH >= rounded_alts(k);

        % Find indexes of the heights directly below and directly above the aircraft height
        logical_mask_below(:,:,k) = REPGPH == max(REPGPH.*logical_mask_below(:,:,k),[],1);
        REPGPH_temp = REPGPH;
        REPGPH_temp(~logical_mask_above(:,:,k)) = NaN;
        logical_mask_above(:,:,k) = REPGPH == min(REPGPH_temp.*logical_mask_above(:,:,k),[],1);
    end
        % Check which soundings contain the aircraft height and will be used
        used_soundings = any(logical_mask_above) & any(logical_mask_below);
    
        % Use only soundings in used_soundings
        logical_mask_below = logical_mask_below & used_soundings;
        logical_mask_above = logical_mask_above & used_soundings;

        % Check if no soundings contains the aircraft height
        if ~(any(used_soundings(:,:,1)) && any(used_soundings(:,:,2)) && ...
                any(used_soundings(:,:,3)))
            warning off backtrace
            warning('Aircraft height is not in sounding data');
            warning on backtrace
            return;
        end

        % Interpolate the values at index_below and index_above to the aircraft height
        % using linear interpolation
        for k = 1:3
            p(:,k) = PRESS(logical_mask_below(:,:,k)) + (PRESS(logical_mask_above(:,:,k)) - PRESS(logical_mask_below(:,:,k)))./(REPGPH(logical_mask_above(:,:,k)) - REPGPH(logical_mask_below(:,:,k))) .* (alts(k) - REPGPH(logical_mask_below(:,:,k)));
            T(:,k) = TEMP(logical_mask_below(:,:,k)) + (TEMP(logical_mask_above(:,:,k)) - TEMP(logical_mask_below(:,:,k)))./(REPGPH(logical_mask_above(:,:,k)) - REPGPH(logical_mask_below(:,:,k))) .* (alts(k) - REPGPH(logical_mask_below(:,:,k)));
            vap_press(:,k) = VAPPRESS(logical_mask_below(:,:,k)) + (VAPPRESS(logical_mask_above(:,:,k)) - VAPPRESS(logical_mask_below(:,:,k)))./(REPGPH(logical_mask_above(:,:,k)) - REPGPH(logical_mask_below(:,:,k))) .* (alts(k) - REPGPH(logical_mask_below(:,:,k)));   
        end
    % Compute the distance averaged pressure, temperature and specific humidity at that height

    % Compute the distance to each station from the aircraft
    dist = zeros(num_soundings,1);
    wgs84 = wgs84Ellipsoid();
    coder.extrinsic('distance');

    for i = 1:num_soundings
        dist(i) = distance(lat, lon, sounding_buses(i).lat, sounding_buses(i).lon, wgs84);
    end

    % Compute the weights for each soundings
    total_dist = sum(dist(used_soundings(:,:,1)'));
    if (num_soundings > 1)
        weights = 1 - (dist(used_soundings(:,:,1)')./total_dist);
    else
        weights = ones(num_soundings);
    end

    % Compute the weighted average
    p = weights' * p;
    T = weights' * T;
    vap_press = weights' * vap_press;

    % Compute the mixing ratio and specific humidity
    r = 0.622 * vap_press./(p - vap_press); % mixing ratio (kg water/kg dry air)
    q = r./(1 + r); % specific humidity (kg water/kg moist air)

    % Get the sounding's pressure, temperature and specific humidity at that height
    %p = sounding_data.PRESS(logical_mask,1);
    %T = sounding_data.TEMP(logical_mask,1);
    %vap_press = sounding_data.VAPPRESS(logical_mask,1);
    %r = 0.622 * vap_press/(p - vap_press); % mixing ratio (kg water/kg dry air)
    %q = r/(1 + r); % specific humidity (kg water/kg moist air)

    p_out(1,1:3) = p(1,1:3);
    T_out(1,1:3) = T(1,1:3);
    q_out(1,1:3) = q(1,1:3);

    % Add the updraft's potential temperature and specific humidity excess to the
    % sounding data's values
    for i = 1:3
        T_out(i) = T_out(i) + updrafts{updraft_index}.ptemp_diff(lats(i),lons(i));
        q_out(i) = q_out(i) + updrafts{updraft_index}.humidity_diff(lats(i),lons(i))/1000;
    end
    % Compute relative humidity
    r = q_out./(1 - q_out); % mixing ratio (kg water/kg dry air) after adding updraft's humidity excess
    e = p_out .* r./(0.622 + r) ./100; % vapor pressure (hPa) after adding updraft's humidity excess
    esat = 6.1094 .* exp(17.625 * (T_out - 273.15)./(T_out - 273.15 + 243.04)); % saturated vapor pressure hPa
    RH_out = e./esat;
    RH_out = RH_out(1,1:3) * 100;


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