function sounding = remove_values_above(sounding, max_height)
    % Check if max_height is a factor or a direct height value
    if max_height < 50
        % If max_height is a factor, multiply it by mixedLayerHeight
        max_height = max_height * sounding.mixedLayerHeight;
        disp('max_height interpreted as a factor');
    else
        disp('max_height interpreted as a direct height value');
    end
    
    % Remove all rows of the table in reduced_sounding.derived that
    % have a geopotential height REPGPH greater than max_height.
    sounding.derived(sounding.derived.REPGPH > max_height, :) = [];
