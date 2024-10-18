function gradient = thermal_gradient(vpt)
    % This function calculates the gradient of the virtual potential temperature
    % in the body frame of an aircraft based on the measurements from sensors 
    % located at the nose and the wingtips.
    %
    % Constants:
    %   wingspan (meters) - The distance between the left and right wingtips.
    %   nose_to_wing (meters) - The distance from the nose of the aircraft to the midpoint of the wingspan.
    %
    % Inputs:
    %   vpt - A vector containing the virtual potential temperature measurements 
    %         from three sensors: [vpt_nose, vpt_left, vpt_right].
    %
    % Outputs:
    %   gradient - A vector representing the gradient of the virtual potential 
    %              temperature in the body frame of the aircraft. The components 
    %              of the gradient vector are:
    %              [dtheta_dx, dtheta_dy, dtheta_dz], where:
    %              dtheta_dx - Gradient in the x-direction (nose to wing).
    %              dtheta_dy - Gradient in the y-direction (left to right wing).
    %              dtheta_dz - Gradient in the z-direction (assumed to be zero 
    %                          since all sensors are at the same height).
    
    % Constants
    wingspan = 15; % meters
    nose_to_wing = 1.6; % meters

    % Extract the virtual potential temperature at each point
    vpt_nose = vpt(1);
    vpt_left = vpt(2);
    vpt_right = vpt(3);

    % Calculate the gradient of virtual potential temperature in the body frame
    dtheta_dy = (vpt_right - vpt_left) / wingspan;
    dtheta_dx = (vpt_nose - (vpt_left + vpt_right) / 2) / nose_to_wing;
    dtheta_dz = 0; % No change in the vertical direction, all sensors are at the same height

    gradient = [dtheta_dx, dtheta_dy, dtheta_dz]; % Gradient vector in the body frame
end


