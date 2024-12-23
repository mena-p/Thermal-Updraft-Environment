function sensor_data = importSensorData(filename, dataLines)
%IMPORTFILE Import data from a text file
%  PEDROCSV = IMPORTFILE(FILENAME) reads data from text file FILENAME
%  for the default selection.  Returns the data as a table.
%
%  PEDROCSV = IMPORTFILE(FILE, DATALINES) reads data for the specified
%  row interval(s) of text file FILENAME. Specify DATALINES as a
%  positive scalar integer or a N-by-2 array of positive scalar integers
%  for dis-contiguous row intervals.
%
%  Example:
%  sensor_data = importSensorData("Raw data\pedro_csv.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 04-Oct-2024 14:38:13

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 11);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["time", "pressure_altitude", "gps_altitude", "vpt", "gps_x", "gps_y", "temperature", "humidity", "pressure", "velocity", "energy"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ImportErrorRule = "omitrow";
opts.MissingRule = "omitrow";
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "time", "InputFormat", "yyyy-MM-dd HH:mm:ss.SSS", "DatetimeFormat", "preserveinput");

% Import the data
sensor_data = readtable(filename, opts);

end