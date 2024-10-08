function error = avg_error_hum(c,sensorData,sounding_buses)
    n = 500000;
    err = zeros(1,n);
    for i = 1:n
        alt = sensorData.gps_altitude(i);

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
        RH = sounding_buses.REPRH(logical_mask);
        RH = RH(1,1) + c;
        measured_RH = sensorData.humidity(i);
        err(i) = sqrt((RH - measured_RH)^2);
    end
    error = sum(err)/n;
end

