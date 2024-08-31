% this script creates a chart of the aircraft trajectory and updraft locations using geoplots
% and geoscatter. The updrafts are represented by red circles, and the aircraft trajectory is
% represented by a blue line. The updrafts are created by clicking on the map, and the aircraft
% trajectory is provided by an array of latitude and longitude coordinates.
%
% This script requires the Mapping Toolbox.
%
close all
% Create a vector of latitude and longitude coordinates for the aircraft trajectory
lat = [48.0, 48.1, 48.2, 48.3, 48.4];
lon = [11.0, 11.1, 11.2, 11.3, 11.6];clc

% Create an empty vector to store the updraft locations
updrafts = [];

% Plot the aircraft trajectory on the map
geoplot(lat,lon,"b-","LineWidth",2)
geobasemap topographic

% Create a button on the figure that calls the add_updraft function when clicked
c = uicontrol('Style','pushbutton','String','Add Updraft','Position',[20,20,100,30],'Callback',@add_updraft);


% Define a callback function to add updrafts
function add_updraft(updraft_list)
    % Display a text above the figure
    annotation('textbox',[0.135,0.89,0.1,0.1],'String','Click on the map to add an updraft.','FitBoxToText','on')
    % Get the current figure
    fig = gcf;
    
    % Get the current axes
    ax = gca;
    
    % Get the latitude and longitude of the clicked point
    [lat,lon] = ginput(1);

    % Remove the text box
    delete(findall(fig,'Type','annotation'))

    % Create an Updraft object with the clicked latitude and longitude
    updraft = Updraft(lat,lon,1);

    % Add the updraft to the updrafts vector
    updraft_list = [updraft_list, updraft];
    

end

