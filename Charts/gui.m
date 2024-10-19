function gui()
    
    all_fig = findall(0, 'type', 'figure');
    close(all_fig)
    
    % Load data and declare variables (function scope)
    load('stations.mat', 'stations');
    nearest = [];
    soundings = [];
    selected_soundings = [];
    
    %% Create UI components
    fig = uifigure("Position",[100 100 800 450],"Name",'Soarsense','Tag','GUI');
    tabs = uitabgroup("Parent",fig,"Units","normalized","Position",[0 0 1 1]);
    tab1 = uitab("Parent",tabs,"Title",	"Setup");
    grid = uigridlayout(tab1,[1 2]);
    grid.ColumnWidth = {'1x','2x'};
    subgrid = uigridlayout(grid,[2 1]);
    tab2 = uitab("Parent",tabs,"Title","Simulation");
    grid2 = uigridlayout(tab2,[2 2]);
    %subgrid2 = uigridlayout(grid2,[1 3]);

    
    %% Plots Simulation Tab
    % Instruments plot
    subgrid2 = uigridlayout(grid2,[1 3]);
    subgrid2.Layout.Row = 1;
    subgrid2.Layout.Column = 2;
    airspeed = uiaeroairspeed(subgrid2,"Tag","airspeed","Limits",[0 150]);
    altimeter = uiaeroaltimeter(subgrid2,"Tag","altimeter");
    climb = uiaeroclimb(subgrid2,"Tag","climb");

    % Aircaft plot
    ax3 = geoaxes(grid2);
    ax3.Layout.Row = 1;
    ax3.Layout.Column = 1;
    position = geoplot(0,0,'-b','Parent',ax3,"Tag","position");
    set(position,'LatitudeData',[],'LongitudeData',[]);

    % Thermals plot
    thermal_plot = geoscatter(0,0,'r',"Marker",'o',"Parent",ax3);
    

    % Arrow plot
    ax2 = polaraxes("Parent",grid2);
    ax2.Layout.Row = 2;
    ax2.Layout.Column = 2;
    arrow_plot = compassplot(0,1,'Parent',ax2,"Tag","arrowPlot");
    set(ax2,"ThetaZeroLocation",'top',"ThetaDir",'clockwise')

    % Simulation controls
    simControl = uisimcontrols(grid2);
    simControl.Layout.Row = 2;
    simControl.Layout.Column = 1;

    % Plots Setup Tab
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

    % Table
    sounding_tbl = uitable(subgrid);
    sounding_tbl.SelectionType = "row";
    sounding_tbl.Multiselect = "on";
    sounding_tbl.Data = table('Size',[1 2],'VariableTypes',["string",...
        "datetime"],'VariableNames',["Station ID","Sounding time"]);
    sounding_tbl.SelectionChangedFcn = @(src,event) select_soundings(src,event);

    % Buttons
    bg = uibuttongroup(subgrid);
    b1 = uibutton(bg,"Text","Load flight","Position",[10 180 100 22]);
    b2 = uibutton(bg,"Text","Detect thermals","Position",[10 155 100 22]);
    b3 = uibutton(bg,"Text","Add thermal","Position",[10 130 100 22]);
    b4 = uibutton(bg,"Text","Remove thermal","Position",[10 105 100 22]);
    b5 = uibutton(bg,"Text","Remove all","Position",[10 80 100 22]);
    b6 = uibutton(bg,"Text","Download data","Position",[10 55 100 22]);
    b7 = uibutton(bg,"Text","Find soundings","Position",[10 30 100 22]);
    b8 = uibutton(bg,"Text","Send to model","Position",[10 5 100 22]);
    
    % Configure buttons
    b1.ButtonPushedFcn = @(src,event) load_flight();
    b2.ButtonPushedFcn = @(src,event) detect_thermals();
    b3.ButtonPushedFcn = @(src,event) add_thermal();
    b4.ButtonPushedFcn = @(src,event) remove_thermal();
    b5.ButtonPushedFcn = @(src,event) remove_all();
    b6.ButtonPushedFcn = @(src,event) download_data();
    b7.ButtonPushedFcn = @(src,event) find_soundings();
    b8.ButtonPushedFcn = @(src,event) send_to_model();
    
  
    % % Load data
    % try
    %     traj_plot = plot_flight();
    % catch
    % end
    % try
    %     updraft_plot = plot_updrafts();
    % catch
    % end
    
    
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

    function find_soundings()
    
            if ~evalin("base",'exist(''flight'', ''var'')')
                disp("Please load a flight first.")
                return
            end
            flight = evalin("base",'flight');
        
            found_soundings = [];
            for i = 1:size(nearest,1)
                station = nearest(i,:);
                filename = strcat('IGRA-Parser/soundings/', station.ID, '-drvd.txt');
                found = parse_derived_by_date(filename, flight.date);
                found_soundings = [found_soundings, found];
            end
            %found_soundings = filter_soundings(found_soundings); 
            soundings = struct2table(found_soundings,"AsArray",true);
            t = soundings;
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

    %% Prepare everything for simulink
    function send_to_model()
        % Check if everything is ready
        
        if ~evalin("base",'exist(''flight'', ''var'')')
            warning off backtrace
            warning("Please load a flight first.")
            warning on backtrace
            return
        elseif ~evalin("base",'exist(''updraft_locations'', ''var'')') || ...
                isempty(evalin("base", 'updraft_locations'))
            warning off backtrace
            warning("Please add at least one thermal.")
            warning on backtrace
            return
        elseif ~evalin("base",'exist(''selected_soundings'', ''var'')') ||...
                size(evalin("base", 'selected_soundings'),1) == 0
            warning off backtrace
            warning("Please select at least one sounding.")
            warning on backtrace
            return
        end
        
        % Load selected soundings
        selected_soundings = evalin("base", 'selected_soundings');

        % Add lat and lon of the station to the selected soundings
        for i = 1:size(selected_soundings,1)
            station = selected_soundings(i,:);
            lat = stations.lat(strcmp(stations.ID,station.stationID));
            lon = stations.lon(strcmp(stations.ID,station.stationID));
            selected_soundings.lat(i) = lat;
            selected_soundings.lon(i) = lon;
        end

        % Extract sounding data and interpolate missing values
        selected_soundings_structs = table2struct(selected_soundings);
        for i = 1:size(selected_soundings_structs,1)
        	tmp = extract_sounding_data(selected_soundings_structs(i));
            %tmp = remove_values_above(tmp, 5000);
            reduced_soundings(i) = interpolate_missing(tmp);
        end

        % Get lowest number of levels among all soundings
        numLevels = min(arrayfun(@(x) length(x.derived.REPGPH), reduced_soundings));

        % Reduce all soundings to the same number of levels
        % (soundings may still have measurements at different heights,
        % but will have the same number of measurements)
        for i = 1:size(reduced_soundings,2)
            reduced_soundings(i).derived(numLevels+1:end,:) = [];
        end
        disp('Capped soundings to the same number of levels')

        % Assign numLevels to base workspace
        assignin("base", 'numLevels', numLevels);

        % Create array of sounding busses
        sounding_buses = create_bus(reduced_soundings);

        % Assign busses to base workspace
        assignin("base", 'sounding_buses', sounding_buses);

        % Load sounding bus specification from sounding_bus.mat to base workspace
        assignin("base", 'sounding', load('sounding_bus.mat').sounding);
        disp('Loaded sounding bus specification')

        % Initialize updrafts
        updraft_locations = evalin("base", 'updraft_locations');
        for i = 1:size(updraft_locations,1)
            updrafts{i} = Updraft(updraft_locations(i,1),updraft_locations(i,2));
        end

        % Assign updrafts to base workspace
        assignin("base", 'updrafts', updrafts);
        disp('Initialized updrafts at selected locations')

        fprintf('\nThe model is ready to run.\n\n')
        
    end

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

    % Select soundings from table
    function select_soundings(src,event)
        rows = event.Selection;
        if ~isempty(soundings)
            selected_soundings = soundings(rows,:);
            assignin("base","selected_soundings",selected_soundings);
        else
            disp('Find soundings first.')
        end
        
    end


end

