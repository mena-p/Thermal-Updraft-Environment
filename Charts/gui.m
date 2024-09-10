function gui()
    
    all_fig = findall(0, 'type', 'figure');
    close(all_fig)
    
    % Load data
    load('stations.mat', 'stations');
    nearest = [];
   
    
    %% Create UI components
    fig = uifigure("Position",[100 100 800 450]);
    grid = uigridlayout(fig,[1 2]);
    grid.ColumnWidth = {'1x','2x'};
    subgrid = uigridlayout(grid,[2 1]);

    sounding_tbl = uitable(subgrid);
    sounding_tbl.SelectionType = "row";
    sounding_tbl.Multiselect = "on";
    sounding_tbl.Data = table('Size',[1 2],'VariableTypes',["string",...
        "datetime"],'VariableNames',["Station ID","Sounding time"]);

    ax = geoaxes(grid);
    traj_plot = geoplot(0,0,'-b','Parent',ax);
    hold(ax,"on")
    updraft_plot = geoscatter(0,0,'r',"Marker",'o',"Parent",ax);
    active_station_plot = geoscatter(0,0,"Marker","^","MarkerEdgeColor","g","Parent",ax);
    nearest_station_plot = geoscatter(0,0,"Marker","^","MarkerEdgeColor","b","Parent",ax);
    hold(ax,"off")
    set(updraft_plot,'XData',[],"YData",[]);
    set(active_station_plot,'XData',[],"YData",[]);
    set(nearest_station_plot,'XData',[],"YData",[]);

    bg = uibuttongroup(subgrid);
    b1 = uibutton(bg,"Text","Load flight","Position",[10 180 100 22]);
    b2 = uibutton(bg,"Text","Detect thermals","Position",[10 155 100 22]);
    b3 = uibutton(bg,"Text","Add thermal","Position",[10 130 100 22]);
    b4 = uibutton(bg,"Text","Remove thermal","Position",[10 105 100 22]);
    b5 = uibutton(bg,"Text","Remove all","Position",[10 80 100 22]);
    b6 = uibutton(bg,"Text","Download data","Position",[10 55 100 22]);
    b7 = uibutton(bg,"Text","Find soundings","Position",[10 30 100 22]);
    
    % Configure buttons
    b1.ButtonPushedFcn = @(src,event) load_flight();
    b2.ButtonPushedFcn = @(src,event) detect_thermals();
    b3.ButtonPushedFcn = @(src,event) add_thermal();
    b4.ButtonPushedFcn = @(src,event) remove_thermal();
    b5.ButtonPushedFcn = @(src,event) remove_all();
    b6.ButtonPushedFcn = @(src,event) download_data();
    b7.ButtonPushedFcn = @(src,event) find_soundings();

    
    

    % % Load data
    % try
    %     traj_plot = plot_flight();
    % catch
    % end
    % try
    %     updraft_plot = plot_updrafts();
    % catch
    % end
    
    
    % % Configure table
    % sounding_tbl.SelectionChangedFcn = @(src,event) plotTsunami(src,event,traj_plot);  
    
    
    
    %% Button callback functions
    % Load flight
    function load_flight()
    [filename,filepath] = uigetfile({'*.igc';'*.mat'});
        if filename == 0
            return
        elseif contains(filename, '.igc')
            % Parse igc file
            [flight, name] = parse_igc_file([filepath filename]);
            % Save flight to a .mat file
            save(strcat('Flights/',name, '.mat'), 'flight');
            assignin("base",'flight',flight);
        elseif contains(filename, '.mat')
            % Open saved flight
            load([filepath filename]);
            assignin("base",'flight',flight);
        else
            return
        end
        % Plot the flight trajectory
        plot_flight();
        show_stations();
    end

    % Detect thermals
    function detect_thermals()
        % Check if flight is loaded
        if ~evalin("base",'exist(''flight'', ''var'')')
            disp("Please load a flight first.")
            return
        end
        % Check if updraft_locations is loaded
        if ~evalin("base",'exist(''updraft_locations'', ''var'')')
            updraft_locations = zeros(0, 0);
            assignin("base", 'updraft_locations', updraft_locations)
        end
        % Load flight and updraft_locations
        updraft_locations = evalin("base", 'updraft_locations');
        flight = evalin("base",'flight');

        % Call detect_thermals_igc function
        new_locations = detect_thermals_igc(flight.trajectory);
        updraft_locations = [updraft_locations; new_locations];

        % Remove duplicates (in case the user spams the button)
        [~, idx] = unique(updraft_locations, 'rows');
        updraft_locations = updraft_locations(idx,:);
        
        assignin("base", 'updraft_locations', updraft_locations)
        plot_updrafts();
    end

    % Add thermal
    function add_thermal(src, event)

        % Dumb workaround since ginput doesn't work with uifigure
        fhv = fig.HandleVisibility;        % Current status
        fig.HandleVisibility = 'callback'; % Temp change (or, 'on') 
        set(0, 'CurrentFigure', fig)       % Make fig current

        % Get latitude and longitude from user input
        [lat, lon] = ginput(1);

        fig.HandleVisibility = fhv;        % return original state
        
        % Check if updraft_locations is loaded
        if ~evalin("base",'exist(''updraft_locations'', ''var'')')
            updraft_locations = zeros(0, 0);
            assignin("base", 'updraft_locations', updraft_locations)
        end

        % Load updrafts locations from model workspace
        updraft_locations = evalin("base", 'updraft_locations');

        % Append the updraft to the array
        updraft_locations(end+1,:) = [lat lon];

        % Save the changes to the workspace variable
        assignin("base", 'updraft_locations', updraft_locations)

        % Re-plot the updraft locations
        plot_updrafts();
    end

    % Remove thermal
    function remove_thermal(src, event)

        % Check if updraft_locations is loaded
        if ~evalin("base",'exist(''updraft_locations'', ''var'')')
            return
        end

        % Load updrafts objects from the workspace
        updraft_locations = evalin("base", 'updraft_locations');

        % Dumb workaround since ginput doesn't work with uifigure
        fhv = fig.HandleVisibility;        % Current status
        fig.HandleVisibility = 'callback'; % Temp change (or, 'on') 
        set(0, 'CurrentFigure', fig)       % Make fig current

        % Get latitude and longitude from user input
        [lat, lon] = ginput(1);

        fig.HandleVisibility = fhv;        % return original state

        % Find the index of the updraft to delete
        max_distance = 0.05;
        idx = find(sqrt((updraft_locations(:,1)-lat).^2 + (updraft_locations(:,2)-lon).^2) < max_distance, 1);

        % Delete the updraft
        updraft_locations(idx,:) = [];

        % Save the changes to the workspace variable
        assignin("base", 'updraft_locations', updraft_locations)

        % Re-plot updrafts
        plot_updrafts();
        
    end

    % Remove all thermals
    function remove_all(src, event)
        % Check if updraft_locations is loaded
        if ~evalin("base",'exist(''updraft_locations'', ''var'')')
            return
        end
        % Load updrafts objects from the workspace
        assignin("base", 'updraft_locations',[]);
        % Re-plot updraft
        plot_updrafts();
    end

    %% Plotting functions
    % Plot flight trajectory
    function plot_flight()
        flight = evalin("base",'flight');
        traj_lat = flight.trajectory.lat.lat;
        traj_lon = flight.trajectory.lon.lon;
        set(traj_plot,'XData',traj_lat,'YData',traj_lon);
        geolimits(ax,[0.99*min(traj_lat) 1.01*max(traj_lat)], [0.99*min(traj_lon) 1.01*max(traj_lon)])
    end

    % Plot updrafts
    function plot_updrafts()
        % Check if updraft_locations is loaded
        if ~evalin("base",'exist(''updraft_locations'', ''var'')')
            updraft_locations = zeros(0, 0);
            assignin("base", 'updraft_locations', updraft_locations)
        end

        updraft_locations = evalin("base",'updraft_locations');
        if ~isempty(updraft_locations)
            set(updraft_plot,'XData',updraft_locations(:,1),"YData",updraft_locations(:,2));
        else
            set(updraft_plot,'XData',[],"YData",[]);
        end
    end
    % Plot stations
    function show_stations()
        if ~evalin("base",'exist(''flight'', ''var'')')
            disp("Please load a flight first.")
            return
        end

        flight = evalin("base",'flight');

        active = find_active_stations(flight,stations,200000);
        nearest = find_nearest_stations(flight,active);

        set(active_station_plot,'XData',active.lat,"YData",active.lon);
        set(nearest_station_plot,'XData',nearest.lat,"YData",nearest.lon);
    end

    function soundings = find_soundings()
    
            if ~evalin("base",'exist(''flight'', ''var'')')
                disp("Please load a flight first.")
                return
            end
            flight = evalin("base",'flight');
        
            soundings = [];
            for i = 1:size(nearest,1)
                station = nearest(i,:);
                filename = strcat('IGRA-Parser/soundings/', station.ID, '-drvd.txt');
                found = parse_derived_by_date(filename, flight.date);
                soundings = [soundings, found];
            end
            t = struct2table(soundings);
            vars = ["stationID","time"];
            newNames = ["Station ID","Sounding time"];
            t = renamevars(t,vars,newNames);
            t = t(:,newNames);
            % Configure table
            sounding_tbl.Data = t;
            sounding_tbl.SelectionType = "row";
            sounding_tbl.Multiselect = "on";
      
    end
    %% Download data
    function download_data(src,event)
        download_station_files(nearest);
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

end