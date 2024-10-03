% clear times
% for i = 1:n
% milli = measured_data.time(i) - start_time;
% milli.Format = 's';
% times(i,1) = milli;
% end

flight.trajectory.alt = timetable(times,measured_data.gps_altitude);
temps = timetable(times,measured_data.temperature + 273.15);
