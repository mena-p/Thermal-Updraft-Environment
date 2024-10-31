function update_station_cache(stationID)
% Updates the cache for a given station.
% 
% This function checks if the cache file and the derived parameter file for 
% the specified station exist. If they do, it updates the cache with new 
% sounding data from the derived parameter file.
    
    filename = fullfile('IGRA-Parser', 'Cache', strcat(stationID, '-cache.mat'));
    stationFilename = fullfile('IGRA-Parser', 'Stations', strcat(stationID, '-drvd.txt'));

    % Check if the station cache exists
    if ~isfile(filename)
        error(strcat('There is no cache file for station ',...
            stationID, '. Create one first'))
        return
    end

    % Check if the derived parameter file exists
    if ~isfile(stationFilename)
        error(strcat('There is no derived parameter file for station ',...
            stationID, '. Download one first'))
        return
    end

    fprintf('Station %s is already cached. Updating cache...\n', stationID);

    % If cache exists, open it
    load(filename, 'cache');

    % Get line of most recent sounding in cache
    lastLine = cache.line(cache.date == max(cache.date));

    % Open corresponding station file at lastLine and extract sounding dates and line numbers
    fileid = fopen(stationFilename);

    % Move to cursor to lastLine
    line = textscan(fileid, '%s', 1, 'delimiter', '\n', 'headerlines', lastLine-1);
    lineCounter = lastLine;

    while(~feof(fileid))
        % Read next line
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
    save(filename, 'cache');
    fclose(fileid);
    fprintf('Finished caching %s\n',stationID);
end