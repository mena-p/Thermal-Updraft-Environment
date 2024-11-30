function purge_cache()
    % This function resets the cache and the lastUpdate field of all stations.
    % It is used when the cache and the lastUpdate field out of sync due to manual
    % changes in the cache folder or the stations.mat file. Don't change them manually!
    
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
