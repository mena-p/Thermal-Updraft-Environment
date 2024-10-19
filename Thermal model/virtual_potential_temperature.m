function vpt = virtual_potential_temperature(T, RH, p)
    % virtual_potential_temperature Calculate the virtual potential temperature.
    %
    %   vpt = virtual_potential_temperature(T, RH, P) computes the virtual 
    %   potential temperature given the temperature (T) in kelvin, relative 
    %   humidity (RH) in percentage, and pressure (P) in pascals.
    %
    %   The function uses the August-Roche-Magnus equation to calculate the 
    %   saturated vapor pressure.
    %
    %   Inputs:
    %       T  - temperature in kelvin
    %       RH - relative humidity in percentage
    %       P  - pressure in pascals
    %
    %   Outputs:
    %       vpt - virtual potential temperature in kelvin

        theta = T*(100000/p)^0.286; % potential temperature
        esat = 6.1094 * exp(17.625 * (T - 273.15)/(T - 273.15 + 243.04)); % saturated vapor pressure hPa
        e = RH * esat / 100; % vapor pressure hPa
        r = 0.622 * e/(p-e); % mixing ratio, unitless
        
        vpt = theta*(1+0.61*r); % virtual potential temperature in K
    end