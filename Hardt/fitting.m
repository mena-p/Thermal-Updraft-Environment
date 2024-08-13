% This script loads the data from all .csv files in the folder "C:\Users\Pedro\Documents\Faculdade\Bachelorarbeit\Hardt data"
% each into one table. It extracts only the colums relative_distance_m, ptemt_diff_dgc and spec_hum_diff_gkg from each file.
% It then plots the values of ptemt_diff_dgc and spec_hum_diff_gkg against relative_distance_m for each table, in the same figure.

close all

% load all .csv files in the folder "C:\Users\Pedro\Documents\Faculdade\Bachelorarbeit\Hardt data" into a cell array
files = dir("C:\Users\Pedro\Documents\Faculdade\Bachelorarbeit\Hardt data\*.csv");
tablesUW = cell(length(files), 1);
tablesCW = cell(length(files), 1);
tablesDW = cell(length(files), 1);

% import the data from each file into a table and store the table in the corresponding cell array

for i = 1:length(files)
    tables{i} = import_thermal2(fullfile(files(i).folder, files(i).name), [17, Inf]);
    % check if file is crosswind (CW), downwind (DW) or upwind (UW) by checking the file name and store in the corresponding cell array
    if contains(files(i).name, "CW")
        tablesCW{i} = tables{i};
    elseif contains(files(i).name, "UW")
        tablesUW{i} = tables{i};
    elseif contains(files(i).name, "DW")
        tablesDW{i} = tables{i};
    else
        error("File name does not contain 'CW', 'DW' or 'UW'");
    end
end

% drop empty rows
tablesUW = tablesUW(~cellfun('isempty', tablesUW));
tablesCW = tablesCW(~cellfun('isempty', tablesCW));
tablesDW = tablesDW(~cellfun('isempty', tablesDW));

% plot ptemp_diff_dgc against relative distance between -1 and 1 for UW flights 
figure
subplot(1,3,1)
hold on
for i = 1:length(tablesUW)
    plot(table2array(tablesUW{i}(:, 1)), table2array(tablesUW{i}(:, 2)))
end
% restrict the x axis to -1 and 1
xlim([-2, 2])
xlabel('relative distance (m)')
ylabel('ptemp diff (dgc)')
title('UW flights')
hold off

% make another plot in the same figure for DW flights
subplot(1,3,2)
hold on
for i = 1:length(tablesDW)
    plot(table2array(tablesDW{i}(:, 1)), table2array(tablesDW{i}(:, 2)))
end

% restrict the x axis to -1 and 1
xlim([-2, 2])
xlabel('relative distance (m)')
ylabel('ptemp diff (dgc)')
title('DW flights')
hold off

% make another plot in the same figure for CW flights
subplot(1,3,3)
hold on
for i = 1:length(tablesCW)
    plot(table2array(tablesCW{i}(:, 1)), table2array(tablesCW{i}(:, 2)))
end
% restrict the x axis to -1 and 1
xlim([-2, 2])
xlabel('relative distance (m)')
ylabel('ptemp diff (dgc)')
title('CW flights')
hold off

% plot spec_hum_diff_gkg against relative distance between -1 and 1 for UW flights 
figure
subplot(1,3,1)
hold on
for i = 1:length(tablesUW)
    plot(table2array(tablesUW{i}(:, 1)), table2array(tablesUW{i}(:, 3)))
end

% restrict the x axis to -1 and 1
xlim([-2, 2])
xlabel('relative distance (m)')
ylabel('spec hum diff (g/kg)')
title('UW flights')
hold off

% make another plot in the same figure for DW flights
subplot(1,3,2)
hold on
for i = 1:length(tablesDW)
    plot(table2array(tablesDW{i}(:, 1)), table2array(tablesDW{i}(:, 3)))
end
% restrict the x axis to -1 and 1
xlim([-2, 2])
xlabel('relative distance (m)')
ylabel('spec hum diff (g/kg)')
title('DW flights')
hold off

% make another plot in the same figure for CW flights
subplot(1,3,3)
hold on
for i = 1:length(tablesCW)
    plot(table2array(tablesCW{i}(:, 1)), table2array(tablesCW{i}(:, 3)))
end
% restrict the x axis to -1 and 1
xlim([-2, 2])
xlabel('relative distance (m)')
ylabel('spec hum diff (g/kg)')
title('CW flights')
hold off

% interpolate the values in the tables to obtain the ptemp_diff and spec_hum_diff for UW, DW and CW flights
% in fixed 0.0001 m intervals of relative distance

% interpolate the UW flights
% find min and max values of relative distance among all tables
min_dist = inf;
max_dist = - inf;
for i = 1:length(tablesDW)
    if min_dist > tablesDW{i}{1, 1}
        min_dist = tablesDW{i}{1, 1};
    end
    if max_dist < tablesDW{i}{end, 1}
        max_dist = tablesDW{i}{end, 1};
    end
end

% create array of query points
xq = min_dist:0.0001:max_dist;

% interpolate the values in the tables to obtain the ptemp_diff and spec_hum_diff for DW flights
% in fixed 0.0001 m intervals of relative distance
ptemp_diff_DW = zeros(length(tablesDW), length(xq));    % store values of each table in one line of the array
spec_hum_diff_DW = zeros(length(tablesDW), length(xq)); % same as above
for i = 1:length(tablesDW)
    ptemp_diff_DW(i, :) = interp1(table2array(tablesDW{i}(:, 1)), table2array(tablesDW{i}(:, 2)), xq);
    spec_hum_diff_DW(i, :) = interp1(table2array(tablesDW{i}(:, 1)), table2array(tablesDW{i}(:, 3)), xq);
end

% average out the values of ptemp_diff and spec_hum_diff at each position for DW flights
ptemp_diff_DW_avg = mean(ptemp_diff_DW, 1);

% plot the average values and the original values together
figure
subplot(2,1,1)
hold on
plot(xq, ptemp_diff_DW(1, :))
plot(xq, ptemp_diff_DW(2, :))
%plot(xq, ptemp_diff_DW(3, :))
hold off
xlabel('relative distance (m)')
ylabel('ptemp diff (dgc)')
title('DW flights')
xlim([-2, 2])
subplot(2,1,2)
plot(xq, ptemp_diff_DW_avg)
xlabel('relative distance (m)')
ylabel('avg ptemp diff (dgc)')
title('DW flights')
xlim([-2, 2])




