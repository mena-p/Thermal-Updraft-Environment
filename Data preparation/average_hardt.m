function [ptemp_avg,spec_hum_avg,rel_dist] = average_hardt(tables)
% This function averages the potential temperature and specific 
% humidity differences for the flights provided in tables and returns the
% average values truncated to -4 to 4 relative distance.
%   INPUT: 
%   tables - a cell array of tables containing the potential
%   temperature and specific humidity differences for the flights
%   OUTPUT: 
%   ptemp_avg - the average potential temperature difference
%   spec_hum_avg - the average specific humidity difference


% interpolate flights
% find min and max values of relative distance among all flights
min_dist = inf;
max_dist = - inf;
for i = 1:length(tables)
    if min_dist > tables{i}{1, 1}
        min_dist = tables{i}{1, 1};
    end
    if max_dist < tables{i}{end, 1}
        max_dist = tables{i}{end, 1};
    end
end

% create array of query points
rel_dist = min_dist:0.0001:max_dist;

% interpolate the values in the tables to obtain the ptemp_diff and spec_hum_diff for the flights
% in fixed 0.0001 m intervals of relative distance
ptemp = zeros(length(tables), length(rel_dist));    % store values of each table in one line of the array
spec_hum = zeros(length(tables), length(rel_dist)); % same as above
for i = 1:length(tables)
    ptemp(i, :) = interp1(table2array(tables{i}(:, 1)), table2array(tables{i}(:, 2)), rel_dist);
    spec_hum(i, :) = interp1(table2array(tables{i}(:, 1)), table2array(tables{i}(:, 3)), rel_dist);
end

% average out the values of ptemp_diff and spec_hum_diff at each position
ptemp_avg = mean(ptemp, 1,"omitnan");
spec_hum_avg = mean(spec_hum, 1,"omitnan");

% truncate profiles to -4 to 4 relative distance
ptemp_avg = ptemp_avg(rel_dist >= -4 & rel_dist <= 4);
spec_hum_avg = spec_hum_avg(rel_dist >= -4 & rel_dist <= 4);
rel_dist = rel_dist(rel_dist >= -4 & rel_dist <= 4);
end

