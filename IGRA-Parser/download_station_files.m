function download_station_files(stations)
%DOWNLOAD_STATION_FILE Summary of this function goes here
%   Detailed explanation goes here
    for i = 1:size(stations,1)
        station = stations(i,:);
        url = strcat('https://www.ncei.noaa.gov/data/integrated-global-radiosonde-archive/access/derived-por/', station.code, '-drvd.txt.zip');
        filename = strcat('IGRA-Parser/soundings/', station.code, '-drvd.txt.zip');
        outfilename = websave(filename,url);
        unzip(outfilename,"IGRA-Parser/soundings/");
        delete(outfilename)
    end
end

