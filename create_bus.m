function sounding_buses = create_bus(sounding_array)

    % Initialize array to hold the busses
    sounding_buses = [];
    
    % For all sounding objects in the input array
    for i = 1:length(sounding_array)
        
        % Fill the bus elements with the data from the sounding object
        %new_bus.stationID = sounding_array(i).stationID;
        new_bus.lat = sounding_array(i).lat;
        new_bus.lon = sounding_array(i).lon;
        new_bus.numLevels = length(sounding_array(i).derived.TEMP); % Assuming numLevels is the length of TEMP array
        new_bus.zi = sounding_array(i).mixedLayerHeight;
        new_bus.LCL = sounding_array(i).LCLheight;
        new_bus.REPGPH = sounding_array(i).derived.REPGPH;
        new_bus.PRESS = sounding_array(i).derived.PRESS;
        new_bus.TEMP = sounding_array(i).derived.TEMP/10;
        new_bus.PTEMP = sounding_array(i).derived.PTEMP/10;
        new_bus.VTEMP = sounding_array(i).derived.VTEMP/10;
        new_bus.VAPPRESS = sounding_array(i).derived.VAPPRESS/10;
        new_bus.SATVAP = sounding_array(i).derived.SATVAP/10;
        new_bus.REPRH = sounding_array(i).derived.REPRH/10;
        
        % Append the new bus to the array of busses
        sounding_buses = [sounding_buses, new_bus];
    end
    disp('Created array of sounding busses.')
end