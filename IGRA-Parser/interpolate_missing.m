function interpolated_sounding = interpolate_missing(sounding)
    % interpolate_missing interpolates missing atmospheric parameters in a sounding object.
    % The function takes a sounding object as input and interpolates the missing values
    % for columns REPGPH, PRESS, TEMP, PTEMP, and VTEMP at 1-meter intervals of geopotential heights.
    % The interpolated values are then assigned to a new sounding object and returned as output.

    % Extract the columns REPGPH, PRESS, TEMP, PTEMP, and VTEMP
    repgph = sounding.derived.REPGPH;
    press = sounding.derived.PRESS;
    temp = sounding.derived.TEMP;
    ptemp = sounding.derived.PTEMP;
    vtemp = sounding.derived.VTEMP;
    
    % Create a new array of geopotential heights with 1 meter interval
    new_repgph = min(repgph):1:max(repgph);
    
    % Interpolate the values for each column at the new geopotential heights
    new_press = interp1(repgph, press, new_repgph);
    new_temp = interp1(repgph, temp, new_repgph);
    new_ptemp = interp1(repgph, ptemp, new_repgph);
    new_vtemp = interp1(repgph, vtemp, new_repgph);
    
    % Create a new sounding object with the original atmospheric parameters
    interpolated_sounding.mixedLayerHeight = sounding.mixedLayerHeight;
    interpolated_sounding.LCLheight = sounding.LCLheight;

    % Create a new table from new_temp, new_ptemp, new_vtemp, new_press, and new_repgph,
    % with the columns REPGPH, PRESS, TEMP, PTEMP, and VTEMP, and assign the new values
    % to the new table's fields.
    interpolated_sounding.derived = table(new_repgph', new_press', new_temp', new_ptemp', new_vtemp', ...
        'VariableNames', {'REPGPH', 'PRESS', 'TEMP', 'PTEMP', 'VTEMP'});
end
