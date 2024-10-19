% This function is used to plot the VPT data. The function takes a flight
% data structure and an array of updraft positions and plots the VPT data
% using the thermal model and virtual potential temperature functions. The
% function plots the VPT as the z coordinate, the other axes are in lat/lon.
% The function determines the size of the area to plot based on the flight 
% data.

function vptplot(flight,updraft_locations,sounding_buses)

% Create array of updrafts
updrafts = cell(length(updraft_locations),1);
for i = 1:length(updraft_locations)
    updrafts{i} = Updraft(updraft_locations(i,1),updraft_locations(i,2));
end

% Determine the area to plot
min_lat = min(flight.trajectory.lat.lat);
max_lat = max(flight.trajectory.lat.lat);
min_lon = min(flight.trajectory.lon.lon);
max_lon = max(flight.trajectory.lon.lon);

% Create a grid of lat/lon points
lat = linspace(min_lat,max_lat,300);
lon = linspace(min_lon,max_lon,300);
[LAT,LON] = meshgrid(lat,lon);
% Initialize the VPT array
VPT = zeros(size(LAT));

% Calculate the VPT for each point using the thermal model and vpt function
for i = 1:size(LAT,1)
    for j = 1:size(LAT,2)
        [T,~,p,RH] = thermal_model(lat(j),lon(i),1500,updrafts,sounding_buses);
        VPT(i,j) = virtual_potential_temperature(T,RH,p);
    end
end

% Plot the VPT data in a 2D plot
figure
plot = surf(LAT,LON,VPT);
xlabel('Latitude')
ylabel('Longitude')
zlabel('VPT')
title('Virtual Potential Temperature')
colorbar
set(plot,"linestyle","none")
view(0,90)
% Mark updraft locations
hold on
for i = 1:length(updraft_locations)
    plot3(updraft_locations(i,1),updraft_locations(i,2),500,'ro','MarkerSize',10)
end
hold off

end