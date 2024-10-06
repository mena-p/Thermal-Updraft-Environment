function error = avg_error_f(tau, f,sensorData)
    if f > 1
        f = 1;
    elseif f < 0
        f = 0;
    end
    n = 50000;
    T_aircraft = zeros(1,n);
    T_modeled = zeros(1,n);
    err = zeros(1,n);

    T_aircraft(1) = 292.130400000000;
    for i = 2:n
        T_air = 300.9147 - 9.8 * (sensorData.gps_altitude(i) - 385)/1000;
        T_aircraft(i) = T_aircraft(i-1) + 0.02/(tau+0.02) * (T_air - T_aircraft(i-1));
        T_modeled(i) = T_air*(1-f) + f*T_aircraft(i);

        err(i) = sqrt((T_modeled(i) - (sensorData.temperature(i)+273.15))^2);
    end
    error = sum(err)/n;
end