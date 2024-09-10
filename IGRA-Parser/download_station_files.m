function download_station_files(stations)
%DOWNLOAD_STATION_FILE Summary of this function goes here
%   Detailed explanation goes here
    for i = 1:size(stations,1)
        station = stations(i,:);
        url = strcat('https://www.ncei.noaa.gov/data/integrated-global-radiosonde-archive/access/derived-por/', station.ID, '-drvd.txt.zip');
        filename = strcat('IGRA-Parser/soundings/', station.ID, '-drvd.txt.zip');
        fprintf('Downloading file %s-drvd.txt.zip from IGRA archive...\n',station.ID);
        outfilename = websave(filename,url);
        unzip(outfilename,"IGRA-Parser/soundings/");
        delete(outfilename)
    end
end

