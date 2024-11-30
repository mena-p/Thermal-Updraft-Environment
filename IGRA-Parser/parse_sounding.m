function soundings = parse_sounding(filename)
% Usage: exampleOutput = parse_sounding('GMM00010868-data.txt');
% This function parses an IGRA atmospheric sounding file containing
% multiple soundings and returns an array of ALL atmospheric sounding
% objects. Each object contains information about the sounding, such
% as date, time, location, etc. and the measured data itself. Missing
% flags in the measument data or headers are filled with NaN
% and missing numerical values in the data are filled with NaN.
% Find more about the dataset on https://www.ncei.noaa.gov/products/weather-balloon/integrated-global-radiosonde-archive

% Open the provided file
file = fopen(filename, 'rt');
if file == -1
    error('Cannot open file: %s', filename);
end

% Initialize output array
soundings = [];

% Read first line
headerLine = fgetl(file);
lineCounter = 1;

% Search for headers (check if line starts with '#')
while ischar(headerLine)  
    if headerLine(1) == '#' % header found
        
        % Create a new sounding object
        sounding = struct('stationID',NaN,...
            'date',NaN,...
            'time',NaN,...
            'releaseTime',NaN,...
            'numLevels',NaN,...
            'pressureSource',NaN, ...
            'nonpressureSource',NaN,...
            'lat', NaN,...
            'lon', NaN,...
            'data',NaN);

        % Parse header information into sounding attributes. Some 
        % atributes are always available, some are not and need special
        % treatment.

        % These attributes are always available and can be taken directly:

        % station ID
        sounding.stationID = headerLine(2:12);

        % date of measurement
        sounding.date = datetime(headerLine(14:23),'InputFormat',...
            'yyyy MM dd','TimeZone','UTC');

        % number of measurement levels (= number of data records that
        % follow)
        sounding.numLevels = str2double(headerLine(33:36));

        % latitude and longitude where sounding was taken
        sounding.lat = str2double(headerLine(56:62))/10000;
        sounding.lon = str2double(headerLine(64:71))/10000;

        % These attributes might be missing in the header and need 
        % special treatment:

        % pressure source
        % might be missing if a non-pressure source is used
        pressureSource = headerLine(38:45);
        if pressureSource == "        "
            sounding.pressureSource = NaN;
        else
            sounding.pressureSource = headerLine(38:45);
        end

        % non-pressure source 
        % might be missing if a pressure source is used
        nonpressureSource = headerLine(47:54);
        if nonpressureSource == "        "
            sounding.nonpressureSource = NaN;
        else
            sounding.pressureSource = headerLine(47:54);
        end

        % hour of sounding HH
        % might be missing completely (value equal to 99)
        time = headerLine(25:26);
        if strcmp(time, '99')
            sounding.time = NaN;
        else
            sounding.time = datetime(time,'InputFormat','HH',...
                'Format','HH:mm','TimeZone','UTC');
        end

        % release time of sounding HHmm 
        % might have missing minutes (XX99) or both hours and minutes
        % (9999)
        releaseTime = headerLine(28:31);
        if strcmp(releaseTime, '9999')
            sounding.releaseTime = NaN; % set undefined
        elseif strcmp(releaseTime(3:4), '99') % ignore minutes, take hour
            sounding.releaseTime = datetime(releaseTime(1:2),...
                'InputFormat','HH','Format','HH:mm','TimeZone','UTC');
        else
            sounding.releaseTime = datetime(releaseTime,...
                'InputFormat','HHmm','Format','HH:mm','TimeZone','UTC');
        end

        % Get actual sounding data. 
        % The next numLevel rows contain the actual data. The data is
        % stored into a table, and the table is stored as the attribute
        % 'data' of the souding object. The data might contain missing 
        % numerical values, denoted by -9999. These are found and 
        % replaced by NaN.

        data = sounding_to_table(filename, lineCounter+1,...
            lineCounter+sounding.numLevels);
        sounding.data = data;

        % Append this sounding object to the output array.
        soundings = [soundings sounding];
    end
    headerLine = fgetl(file);
    lineCounter = lineCounter + 1;
end

fclose(file);

end
