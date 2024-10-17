function error = avg_error_press(c,d,sensorData,sounding_buses)
    n = 20001; % tune on first 400 seconds, max 15km from aerodrome
    err = zeros(1,n);
    for i = 1:n
        alt = sensorData.gps_altitude(i);
        v_squared = sensorData.velocity(i).^2;
        % Round aircraft height to nearest integer
        alt = round(alt);
        alt_top = alt + 0.01;
        alt_bottom = alt - 0.01;

        numLevels = sounding_buses.numLevels;
        logical_mask = false(numLevels,1);
        used_soundings = false(1,1);

        % Initialize logical mask (1 if aircraft height is in sounding data, 0 otherwise)
        logical_mask = (sounding_buses.REPGPH <= alt_top & sounding_buses.REPGPH >= alt_bottom);
        % Check if no soundings contains the aircraft height
        if ~any(logical_mask)
            warning off backtrace
            warning('Aircraft height is not in sounding data');
            warning on backtrace
            return;
        end
        p = sounding_buses.PRESS(logical_mask)/100;
        p = p(1,1) + c + d * v_squared;
        measured_p = sensorData.pressure(i);
        err(i) = sqrt((p - measured_p)^2);
    end
    error = sum(err)/n;
end

