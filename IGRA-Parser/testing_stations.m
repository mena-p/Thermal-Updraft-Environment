close all

% Load stations data from the stations.mat file
load('stations.mat');
%load('Flights/29-Jul-2024_Schlautmann Nils.mat');

stations = find_nearby_stations(flight,stations,200000);

% Download soundings for the selected stations
%download_station_files(stations);

% Search downloaded files for soundings on the flight date
% soundings = [];
% for i = 1:size(stations,1)
%     station = stations(i,:);
%     filename = strcat('IGRA-Parser/soundings/', station.code, '-drvd.txt');
%     found = parse_derived_by_date(filename, flight.date);
%     soundings = [soundings, found];
% end

% Plot trajectory and stations
figure
geoplot(flight.trajectory.lat.lat, flight.trajectory.lon.lon, 'b-')
hold on
geoscatter([stations.lat], [stations.lon], 'r*')
% voronoi([stations.lat], [stations.lon]);
hold off



