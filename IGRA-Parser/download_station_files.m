function download_station_files(stationList)
% Downloads and processes station files from IGRA archive
%   This function takes a list of station structures, downloads the corresponding
%   data files from the IGRA archive, unzips them, and updates the cache for each station.

    for i = 1:size(stationList,1)
        station = stationList(i,:);
        url = strcat('https://www.ncei.noaa.gov/data/integrated-global-radiosonde-archive/access/derived-por/', station.ID, '-drvd.txt.zip');
        filename = strcat('IGRA-Parser/Stations/', station.ID, '-drvd.txt.zip');
        fprintf('Downloading file %s-drvd.txt.zip from IGRA archive...\n',station.ID);
        outfilename = websave(filename,url);
        unzip(outfilename,"IGRA-Parser/Stations/");
        delete(outfilename)

        fprintf('Downloaded file for station %s\n',station.ID);

        % Update or create cache for stations
        cacheFilename = strcat('IGRA-Parser/Cache/',station.ID, '-cache.mat');
        if ~isfile(cacheFilename)
            create_station_cache(station.ID);
        else
            update_station_cache(station.ID);
        end
        % Update lastUpdate in station.mat file
        load("IGRA-Parser/stations.mat");
        stations.lastUpdate(stations.ID == station.ID) = datetime('now','TimeZone','UTC');
        save("IGRA-Parser\stations.mat","stations");
        fprintf('Registered update in stations.mat\n\n');
    end
    fprintf('Finished downloading station files and updating cache.\n\n');
end

