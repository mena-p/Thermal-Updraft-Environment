% This script tests out ways of extrapolating the 1D profile of
% the thermal into 2D space. The first method is to manually average the
% two profiles based on the angle the gliders makes with the updraft.
% The second method is to use the griddata function to interpolate 
% the values of potential temperature at any point in the updraft. Linear,
% quadratic, cubic, natural... interpolation were tested. Plots
% are generated for the thesis

close all
clear

% Plot colors
c = colormap('sky');
test = [c(:,3) c(:,2) c(:,1)];
color1 = [252 223 176];
color2 = [255 165 0];
color3 = [242 91 26];

r = [linspace(color1(1),color2(1),128)';linspace(color2(1),color3(1),128)']./255;
g = [linspace(color1(2),color2(2),128)';linspace(color2(2),color3(2),128)']./255;
b = [linspace(color1(3),color2(3),128)';linspace(color2(3),color3(3),128)']./255;
colors = [r g b];
map = colormap(colors);
% Method 1: using custom interpolation
% Create a updraft object with the same properties as the updraft
updraft = Updraft(47.9724,11.796789,1000);
updraft.gain = 1;
updraft.wind_dir = 0;

dx = 0.01;
% Generate vector of sample latitudes and longitudes
lat = linspace(updraft.latitude - dx,updraft.latitude + dx,240);
lon = linspace(updraft.longitude - dx,updraft.longitude + dx,240);

% Create linspace out of the lat and lon vectors
[lat, lon] = meshgrid(lat, lon);

% Calculate the potential temperature difference at the same positions as the grid
ptemp_diff = zeros(size(lat));
humidity_diff = zeros(size(lat));
ramp = zeros(size(lat));
for i = 1:size(lat,1)
    for j = 1:size(lat,2)
        ptemp_diff(i,j) = updraft.ptemp_diff(lat(i,j),lon(i,j));
        humidity_diff(i,j) = updraft.humidity_diff(lat(i,j),lon(i,j)); 
        
        dist = updraft.elliptical_dist_to(lat(i,j), lon(i,j));
            if dist > 1 && dist <= 3
                ramp(i,j) = (1.5 - 0.5 * dist);	
            elseif dist > 3
                ramp(i,j) = 0;
            else
                ramp(i,j) = 1;
            end

    end
end

%% Plots
close all
centerLat = updraft.latitude;
centerLon = updraft.longitude;
delta = 0.005;
lowLon = centerLon - delta;
highLon = centerLon + delta;
lowLat = centerLat - delta;
highLat = centerLat + delta;

% Plot the potential temperature difference in the grid
figure
surf(lat,lon,ptemp_diff, 'LineStyle','none')
xlabel('lat')
ylabel('lon')
ylim([lowLon highLon])
xlim([lowLat highLat])
zlabel('\Delta\theta [K]')
title('Potential Temperature Difference')
a = colorbar;
a.Label.String  = '\Delta\theta [K]';
colormap(map);
%saveas(gcf,'Images/Thermal model/thermal_ptemp_2d','png')

% Plot the humidity difference in the grid
figure
surf(lat,lon,humidity_diff, 'LineStyle','none')
xlabel('lat')
ylabel('lon')
ylim([lowLon highLon])
xlim([lowLat highLat])
zlabel('\Deltaq [g/kg]')
title('Specific Humidity Difference')
b = colorbar;
b.Label.String = '\Deltaq [g/kg]';
colormap("sky");
%saveas(gcf,'Images/Thermal model/thermal_hum_2d','png')

% Plot the ramp in the grid
figure
surf(lat,lon,ramp, 'LineStyle','none')
xlabel('lat')
ylabel('lon')
ylim([lowLon highLon])
xlim([lowLat highLat])
zlabel('Scaling Factor [-]')
title('Scaling Function')
d = colorbar;
d.Label.String  = 'Scaling Factor [-]';
colormap("gray")
%saveas(gcf,'Images/Thermal model/thermal_scaling_function_2d','png')



