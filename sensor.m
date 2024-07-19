function [theta_v] = sensor(T,q,p)
% This function contains the sensor logic to compute the virtual potential
% temperature

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:   T       =   temperature measured by sensor (can differ from actual temperature), K
%           q       =   specific humidity measured by sensor (can differ from actual value), g_water/kg_air
%           p       =   pressure measure by sensor, Pa
%
% Outputs:  theta_v = virtual potential temperature
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

theta = T*(100000/p)^0.286;                                 % potential temperature
q = q/1000;                                                 % convert q to g_water/g_air (unitless)
r = q*(1-q);                                                % mixing ratio, unitless

theta_v = theta*(1+0.61*r);                                 % virtual potential temperature
end

