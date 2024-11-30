function create_station_cache(stationID)
% Creates a cache for a given station. 
%
% This function creates a cache for a specified station by extracting
% sounding dates and line numbers from the derived parameter file for that
% station. The cache stores the line at which soundings for a specific day
% can be found. It is saved as a .mat file in the Cache folder.

    filename = fullfile('IGRA-Parser', 'Cache', strcat(stationID, '-cache.mat'));
    stationFilename = fullfile('IGRA-Parser', 'Stations', strcat(stationID, '-drvd.txt'));
    
    if ~isfile(stationFilename)
        error(strcat('There is no derived parameter file for station',...
            ' ', stationID, '. Download one first'))
        return
    end

    fprintf('Station %s not yet cached. Caching...\n', stationID);

    % Create a new cache
    cache = table('Size',[0 2],'VariableNames', {'date', 'line'}, 'VariableTypes', {'datetime', 'uint32'});
    % Set timezone to UTC
    cache.date.TimeZone = 'UTC';

    % Initialize line counter
    lineCounter = uint32(0);

    % Open corresponding station file and extract sounding dates and line numbers
    fileid = fopen(stationFilename);
    while(~feof(fileid))
        line = fgetl(fileid);
        lineCounter = lineCounter + 1;

        if strcmp(line(1),'#') % Header line
            % Date of sounding
            date = datetime(line(14:23),'InputFormat',...
            'yyyy MM dd','TimeZone','UTC');

            % If the date is not already in the cache, add it
            if ~any(cache.date == date)
                cache = [cache; {date, lineCounter}];
            end
        end
    end
    fclose(fileid);
    save(filename, 'cache');
    fprintf('Finished caching %s\n',stationID);
end
