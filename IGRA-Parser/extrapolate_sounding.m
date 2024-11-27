function sounding_out = extrapolate_sounding(sounding)
    % This function extrapolates the temperature of the sounding
    % above the mixed layer height zi, using the dry-adiabatic lapse rate.

    % Get the mixed layer height
    zi = sounding.mixedLayerHeight;
    
    if isnan(zi)
        sounding_out = sounding; 
        warning('At least one sounding does not have a mixed layer height. It might have been taken at night. Double check and pick another sounding if necessary. You can safely ignore this message.')
        return
    end
    % Get the temperature profile
    T = sounding.derived.TEMP;

    % Check the maximum height of the sounding
    max_height = max(sounding.derived.REPGPH);

    % Check if it is below the zi
    if max_height <= zi
        % The entire sounding is below the zi, no extrapolation needed
        sounding_out = sounding;
        return
    end

    % Get temperatures before zi
    T_below_zi = T(sounding.derived.REPGPH <= zi);

    % Get the geopotential heights before zi
    GPH_below_zi = sounding.derived.REPGPH(sounding.derived.REPGPH <= zi);

    % Get the last temperature and REPRH before zi
    Tzi = T_below_zi(end);
    GPHzi = GPH_below_zi(end);

    % Get the geopotential heights above zi to interpolate the temperature
    GPH_above_zi = sounding.derived.REPGPH(sounding.derived.REPGPH > zi);

    % Calculate the temperature above zi using the dry-adiabatic lapse rate
    T_above_zi = Tzi - 98*(GPH_above_zi - GPHzi)/1000; % unit is 10*K like in sounding.

    % Concatenate the temperatures
    T_extrapolated = [T_below_zi; T_above_zi];

    % Update the temperature profile
    sounding.derived.TEMP = T_extrapolated; % 10*K
    
    % Update potential temperature profile
    sounding.derived.PTEMP = T_extrapolated .* (100000./sounding.derived.PRESS).^(0.286); % 10*K

    % Return the updated sounding
    sounding_out = sounding;
end