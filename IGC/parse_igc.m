

%[flight, name] = parse_igc_file('C:\Users\Pedro\Documents\MATLAB\Thermal-Updraft-Model\IGC\IGC data\2024-07-29 Nils Schlautmann 450496.igc');

% Save flight to a .mat file called name.mat
save(strcat('Flights/',name, '.mat'), 'flight');




