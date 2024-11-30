function error = avg_error_temp(tau, f, b, sensorData,sounding)
%   This function calculates the mean squared error between the 
%   temperature measurements from the sensor data and the temperature
%   from the sounding data, adjusted by a constant offset, the
%   thermal inertia, and the heat transfer in the tube.
%   It is used to tune the sensor model in chapter 6.
%
%   Inputs:
%       b - offset.
%       tau - thermal inertia.
%       f - heat transfer weighting factor.
%       sensorData - Structure with sensor data.
%       sounding_buses - Simulink bus with sounding data.
%
%   Outputs:
%       error - The mean squared error.   

    n = length(sensorData.time);
    T_aircraft = zeros(1,n);
    T_modeled = zeros(1,n);
    err = zeros(1,n);

    alt1 = sensorData.gps_altitude(1);
    idx1 = uint32(alt1 - sounding.REPGPH(1) + 1);
    T_aircraft(1) = sounding.TEMP(idx1);
    for i = 2:n
        alt = sensorData.gps_altitude(i);
        idx = uint32(alt - 418);
        T_air = sounding.TEMP(idx);
        T_aircraft(i) = (0.02/(tau+0.02))*T_air + (tau/(tau+0.02))*T_aircraft(i-1);
        T_modeled(i) = (1-f)*T_aircraft(i) + f*T_air +  + b; % eq. 6-8 thesis

        err(i) = (T_modeled(i) - (sensorData.temperature(i)+273.15))^2;
    end
    error = sum(err)/n;
end