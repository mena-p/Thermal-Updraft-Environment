%% Thermal model validation
% The thermal + (temperature and humidity) sensor models are run twice for 
% a sections of the flight where the glider encountered a thermal. 
% One simulation has a virtual
% thermal placed at the location of the real thermal, and the other does
% not. The correlations of temperature and humidity between both runs and
% the actual measured values are compared. The simulations with the
% thermal has a larger corelation. This script test the 4 thermals closest
% to the sounding station. To choose which thermal should be testes,
% uncomment the lines defining the ascent (%% Choose ascent) and the
% corresponding updraft (%% Initialize updraft). Your
% results might vary slightly due to the randomness added to the thermal
% structure at initialization. Still, an increase in the correlation was
% consistently present across multiple runs of the same ascents.

clear
close all

% Load data
sensorData = importSensorData('pedro_csv.csv');
load("sounding_buses.mat","sounding_buses");
latitude = sensorData.gps_y/111000;
longitude = sensorData.gps_x/111000;
humidity = sensorData.humidity;
temperature = sensorData.temperature;
altitude = sensorData.gps_altitude;

%% Choose ascent
descent = 46151:1:46151+19401;
 ascent = 46151+19401:1:46151+27551; % Ascent 1
% ascent = 11500:1:19500; % Ascent 2
% ascent = 37000:1:46500; % Ascent 3
% ascent = 92400:1:100600; % Ascent 4

% Plot ascent trajectory
close all
figure
%geoplot(latitude,longitude);
%hold on
geoplot(latitude(ascent),longitude(ascent));

%% Get trajectory data for ascent portion
dataAscent = sensorData(ascent,:);
alt_ascent = dataAscent.gps_altitude;
lat_ascent = dataAscent.gps_y/111000;
lon_ascent = dataAscent.gps_x/111000;
humidity_ascent = dataAscent.humidity;
temp_ascent = dataAscent.temperature + 273.15;

%% Initialize updraft
close all
 updraft = Updraft(49.0247,12.6251,1600); % Ascent 1
% updraft = Updraft(49.2507,12.3636,1600); % Ascent 2
% updraft = Updraft(49.1517,12.486,1600); % Ascent 3
% updraft = Updraft(48.9585,12.8003,1600); % Ascent 4
updraft.gain = 1; % Set the gain to one to remove variability

% Initialize dummy updraft
dummyUpdraft = Updraft(0,0, 100); % Dummy updraft used for the calculation
                                  % without updrafts

% Size of iteration
n = size(alt_ascent,1);

%% Plot trajectory and thermals
close all
figure
geoplot(lat_ascent,lon_ascent)
hold on
geoscatter(updraft.latitude,updraft.longitude,'r*')
title('Flight Segment')
legend('Trajectory','Thermal')
%saveas(gcf,'Images/Validation/Examplary trajectory used in the validation.png','png')

%% Pre-allocate arrays
Twith = zeros(n,1);
Twithout = zeros(n,1);
Pwith = zeros(n,1);
Pwithout = zeros(n,1);
RHwith = zeros(n,1);
RHwithout = zeros(n,1);
T_aircraft1 = zeros(n,1);
T_aircraft2 = zeros(n,1);

% Get starting value for aircraft temperature
[T,~,~,~] = thermal_model(lat_ascent(1),lon_ascent(1),alt_ascent(1),[0 0 0],{updraft},sounding_buses);
T_aircraft1(1) = T(1); % output of thermal model with thermal for i = 1
[T,~,~,~] = thermal_model(lat_ascent(1),lon_ascent(1),alt_ascent(1),[0 0 0],{dummyUpdraft},sounding_buses);
T_aircraft2(1) = T(1); % output of thermal model without thermal for i = 1
% Sensor parameters (derived in the tuneSensors script)
f = 0;
tau = 170.02;
b = 5.8238;
c = -20.439;
%% Get temp/hum predicted by model with and without thermals
for i = 2:n

    % with updraft
    [T,~,~,RH] = thermal_model(lat_ascent(i),lon_ascent(i),alt_ascent(i),[0 0 0],{updraft},sounding_buses);
    T_air = T(1);
    RHwith(i) = RH(1) + c;
    T_aircraft1(i) = (0.02/(tau+0.02))*T_air + (tau/(tau+0.02))*T_aircraft1(i-1);
    Twith(i) = (1-f)*T_aircraft1(i) + f*T_air +  + b; % eq. 6-8 thesis

    % without updraft
    [T,~,~,RH] = thermal_model(lat_ascent(i),lon_ascent(i),alt_ascent(i),[0 0 0],{dummyUpdraft},sounding_buses);
    T_air = T(1);
    RHwithout(i) = RH(1) + c;
    T_aircraft2(i) = (0.02/(tau+0.02))*T_air + (tau/(tau+0.02))*T_aircraft2(i-1);
    Twithout(i) = (1-f)*T_aircraft2(i) + f*T_air +  + b; % eq. 6-8 thesis
end

