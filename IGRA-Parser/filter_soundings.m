function filtered_soundings = filter_soundings(soundings)
    % Filter soundings based on the presence of the mixed layer height parameter.
    % This function takes an array of atmospheric sounding objects and returns
    % a filtered array containing only the soundings for which the inversion
    % height parameter is defined.

    % Initialize an empty array to store the filtered soundings
    filtered_soundings = [];
    
    % Iterate over each sounding in the input list
    for i = 1:length(soundings)
        sounding = soundings(i);
        
        % Check if the inversion height parameter is defined
        if ~isnan(sounding.mixedLayerHeight)
            % If defined, add the sounding to the filtered soundings array
            filtered_soundings = [filtered_soundings, sounding];
        end
    end
end
