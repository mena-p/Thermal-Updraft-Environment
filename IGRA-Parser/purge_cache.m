function purge_cache()
    % Delete all files in the cache folder
    cache_folder = fullfile('IGRA-Parser', 'Cache');
    if isfolder(cache_folder)
        delete(fullfile(cache_folder, '*.mat'));
    end

    % Reset the lastUpdate field of all stations
    load("IGRA-Parser/stations.mat","stations");
    stations.lastUpdate(1:end) = datetime('01.01.0000','TimeZone','UTC');

    % Save the updated stations
    save('IGRA-Parser/stations.mat','stations')
end
