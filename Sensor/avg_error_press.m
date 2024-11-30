function error = avg_error_press(b,d,sensorData,sounding_buses)
%   This function calculates the mean squared error between the pressure 
%   measurements from the sensor data and the pressure from 
%   the sounding data, adjusted by a constant offset and the dynamic
%   pressure. It is used to tune the sensor model in chapter 6.
%
%   Inputs:
%       b - offset.
%       d - dynamic pressure parameter.
%       sensorData - Structure with sensor data.
%       sounding_buses - Simulink bus with sounding data.
%
%   Outputs:
%       error - The mean squared error.   
    n = length(sensorData.time);
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
        p = sounding_buses.PRESS(logical_mask)/1000; % kPa
        T = sounding_buses.TEMP(logical_mask); % K
        measured_p = sensorData.pressure(i); % hPa
        rho = p/(0.2870*T); % kg/m^3
        p = p*10; % hPa
        p = p(1,1) + b + d * rho * v_squared; % e.q. 6-17 thesis
        err(i) = (p - measured_p)^2;
    end
    error = sum(err)/n;
end

