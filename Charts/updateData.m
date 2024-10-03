function updateData(y,time,sigNum)
    % Get GUI handle
    plot = findobj(allchild(0), 'Tag', 'dataPlot');
    xData = plot.XData';
    xData = [xData; time];
    yData = plot.YData';
    yData = [yData; y];
    set(plot,'XData',xData,"YData",yData);
    drawnow;
end
