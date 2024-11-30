function error = avg_error_hum(c, sensorData, sounding_buses)
%   This function calculates the mean squared error between the humidity 
%   measurements from the sensor data and the humidity from 
%   the sounding data, adjusted by a constant offset C. It is used to tune
%   the sensor model in chapter 6.
%
%   Inputs:
%       C - Offset to adjust the reference humidity values.
%       sensorData - Structure with sensor data.
%       sounding_buses - Simulink bus with sounding data.
%
%   Outputs:
%       error - The mean squared error.

    n = length(sensorData.time);
    err = zeros(1, n);
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
        RH = sounding_buses.REPRH(logical_mask); %sounding_buses(uint32(alt+1)) % to tune with flight data profile;
        RH = RH(1,1) + c; % e.q. 6-11 thesis
        measured_RH = sensorData.humidity(i);
        err(i) = (RH - measured_RH)^2;
    end
    error = sum(err)/n;
end

