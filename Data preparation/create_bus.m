function sounding_buses = create_bus(sounding_array)

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