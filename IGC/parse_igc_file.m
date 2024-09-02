function [flight,name] = parse_igc_file(filepath)
%PARSE_IGC_F Parses an IGC file and extracts metadata and trajectory.
%   Detailed explanation goes here
% Open the igc file

disp('Parsing IGC file. Please wait...')
fid = fopen(filepath);
flag = 1;

% Create a timetalbe to store the data
trajectory.lat = timetable;
trajectory.lon = timetable;
trajectory.alt = timetable;

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
            prev_time = datetime(line(2:7), 'InputFormat', 'HHmmss','TimeZone','UTC');
            flag = 0;
        end

        % Extract the duration, latitude, longitude and altitude (DDMMmmm,DDDMMmmm,AAAAA)
        time = datetime(line(2:7), 'InputFormat', 'HHmmss','TimeZone','UTC');
        duration = time - prev_time;
        prev_time = time;
        lat = str2double(line(8:9)) + str2double(line(10:14))/60000;
        lon = str2double(line(16:18)) + str2double(line(19:23))/60000;
        if line(25) == 'A'
            alt = str2double(line(31:35));
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
        
        % Append the data to the timetable
        trajectory.lat = [trajectory.lat; timetable(duration, lat)];
        trajectory.lon = [trajectory.lon; timetable(duration, lon)];
        trajectory.alt = [trajectory.alt; timetable(duration, alt)];
        
    end
end

% Close the igc file
fclose(fid);

% Store the data in a structure
flight = struct('date', date, 'pilot', pilot, 'glider', glider, 'registration', registration, 'trajectory', trajectory);
name = strcat(string(flight.date), '_', flight.pilot);
disp('IGC file parsed successfully.')
end

