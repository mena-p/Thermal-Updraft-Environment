% This script tests the methods of the Updraft class

clear
close all

% Initialize the updraft
updraft = Updraft (0,0,1000);

% Create meshgrid
dx = 0.04;
lat = linspace(updraft.latitude - dx,updraft.latitude + dx,100);
lon = linspace(updraft.longitude - dx,updraft.longitude + dx,100);
[lat, lon] = meshgrid(lat, lon);

% Test the elliptical_dist_to method
dist = zeros(size(lat));
for i = 1:size(lat,1)
    for j = 1:size(lat,2)        
        dist(i,j) = updraft.elliptical_dist_to(lat(i,j), lon(i,j));
    end
end

% Plot the distance
figure
surf(lat,lon,dist)
title('Elliptical distance to the updraft')
xlabel('Latitude')
ylabel('Longitude')
zlabel('Distance')
