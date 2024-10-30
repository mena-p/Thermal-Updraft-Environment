function soundings = parse_derived_by_date(filename, date)
    % Usage: exampleOutput = parse_sounding('GMM00010868-drvd.txt','31.01.2019');
    % This function searches an IGRA derived parameter file containing
    % multiple soundings for a sounding on the given date and returns 
    % a sounding object with the sounding if it is found. 
    % The object contains information about the sounding, such
    % as date, time, location, inversion height, mixed layer depth, etc. 
    % and derived parameter values at each pressure level. Missing
    % flags in the measument data or headers are filled with NaN
    % and missing numerical values in the data are filled with NaN.
    % Find more about the dataset on https://www.ncei.noaa.gov/products/weather-balloon/integrated-global-radiosonde-archive
    tic()
    disp('Searching for soundings.')
    % Open the provided file
    file = fopen(filename, 'rt');
    if file == -1
        error('Cannot open file: %s', filename);
    end
    
    % Initialize output array
    soundings = [];

    % Set requested date's time zone
    requested_date = date;
    requested_date.TimeZone = 'UTC';
    
    % Read first line
    headerLine = fgetl(file);
    lineCounter = 1;
    
    while(headerLine(1) ~= '#') % find the first header
        headerLine = fgetl(file);
        lineCounter = lineCounter + 1;
    end

    while(ischar(headerLine)) % read until the end of the file
        % Parse the header line
        
        % date of measurement
        date = datetime(headerLine(14:23),'InputFormat',...
            'yyyy MM dd','TimeZone','UTC');

        % Get number of measurement lines
        numLines = str2double(headerLine(32:36));

        % Skip the measurement lines if the date is not the requested date
        if date < requested_date
            for i = 1:numLines+1
                headerLine = fgetl(file);
                lineCounter = lineCounter + 1;
            end
        elseif date == requested_date
            disp('Sounding found! Parsing...')

            % Create a new sounding object
            sounding = struct('stationID',NaN,...
                'date',NaN,...
                'time',NaN,...
                'releaseTime',NaN,...
                'numLevels',NaN,...
                'precipitableWater',NaN,...
                'inversionPressure',NaN,...
                'inversionHeight',NaN,...
                'inversionTempDiff',NaN,...
                'mixedLayerPressure',NaN,...
                'mixedLayerHeight',NaN,...
                'freezingPressure',NaN,...
                'freezingHeight',NaN,...
                'LCLpressure',NaN,...
                'LCLheight',NaN,...
                'LFCpressure',NaN,...
                'LFCheight',NaN,...
                'LNBpressure',NaN,...
                'LNBheight',NaN,...
                'liftedIndex',NaN,...
                'showalterIndex',NaN,...
                'kIndex',NaN,...
                'totalTotalsIndex',NaN,...
                'CAPE',NaN,...
                'CIN',NaN,...
                'derived',NaN);

            % Parse header information into sounding attributes. Some 
            % atributes are always available, some are not and need special
            % treatment.
    
            % These attributes are always available and can be taken directly:
            
            % date of measurement
            sounding.date = datetime(headerLine(14:23),'InputFormat',...
            'yyyy MM dd','TimeZone','UTC');

            % station ID
            sounding.stationID = headerLine(2:12);
    
            % number of measurement levels (= number of data records that
            % follow)
            sounding.numLevels = numLines;
    
           
    
            % These attributes might be missing in the header and need 
            % special treatment:
    
            % hour of sounding HH
            % might be missing completely (value equal to 99)
            time = headerLine(25:26);
            if ~strcmp(time, '99')
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
    
            % precipitable water between surface and 500hPa
            string = headerLine(38:43);
            if ~strcmp(string, '-99999')
                sounding.precipitableWater = str2double(string);
            end
    
            % inversion pressure
            invPressure = headerLine(44:49);
            if ~strcmp(invPressure, '-99999')
                sounding.inversionPressure = str2double(invPressure);
            end
    
            % inversion height
            invHgt = headerLine(50:55);
            if ~strcmp(invHgt, '-99999')
                sounding.inversionHeight = str2double(invHgt);
            end
    
            % inversion temperature difference
            tempDiff = headerLine(56:61);
            if ~strcmp(tempDiff, '-99999')
                sounding.inversionTempDiff = str2double(tempDiff);
            end
    
            % mixed layer top pressure
            press = headerLine(62:67);
            if ~strcmp(press, '-99999')
                sounding.mixedLayerPressure = str2double(press);
            end
    
            % mixed layer top height
            string = headerLine(68:73);
            if ~strcmp(string, '-99999')
                sounding.mixedLayerHeight = str2double(string);
            end
            
            % freezing level pressure
            string = headerLine(74:79);
            if ~strcmp(string, '-99999')
                sounding.freezingPressure = str2double(string);
            end
    
            % freezing level height
            string = headerLine(80:85);
            if ~strcmp(string, '-99999')
                sounding.freezingHeight = str2double(string);
            end
    
            % lifting condensation level pressure
            string = headerLine(86:91);
            if ~strcmp(string, '-99999')
                sounding.LCLpressure = str2double(string);
            end
    
            % lifting condensation level height
            string = headerLine(92:97);
            if ~strcmp(string, '-99999')
                sounding.LCLheight = str2double(string);
            end
    
            % level of free convection pressure
            string = headerLine(98:103);
            if ~strcmp(string, '-99999')
                sounding.LFCpressure = str2double(string);
            end
    
            % level of free convection height
            string = headerLine(104:109);
            if ~strcmp(string, '-99999')
                sounding.LFCheight = str2double(string);
            end
    
            % level of neutral buoyancy pressure
            string = headerLine(110:115);
            if ~strcmp(string, '-99999')
                sounding.LNBpressure = str2double(string);
            end
    
            % level of neutral buoyancy height
            string = headerLine(116:121);
            if ~strcmp(string, '-99999')
                sounding.LNBheight = str2double(string);
            end
    
            % lifted index
            string = headerLine(122:127);
            if ~strcmp(string, '-99999')
                sounding.liftedIndex = str2double(string);
            end
    
            % showalter index
            string = headerLine(128:133);
            if ~strcmp(string, '-99999')
                sounding.showalterIndex = str2double(string);
            end
    
            % k index
            string = headerLine(134:139);
            if ~strcmp(string, '-99999')
                sounding.kIndex = str2double(string);
            end
    
            % total totals index
            string = headerLine(140:145);
            if ~strcmp(string, '-99999')
                sounding.totalTotalsIndex = str2double(string);
            end
    
            % convective available potential energy
            string = headerLine(146:151);
            if ~strcmp(string, '-99999')
                sounding.CAPE = str2double(string);
            end
    
            % convective inhibition
            string = headerLine(152:157);
            if ~strcmp(string, '-99999')
                sounding.CIN = str2double(string);
            end
    
            % Get actual derived parameters. 
            % The next numLevel rows contain the actual data. The data is
            % stored into a table, and the table is stored as the attribute
            % 'derived' of the souding object. The data might contain missing 
            % numerical values, denoted by -9999. These are found and 
            % replaced by NaN.
    
            data = derived_to_table(filename, lineCounter+1,...
                lineCounter+sounding.numLevels);
            sounding.derived = data;

            % Append this sounding object to the output array.
            soundings = [soundings sounding];

            disp('Finished parsing.')
            for i = 1:numLines+1
                headerLine = fgetl(file);
                lineCounter = lineCounter + 1;
            end
        else
            disp("There are no more soundings at this date for this station.")
            fclose(file);
            toc()
            return
        end
    end
end