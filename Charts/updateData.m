function updateData(y,time,sigNum)

    % Get GUI handle
    gui = findobj(allchild(0),'Tag','GUI');

    % Update the data
    if sigNum == 1 % y = position
        % Get position plot and altimeter
        position = findobj(allchild(gui), 'Tag', 'position');
        altimeter = findobj(allchild(gui), 'Tag', 'altimeter');
        
        if time(1) < 2
            set(position,'LatitudeData',[],"LongitudeData",[]);
            set(altimeter,'Altitude',0);
            drawnow;
        else
            lat = y(1,1);
            lon = y(1,2);
            set(position,'LatitudeData',lat,"LongitudeData",lon);
            set(altimeter,'Altitude',y(1,3));

            % Check if updraft positions exist
        if ~evalin("base",'exist(''updraft_locations'', ''var'')')
            return
        end
        
        % Get nearest thermal arrow plot
        near = findobj(allchild(gui), 'Tag', 'nearestPlot');

        % Get nearest updraft location
        updrafts_pos = evalin("base",'updraft_locations');

        % Compute distance to each updraft
        dist = zeros(size(updrafts_pos,1),1);
        for i = 1:size(updrafts_pos,1)
            dist(i) = sqrt((updrafts_pos(i,1) - y(1,1))^2 + (updrafts_pos(i,2) - y(1,2))^2);
        end

        % Get nearest updraft
        [~,idx] = min(dist);
        nearest = updrafts_pos(idx,:);

        % Compute angle to nearest updraft
        z = nearest(1) - y(1,1) + (nearest(2)-y(1,2))*1j;
        theta = angle(z);
        rho = 1;

        % Update nearest updraft arrow plot
        set(near,'ThetaData',theta,'RData',rho)
        drawnow;
        end

    elseif sigNum == 2 % y = velocity
        % Get airspeed and climb plots
        airspeed = findobj(allchild(gui), 'Tag', 'airspeed');
        climb = findobj(allchild(gui), 'Tag', 'climb');
        
        % Compute norm of velocity in knots
        v = sqrt(y(1,1)^2 + y(1,2)^2 + y(1,3)^2) * 1.944;
        
        % Vertical speed feet/min
        vert = y(1,3) * 196.9;
        set(airspeed,'AirSpeed',v);
        set(climb,'ClimbRate',vert);
        drawnow;

    elseif sigNum == 4 % y = vpt gradient
        % Get soarsense plot
        soarsense = findobj(allchild(gui), 'Tag', 'soarsensePlot');
       
        theta = y(1,1);
        rho = y(1,2);
        set(soarsense,'ThetaData',theta,'RData',rho)
        drawnow;
    else
        return
    end
    
end
