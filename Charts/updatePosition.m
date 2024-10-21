function updatePosition(y,time,sigNum) 
% Get GUI handle
    position = findobj(allchild(0),'Tag', 'position');
    % Get current data
    currentLat = position.LatitudeData;
    currentLon = position.LongitudeData;
    % Append new data
    latData = [currentLat y(1,1)];
    lonData = [currentLon y(1,2)];
    % Update plot
    set(position,'LatitudeData',latData,'LongitudeData',lonData);
    drawnow limitrate;
end