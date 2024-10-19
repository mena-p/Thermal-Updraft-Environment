function updateVelocity(y,time,sigNum)
    % Get GUI handle
    airspeed = findobj(allchild(0),'Tag', 'airspeed');
    climb = findobj(allchild(0),'Tag', 'climb');
    vel = sqrt(y*y') * 1.943844; % knots
    vert = y(3) * 196.85039370078738; % ft/min
    set(airspeed,'Airspeed',vel);
    set(climb,'ClimbRate',vert);
    drawnow;
end