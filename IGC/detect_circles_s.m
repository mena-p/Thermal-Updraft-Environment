
clc
close all
[positions] = detect_thermals_igc(flight.trajectory);

% Extract latitude, longitude and altitude coordinates from the trajectory
traj_lat = flight.trajectory.lat.lat;
traj_lon = flight.trajectory.lon.lon;

% Plot trajectory
figure
g = geoplot(traj_lat, traj_lon, 'b-');
title('Aircraft Trajectory')
%legend('Aircraft Trajectory')

% Add stations to the plot
hold on
geoscatter(stations, "lat", "lon","Marker","^","MarkerEdgeColor","g")
hold off

% Set axis limits to fit the trajectory
geolimits([min(traj_lat) max(traj_lat)], [min(traj_lon) max(traj_lon)])

% Add circles to the plot
hold on
for i = 1:length(positions)
    geoplot(positions(i,1), positions(i,2), 'ro', 'MarkerSize', 10)
    %geoplot(positions(i,1), positions(i,2), 'r-', 'LineWidth', 2)
end
hold off

% Plot trajectory in 3d using geoplot3
g = geoglobe(uifigure);
geoplot3(g,traj_lat, traj_lon, flight.trajectory.alt.alt, 'b-');