function [flight,name] = parse_igc_file(filepath)
% Parses an IGC file and extracts metadata and trajectory.
%   Detailed explanation goes here

% Open the igc file
disp('Parsing IGC file. Please wait...')
fid = fopen(filepath);
flag = 1;

% Create a timetable to store the data
% Create vectors to store the data
durations = [];
latitudes = [];
longitudes = [];
altitudes = [];
press_altitudes = [];


% Loop through the file and extract the data
while ~feof(fid)
    % Read the next line
    line = fgetl(fid);
    
    % Check if the line contains the date
    if contains(line, 'HFDTE')
        % Extract the date in UTC
        date = datetime([line(11:16)], 'InputFormat', 'ddMMyy','TimeZone','UTC');
    end
    
    % Check if the line contains the pilot's name
    if contains(line, 'PILOT')
        % Extract the pilot's name
        pilot = line(12:end);
    end
    
    % Check if the line contains the glider type
    if contains(line, 'GLIDERTYPE')
        % Extract the glider type
        glider = line(17:end);
    end
    
    % Check if the line contains the registration
    if contains(line, 'GLIDERID')
        % Extract the registration
        registration = line(15:end);
    end
    
    % Check if the line contains the latitude, longitude and altitude
    if startsWith(line, 'B')

        if flag == 1
            first_time = datetime(line(2:7), 'InputFormat', 'HHmmss','TimeZone','UTC');
            flag = 0;
        end

        % Extract the duration, latitude, longitude and altitude (DDMMmmm,DDDMMmmm,AAAAA)
        time = datetime(line(2:7), 'InputFormat', 'HHmmss','TimeZone','UTC');
        sec = time - first_time;
        sec.Format = 's';
        lat = str2double(line(8:9)) + str2double(line(10:14))/60000;
        lon = str2double(line(16:18)) + str2double(line(19:23))/60000;
        if line(25) == 'A'
            alt = str2double(line(31:35));
            press_alt = str2double(line(26:30));
        else
            % Skip the line if the altitude is not available
            continue
        end

        if line(15) == 'S'
            lat = -lat;
        end
        if line(24) == 'W'
            lon = -lon;
        end
        
        % Append data to the arrays
        latitudes = [latitudes; lat];
        longitudes = [longitudes; lon];
        altitudes = [altitudes; alt];
        press_altitudes = [press_altitudes; press_alt];
        durations = [durations; sec];
        
    end
end

% Create the trajectory timetables
lat = latitudes;
lon = longitudes;
alt = altitudes;
press_alt = press_altitudes;
trajectory.lat = timetable(durations,lat);
trajectory.lon = timetable(durations,lon);
trajectory.alt = timetable(durations,alt);
trajectory.press_alt = timetable(durations,press_alt);

% Close the igc file
fclose(fid);

% Store the data in a structure
flight = struct('date', date, 'pilot', pilot, 'glider', glider, 'registration', registration, 'trajectory', trajectory);
name = strcat(string(flight.date), '_', flight.pilot);
disp('IGC file parsed successfully.')
end