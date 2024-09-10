all_fig = findall(0, 'type', 'figure');
close(all_fig)

% % Load data
% load('stations.mat', 'stations');
% 
% % Extract trajectory from flight
% traj_lat = flight.trajectory.lat.lat;
% traj_lon = flight.trajectory.lon.lon;
% 
% active_stations = find_active_stations(flight,stations,200000);
% 
% nearest_stations = find_nearest_stations(flight,active_stations);
% 
% soundings = [];
% for i = 1:size(nearest_stations,1)
%     station = nearest_stations(i,:);
%     filename = strcat('IGRA-Parser/soundings/', station.ID, '-drvd.txt');
%     found = parse_derived_by_date(filename, flight.date);
%     soundings = [soundings, found];
% end
% 
% 
% stations = load('stations.mat', 'stations');
% stations = stations.stations;
% t = struct2table(soundings);
% vars = ["stationID","time"];
% newNames = ["Station ID","Sounding time"];
% t = renamevars(t,vars,newNames);
% t = t(:,newNames);

% Create UI components
fig = uifigure("Position",[100 100 800 450]);
grid = uigridlayout(fig,[1 2]);
grid.ColumnWidth = {'1x','2x'};
subgrid = uigridlayout(grid,[2 1]);
sounding_tbl = uitable(subgrid);
ax = geoaxes(grid);
bg = uibuttongroup(subgrid);
b1 = uibutton(bg,"Text","Load flight","Position",[10 180 100 22]);
% b2 = uibutton(bg,"Text","Detect thermals","Position",[10 155 100 22]);
% b3 = uipushbutton(bg,"Text","Add thermal","Position",[10 130 100 22]);
% b4 = uipushbutton(bg,"Text","Remove thermal","Position",[10 105 100 22]);
% b5 = uipushbutton(bg,"Text","Remove all","Position",[10 80 100 22]);
% b6 = uipushbutton(bg,"Text","Import selected","Position",[10 55 100 22]);


traj_plot = geoplot([],[],'-b','Parent',ax);

% Set axis limits to fit the trajectory
%geolimits(ax,[min(traj_lat) max(traj_lat)], [min(traj_lon) max(traj_lon)]);

% % Add all stations to the plot
% hold(ax,"on");
% geoscatter(stations, "lat", "lon","Marker","^","MarkerEdgeColor","r","Parent",ax);
% hold(ax,"off")
% 
% % Add active stations to the plot
% hold(ax,"on");
% geoscatter(active_stations, "lat", "lon","Marker","^","MarkerEdgeColor","g","Parent",ax);
% hold(ax,"off")
% 
% % Add nearest stations to the plot
% hold(ax,"on");
% geoscatter(nearest_stations, "lat", "lon","Marker","^","MarkerEdgeColor","b","Parent",ax);
% hold(ax,"off")

% % Configure table
% sounding_tbl.Data = t;
% sounding_tbl.SelectionType = "row";
% sounding_tbl.Multiselect = "on";
% sounding_tbl.SelectionChangedFcn = @(src,event) plotTsunami(src,event,traj_plot);  

% Configure buttons
b1.ButtonPushedFcn = @(src,event) load_flight();

% Button callback functions
function load_flight()
[filename,filepath] = uigetfile({'*.igc';'*.mat'});
    if filename == 0
        return
    elseif contains(filename, '.igc')
        % Parse igc file
        [flight, name] = parse_igc_file([filepath filename]);
        % Save flight to a .mat file
        save(strcat('Flights/',name, '.mat'), 'flight');
    elseif contains(filename, '.mat')
        % Open saved flight
        load([filepath filename]);
        assignin("base",'flight',flight);
        fig.grid.ax.traj_plot.LatitudeData = flight.trajectory.lat.lat;
        traj_plot.LongitudeData = flight.trajectory.lon.lon;
    else
        return
    end
end
% % Plot tsunami data for each selected row
% function plotTsunami(src,event,gb)
% rows = event.Selection;
% data = src.Data(rows,:);
% gb.LatitudeData = data.Latitude;
% gb.LongitudeData = data.Longitude;
% gb.SizeData = data.MaxHeight;
% end

% Show station names when hovering over the markers wohooooooooooooo
% gcm_obj = datacursormode(fig);
% set(gcm_obj,'UpdateFcn',@data_cursor_updatefcn)
% % Callback function to display station names
% function output_txt = data_cursor_updatefcn(~, event_obj)
%     % Display the position of the data cursor
%     pos = event_obj.Position;
%     idx = event_obj.DataIndex;
%         output_txt = {['Station: ' stations.ID{idx}]};
% end