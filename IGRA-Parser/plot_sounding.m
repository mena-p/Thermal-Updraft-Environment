function plot_sounding(reduced_sounding, max_height_multiplier)
% Plots the temperature and pressure profiles against geopotential 
% height.
%
% This function takes a reduced sounding data structure and plots the
% atmospheric variables (pressure, temperature, virtual temperature, 
% and potential temperature) against geopotential height. The y-axis
% limit is set to the mixed layer height multiplied by the 
% max_height_multiplier value.
%
% Inputs:
%   reduced_sounding - A data structure containing the reduced 
%                      sounding data. It should have the following
%                      fields:
%                      - derived.PRESS: Pressure (Pa)
%                      - derived.REPGPH: Geopotential height (m)
%                      - derived.TEMP: Temperature (K)
%                      - derived.VTEMP: Virtual temperature (K)
%                      - derived.PTEMP: Potential temperature (K)
%   max_height_multiplier - An optional scalar value to multiply 
%                           the mixed layer height to determine the
%                           y-axis limit. Default value is 1.2.
% Outputs:
%   None



% Check if the max_height_multiplier is provided
if nargin < 2
    max_height_multiplier = 1.2;
end

% Check if max_height_multiplier is a valid value
if max_height_multiplier <= 0
    error('Invalid max_height_multiplier value. Please provide a positive value.')
end

% Calculate the inversion layer height
mixed_layer_height = reduced_sounding.mixedLayerHeight/1000;

figure

subplot(3,1,1)
hold on
plot(reduced_sounding.derived.PRESS./100, ...
    reduced_sounding.derived.REPGPH./1000, 'r', 'DisplayName', 'Pressure')
xlabel('Pressure (Pa)')
ylabel('Geopotential Height (km)')
yline(mixed_layer_height, 'k--', 'DisplayName', 'zi')   
yline(reduced_sounding.LCLheight./1000, 'b--', 'DisplayName', 'LCL')
legend('Pressure', 'Mixed Layer Height', 'LCL')
ylim([0, max_height_multiplier*mixed_layer_height])


subplot(3,1,2)
hold on
plot(reduced_sounding.derived.TEMP./10, ...
    reduced_sounding.derived.REPGPH./1000, 'b', 'DisplayName', ...
    'Temperature')
plot(reduced_sounding.derived.VTEMP./10, ...
    reduced_sounding.derived.REPGPH./1000, 'm', ...
    'DisplayName', 'Virtual Temperature')
xlabel('Temperature (K)')
ylabel('Geopotential Height (km)')
yline(mixed_layer_height, 'k--', 'DisplayName', 'zi')
yline(reduced_sounding.LCLheight./1000, 'b--', 'DisplayName', 'LCL')
legend('Temperature', 'Virtual Temperature', 'Mixed Layer Height', 'LCL')
ylim([0, max_height_multiplier*mixed_layer_height])


subplot(3,1,3)
hold on
plot(reduced_sounding.derived.PTEMP./10,...
    reduced_sounding.derived.REPGPH./1000, 'g', 'DisplayName', ...
    'Potential Temperature')
xlabel('Potential Temperature (K)')
ylabel('Geopotential Height (km)') 
yline(mixed_layer_height, 'k--', 'DisplayName', 'zi')
yline(reduced_sounding.LCLheight./1000, 'b--', 'DisplayName', 'LCL')
legend('Potential Temperature', 'Mixed Layer Height', 'LCL')
ylim([0, max_height_multiplier*mixed_layer_height])

end