%% Plots
%  RH from the ascent and RH with and without updraft
close all
figure
plot(dataAscent.time,humidity_ascent)
hold on
plot(dataAscent.time(2:end),RHwith(2:end))
plot(dataAscent.time(2:end),RHwithout(2:end))
legend('Measured','With updraft','Without updraft')
xlabel('Time')
ylabel('Humidity (%)')
title('Humidity from ascent and RH with and without updraft')
% Same thing for temperature
figure
plot(dataAscent.time,temp_ascent)
hold on
plot(dataAscent.time(2:end),Twith(2:end))
plot(dataAscent.time(2:end),Twithout(2:end))
legend('Measured','With updraft','Without updraft')
xlabel('Time')
ylabel('Temperature [K]')
title('Temperature from ascent and RH with and without updraft')


% Compute correlation coefficients between measured humidity and modelled
% humidity with and without updraft
corr_RHwith = corrcoef(humidity_ascent(2:end),RHwith(2:end));
corr_RHwithout = corrcoef(humidity_ascent(2:end),RHwithout(2:end));

% Same thing for temperature
corr_Twith = corrcoef(temp_ascent(2:end),Twith(2:end));
corr_Twithout = corrcoef(temp_ascent(2:end),Twithout(2:end));

% Results:  Temp        Hum
% Ascent 1: 0.0095 and 0.0036 increase
% Ascent 2: 0.0001 and 0.0027 increase
% Ascent 3: 0.0073 and 0.0173 increase
% Ascent 4:-0.0002 and 0.0089 difference
% Six runs for each ascent were made in total, results from the last run 
% are shown

%% Qualitative analysis
% Colormap for plots
color1 = [252 252 252];
color2 = [255 165 0];
color3 = [242 91 26];
r = [linspace(color1(1),color2(1),128)';linspace(color2(1),color3(1),128)']./255;
g = [linspace(color1(2),color2(2),128)';linspace(color2(2),color3(2),128)']./255;
b = [linspace(color1(3),color2(3),128)';linspace(color2(3),color3(3),128)']./255;
colors = [r g b];
map = colormap(colors);

close all
sounding = sounding_buses(1);

%% Single thermal
updrafta = Updraft(49.0247,12.6251,1600); 
updrafta.gain = 1; % Set the gain to one to remove variability
updrafta.wind_dir = 0;

% Compute vpt field (single thermal)
[vpt,lat_grid,lon_grid] = compute_vpt_field(sounding,{updrafta},300);

%% Cloud street (multiple thermals in s straight line)
% Define straight line of thermals
lons = 12.6250:0.01:12.7000;

% Define updrafts
updrafts = cell(1,length(lons));
for i = 1:length(lons)
    updraft = Updraft(49.0247+0.01*rand(1),lons(i),1600);
    updraft.gain = 1;
    updraft.wind_dir = 70 + 40*rand(1);
    updrafts{i} = updraft;
end

%% Compute vpt field (cloud street)
[vpt1,lat_grid1,lon_grid1] = compute_vpt_field(sounding,updrafts,500);

%% Plot vpt field and thermal radius
% Create ellipse with the size of the thermal
rx = updrafta.radius_uw; % semi-major axis (aligned with alpha)
ry = updrafta.radius_cw; % semi-minor axis
alpha = updrafta.wind_dir;

% define an ellipse with rx, ry at the origin
t = linspace(0,2*pi,100);
x = rx*cos(t);
y = ry*sin(t);
[ylat,xlon] = ned2geodetic(x,y,0,updrafta.latitude,updrafta.longitude,0,wgs84Ellipsoid);

f1 = figure('Renderer', 'painters', 'Position', [10 10 900 900]);
contourf(lon_grid,lat_grid,vpt)
hold on
plot(xlon,ylat,'linewidth',1,'Color',[1 1 1])
bar1 = colorbar;
bar1.Label.String = '\theta_v [K]';
colormap(map)
title('Virtual Potential Temperature (Single Thermal)')
xlabel('Longitude')
ylabel('Latitude')


%% Plot vpt field and radii (cloud street)
close all
f2 = figure('Renderer', 'painters', 'Position', [10 10 900 900]);
contourf(lon_grid1,lat_grid1,vpt1)
bar2 = colorbar;
bar2.Label.String = '\theta_v [K]';
colormap(map);
title('Virtual Potential Temperature (Cloud Street)')
xlabel('Longitude')
ylabel('Latitude')
hold on
% Create one ellipse for each thermal
for i = 1:length(updrafts)
    rx = updrafts{i}.radius_uw; % semi-major axis (aligned with alpha)
    ry = updrafts{i}.radius_cw; % semi-minor axis
    alpha = updrafts{i}.wind_dir;

    % define an ellipse with rx, ry at the origin rotated by alpha
    t = linspace(0,2*pi,100);
    x = rx*cos(t);
    y = ry*sin(t);
    R = [cosd(alpha) -sind(alpha); sind(alpha) cosd(alpha)];
    xy = R*[x;y];
    [ylat,xlon] = ned2geodetic(xy(1,:),xy(2,:),0,updrafts{i}.latitude,updrafts{i}.longitude,0,wgs84Ellipsoid);
    plot(xlon,ylat,'linewidth',0.5,'Color',[1 1 1])
end
%% Save figures
saveas(f1,'Images/Validation/Single thermal','png')
saveas(f2,'Images/Validation/Cloud street','png')