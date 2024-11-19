% This script plots the thermal diameters in chapter 2 of the thesis.
clear
close all

z_i = 1000;
z = linspace(0, z_i, 1000);
z_norm = z / z_i;

% Lenschow/Allen radius (already normalized)
d_Lenschow_norm = 0.2032 * z_norm.^(1/3) .* (1 - 0.25 * z_norm);

% Childress radius
d_Childress = z_i * 0.4 .* z_norm.^(1/3) .* (1 - 0.5 * z_norm) + ...
    z .* (1 / pi) .* (z_norm - 0.6) .* z_norm;
d_Childress_norm = d_Childress/z_i;

% Plot
figure;
hold on;
plot(d_Lenschow_norm, z_norm,'Color','[0 0 0]','LineStyle','-');
plot(d_Childress_norm, z_norm,'Color','[0 0 0]','LineStyle','--');
xlabel('d/z_i [-]');
ylabel('z/z_i [-]');
title('Lenschow/Allen and Childress Outer Diameter');
legend('Lenschow/Allen','Childress', 'Location', 'northwest');
grid on;
hold off;