%% Method 2: Interpolation of the two profiles using griddata %%%%%%%%%%%%%%%%%%%%%%%%
% Get lat and lon values of the meshgrid separately

load("coeff_cw.mat")
load("coeff_uw.mat")
radius = 600;
[xq,yq] = meshgrid(-radius:5:radius,-radius:5:radius);

ptemp_uw = @ (rel_dist) coeff_uw(1,1) + ...
        coeff_uw(1,2)*cos(rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,3)*sin(rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,4)*cos(2*rel_dist*coeff_uw(1,18)) ...
        + coeff_uw(1,5)*sin(2*rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,6)*cos(3*rel_dist*coeff_uw(1,18)) ...
        + coeff_uw(1,7)*sin(3*rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,8)*cos(4*rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,9)*sin(4*rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,10)*cos(5*rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,11)*sin(5*rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,12)*cos(6*rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,13)*sin(6*rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,14)*cos(7*rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,15)*sin(7*rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,16)*cos(8*rel_dist*coeff_uw(1,18))...
        + coeff_uw(1,17)*sin(8*rel_dist*coeff_uw(1,18));

ptemp_cw = @ (rel_dist) coeff_cw(1,1) + ...
        coeff_cw(1,2)*cos(rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,3)*sin(rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,4)*cos(2*rel_dist*coeff_cw(1,18)) ...
        + coeff_cw(1,5)*sin(2*rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,6)*cos(3*rel_dist*coeff_cw(1,18)) ...
        + coeff_cw(1,7)*sin(3*rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,8)*cos(4*rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,9)*sin(4*rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,10)*cos(5*rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,11)*sin(5*rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,12)*cos(6*rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,13)*sin(6*rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,14)*cos(7*rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,15)*sin(7*rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,16)*cos(8*rel_dist*coeff_cw(1,18))...
        + coeff_cw(1,17)*sin(8*rel_dist*coeff_cw(1,18));

hum_uw = @ (rel_dist) coeff_uw(2,1) + ...
        coeff_uw(2,2)*cos(rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,3)*sin(rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,4)*cos(2*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,5)*sin(2*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,6)*cos(3*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,7)*sin(3*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,8)*cos(4*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,9)*sin(4*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,10)*cos(5*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,11)*sin(5*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,12)*cos(6*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,13)*sin(6*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,14)*cos(7*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,15)*sin(7*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,16)*cos(8*rel_dist*coeff_uw(2,18))...
        + coeff_uw(2,17)*sin(8*rel_dist*coeff_uw(2,18));

hum_cw = @ (rel_dist) coeff_cw(2,1) + ...
        coeff_cw(2,2)*cos(rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,3)*sin(rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,4)*cos(2*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,5)*sin(2*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,6)*cos(3*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,7)*sin(3*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,8)*cos(4*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,9)*sin(4*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,10)*cos(5*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,11)*sin(5*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,12)*cos(6*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,13)*sin(6*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,14)*cos(7*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,15)*sin(7*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,16)*cos(8*rel_dist*coeff_cw(2,18))...
        + coeff_cw(2,17)*sin(8*rel_dist*coeff_cw(2,18));

lats = xq(1,:)';
lons = yq(:,1);

% Evaluate the potential temperature at the x and y values
ptemp_x = ptemp_uw(lats./updraft.radius_uw);
ptemp_y = ptemp_cw(lons./updraft.radius_cw);

% Build vector for griddata function
x_len = length(lats);
lats = [lats; zeros(length(lons), 1)];
lons = [zeros(x_len, 1); lons];
ptemp = [ptemp_x; ptemp_y];

% Interpolate the values in ptemp to obtain the potential temperature at any point xq,yq in the updraft
ptemp2 = griddata(lats,lons,ptemp,xq,yq,"linear"); % linear, cubic, natural, or nearest

% Plot the interpolated values
figure
surf(xq,yq,ptemp2, 'LineStyle','none')
xlabel('x')
ylabel('y')
zlabel('ptemp')
title('Linearly Interpolated Potential Temperature')
zlabel('\Delta\theta [K]')
colorbar
colormap(map);