function sounding_buses = create_bus(sounding_array)
% CREATE_BUS.M
% This function processes an array of sounding objects selected in the GUI 
% and creates an array of bus structures containing only some of the data.
% It is called by the sendo to model button callback function in the GUI.
%
% INPUT:
%   sounding_array - An array of sounding objects selected in the GUI
%
% OUTPUT:
%   sounding_buses - An array of bus structures, each containing the following fields:
%       lat        - Latitude of the station (degrees)
%       lon        - Longitude of the station (degrees)
%       numLevels  - Number of levels in the sounding data
%       zi         - Mixed layer height (meters)
%       LCL        - Lifted Condensation Level (meters)
%       REPGPH     - Reported geopotential height (meters)
%       PRESS      - Pressure (Pascals)
%       TEMP       - Temperature (Kelvin)
%       PTEMP      - Potential temperature (Kelvin)
%       VTEMP      - Virtual temperature (Kelvin)
%       VAPPRESS   - Vapor pressure (Pascals)
%       SATVAP     - Saturation vapor pressure (Pascals)
%       REPRH      - Reported relative humidity (Percent)

    % Initialize array to hold the busses
    sounding_buses = [];
    
    % For all sounding objects in the input array
    for i = 1:length(sounding_array)
        
        % Fill the bus elements with the data from the sounding object
        %new_bus.stationID = sounding_array(i).stationID;
        new_bus.lat = sounding_array(i).lat; % degrees
        new_bus.lon = sounding_array(i).lon; % degrees
        new_bus.numLevels = length(sounding_array(i).derived.TEMP); % Assuming numLevels is the length of TEMP array
        new_bus.zi = sounding_array(i).mixedLayerHeight; % meter
        new_bus.LCL = sounding_array(i).LCLheight; % meter
        new_bus.REPGPH = sounding_array(i).derived.REPGPH; % meter
        new_bus.PRESS = sounding_array(i).derived.PRESS; % Pa
        new_bus.TEMP = sounding_array(i).derived.TEMP/10; % K
        new_bus.PTEMP = sounding_array(i).derived.PTEMP/10; % K
        new_bus.VTEMP = sounding_array(i).derived.VTEMP/10; % K
        new_bus.VAPPRESS = sounding_array(i).derived.VAPPRESS/10; % Pa
        new_bus.SATVAP = sounding_array(i).derived.SATVAP/10; % Pa
        new_bus.REPRH = sounding_array(i).derived.REPRH/10; % Percent
        
        % Append the new bus to the array of busses
        sounding_buses = [sounding_buses, new_bus];
    end
    disp('Created array of sounding busses.')
end