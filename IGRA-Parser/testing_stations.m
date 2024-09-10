

% Load stations data from the stations.mat file
load('stations.mat');
%load('Flights/29-Jul-2024_Schlautmann Nils.mat');

active_stations = find_active_stations(flight,stations,200000);

nearest_stations = find_nearest_stations(flight,active_stations);
% Download soundings for the selected stations
%download_station_files(nearest_stations);

% Search downloaded files for soundings on the flight date
% soundings = [];
% for i = 1:size(stations,1)
%     station = stations(i,:);
%     filename = strcat('IGRA-Parser/soundings/', station.ID, '-drvd.txt');
%     found = parse_derived_by_date(filename, flight.date);
%     soundings = [soundings, found];
% end

% Plot trajectory and stations
figure
geoplot(flight.trajectory.lat.lat, flight.trajectory.lon.lon, 'b-')
hold on
geoscatter([active_stations.lat], [active_stations.lon], 'r*')
% voronoi([stations.lat], [stations.lon]);
hold off



