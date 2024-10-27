% This script tests out two ways of extrapolating the linear profile of
% potential temperature into 2D space. The first method is to manually average the
% two profiles based on the angle the gliders makes with the updraft.
% The second method is to use the griddata function to interpolate 
% the values of potential temperature at any point in the updraft. 

close all

% Method 1: Manual averaging of the two profiles based on the angle of the glider
% Load coefficients of the linear profile of potential temperature
load("coeff_uw.mat");
load("coeff_cw.mat");

uw = coeff_uw(1,:);
cw = coeff_cw(1,:);

% Declare functions of potential temperature
ptemp_uw = @(r) uw(1) + uw(2)*cos(r*uw(6)) + uw(3)*sin(r*uw(6)) + uw(4)*cos(2*r*uw(6)) + uw(5)*sin(2*r*uw(6));
ptemp_cw = @(r) cw(1) + cw(2)*cos(r*cw(6)) + cw(3)*sin(r*cw(6)) + cw(4)*cos(2*r*cw(6)) + cw(5)*sin(2*r*cw(6));

% Define updraft radius, position, and orientation in degrees
radius = 600; % meters
pos = [0, 0]; % [x, y] (x is north, y is east)
ori = 0; % degrees (0 is north, 90 is east)


% Create grid of query points [xq,yq] centered at the updraft
[xq,yq] = meshgrid(pos(1)-radius*4:5:pos(1)+radius*4,pos(2)-radius*4:5:pos(2)+radius*4);

% Calculate the relative distance of each point in the grid to the updraft
r = sqrt((xq-pos(1)).^2 + (yq-pos(2)).^2);

% Calculate the angle of each point in the grid to the x-axis
tan = atan2d(yq-pos(2), xq-pos(1));
tan(tan < 0) = tan(tan < 0) + 360;

% Calculate the angle of each point in the grid to the updraft
theta = tan - ori;

% Calculate the potential temperature at each point in the grid
ptemp = cos(theta/180 *pi).^2 .*ptemp_uw(r./radius) + sin(theta./180 *pi).^2 .*ptemp_cw(r./radius);

% Calculate the weights of each profile based on the angle of the glider (for plotting only)
w_uw = cos(theta/180 *pi).^2;
w_cw = sin(theta/180 *pi).^2;

% % Plot the weights in the grid
% figure
% surf(xq,yq,w_uw, 'LineStyle','none')
% xlabel('x')
% ylabel('y')
% zlabel('w')
% title('Weight of the updraft profile')

% % Plot theta in the grid
% figure
% surf(xq,yq,theta, 'LineStyle','none')
% xlabel('x')
% ylabel('y')
% zlabel('tan')
% title('Angle of each point in the grid to the x-axis')

% % Plot ptemp_uw and ptemp_cw
% figure
% r = -r/radius:0.01:r/radius;
% plot(r, ptemp_uw(r), 'r')
% hold on
% plot(r, ptemp_cw(r), 'b')
% hold off
% xlabel('r')
% ylabel('ptemp')
% title('Potential temperature profiles')

% Plot the potential temperature in the grid
figure
surf(xq,yq,ptemp, 'LineStyle','none')
xlabel('x')
ylabel('y')
zlabel('ptemp')
title('Potential temperature in the updraft')

% Create a updraft object with the same properties as the updraft
updraft = Updraft(47.9724,11.796789);
updraft.gain = 1;
updraft.wind_dir = 0;

% Generate vector of sample latitudes and longitudes
lat = linspace(47.945243,47.999557,120);
lon = linspace(11.756576,11.837002,120);

% Create linspace out of the lat and lon vectors
[lat, lon] = meshgrid(lat, lon);

% Calculate the potential temperature difference at the same positions as the grid
ptemp_diff = zeros(size(lat));
humidity_diff = zeros(size(lat));
for i = 1:size(lat,1)
    for j = 1:size(lat,2)
        ptemp_diff(i,j) = updraft.ptemp_diff(lat(i,j),lon(i,j));
        humidity_diff(i,j) = updraft.humidity_diff(lat(i,j),lon(i,j));
    end
end

% Plot the potential temperature difference in the grid
figure
surf(lat,lon,ptemp_diff, 'LineStyle','none')
xlabel('x')
ylabel('y')
zlabel('ptemp_diff')
title('Potential temperature difference with perturbation')

% Plot the humidity difference in the grid
figure
surf(lat,lon,humidity_diff, 'LineStyle','none')
xlabel('x')
ylabel('y')
zlabel('hum_diff')
title('Specific humidity difference with perturbation')

%
% % Method 2: Interpolation of the two profiles using griddata %%%%%%%%%%%%%%%%%%%%%%%%
% % Get x and y values of the meshgrid separately
% x = xq(1,:)';
% y = yq(:,1);
% 
% % Evaluate the potential temperature at the x and y values
% ptemp_x = ptemp_uw(x./radius);
% ptemp_y = ptemp_cw(y./radius);
% 
% % Build vector for griddata function
% x_len = length(x);
% x = [x; zeros(length(y), 1)];
% y = [zeros(x_len, 1); y];
% ptemp = [ptemp_x; ptemp_y];
% 
% % Interpolate the values in ptemp to obtain the potential temperature at any point xq,yq in the updraft
% ptemp2 = griddata(x,y,ptemp,xq,yq,"linear");
% 
% % Plot the interpolated values and the original values as a line plot
% figure
% surf(xq,yq,ptemp2, 'LineStyle','none')
% xlabel('x')
% ylabel('y')
% zlabel('ptemp')
% title('Interpolated values of potential temperature in the updraft')