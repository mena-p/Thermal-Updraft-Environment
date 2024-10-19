function updateArrow(y,time,sigNum)
    % Get GUI handle
    plot = findobj(allchild(0),'Tag', 'arrowPlot');
    theta = atan2(y(2),y(1));
    rho = sqrt(y(1)^2 + y(2)^2);
    set(plot,'ThetaData',theta,'RData',1);
    drawnow;
end
