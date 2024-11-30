function interpolated_sounding = interpolate_missing(sounding)
    % interpolate_missing interpolates missing data points in a sounding object
    % in a 1 meter interval.
    % The function takes a sounding object as input and outputs a new sounding
    % object with the missing data points interpolated. It was used in old versions
    % of the environment before interpolation was moved to the thermal_model function.

    % Create a new sounding object with the original atmospheric parameters, but no table
    interpolated_sounding = sounding;
    interpolated_sounding.derived = [];

    % Determine the number of columns in sounding.derived
    num_columns = size(sounding.derived, 2);
    
    % Create a new array of geopotential heights with 1 meter interval
    repgph = sounding.derived.REPGPH;
    new_repgph = (min(repgph):1:max(repgph))';
    
    % Initialize a new table to store the interpolated values
    new_table = table('Size', [length(new_repgph), num_columns], 'VariableTypes', repmat({'double'}, 1, num_columns), 'VariableNames', sounding.derived.Properties.VariableNames);
    
    % Interpolate the values for each column at the new geopotential heights
    for i = 1:num_columns
        new_table.(sounding.derived.Properties.VariableNames{i}) = interp1(repgph, sounding.derived.(sounding.derived.Properties.VariableNames{i}), new_repgph);
    end
    
    % Assign the interpolated table to the derived field of the new sounding object
    interpolated_sounding.derived = new_table;
    
    disp('Interpolated missing values in 1 meter intervals')

end
