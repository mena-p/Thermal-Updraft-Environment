classdef Updraft
    properties
        xPosition {mustBeNumeric}
        yPosition {mustBeNumeric}
        gain {mustBeNumeric}
        timeSinceFormation {mustBeNumeric}
        wind_dir {mustBeNumeric}
        coeff_uw {mustBeNumeric}
        coeff_cw {mustBeNumeric}
    end

    methods
        function obj = Updraft(x, y, gain)
            obj.xPosition = x;
            obj.yPosition = y;
            obj.gain = gain;
            obj.timeSinceFormation = 0;
            obj.wind_dir = 350;
            obj.coeff_uw = Updraft.load_coeff_uw();
            obj.coeff_cw = Updraft.load_coeff_cw();

        end

        function outer_radius = outer_radius(obj,z,zi)
            % This function calculates the outer radius of the updraft at a given height.
            % Inputs:
            % z = Aircraft height above ground (m)
            % zi = Mixed layer height (m)
            % Outputs:
            % outer_radius = Outer radius of the updraft at the given height (m)

            % Calculate average updraft size at this height
            zzi = z / zi;
            mean_radius = (.102 * zzi^(1/3)) * (1 - (.25 * zzi)) * zi;

            % Calculate outer radius of the updraft
            outer_radius = mean_radius * obj.gain; % multiply by the perturbation gain
            if outer_radius < 10
                outer_radius = 10; % limit small updrafts to 20m diameter
            end
            outer_radius = 600;
        end

        function inner_radius = inner_radius(obj,z,zi)
            % This function calculates the outer radius of the updraft at a given height.
            % Inputs:
            % z = Aircraft height above ground (m)
            % zi = Mixed layer height (m)
            % Outputs:
            % outer_radius = Outer radius of the updraft at the given height (m)

            % Calculate average updraft size at this height
            zzi = z / zi;
            mean_radius = (.102 * zzi^(1/3)) * (1 - (.25 * zzi)) * zi;

            % Calculate outer radius of the updraft
            outer_radius = mean_radius * obj.gain; % multiply by the perturbation gain
            if outer_radius < 10
                outer_radius = 10; % limit small updrafts to 20m diameter
            end
            if outer_radius < 600
                ratio = .0011 * outer_radius + .14;
            else
                ratio = .8;
            end
            inner_radius = ratio * outer_radius;
        end

        function dist = distance_to(obj, x, y)
            % This function calculates the distance from the aircraft to the updraft.
            % Inputs:
            % x = Aircraft x position (m)
            % y = Aircraft y position (m)
            % Outputs:
            % dist = Distance from the aircraft to the updraft (m)

            dist = sqrt((x - obj.xPosition)^2 + (y - obj.yPosition)^2);
        end

        function angle_from_updraft = angle_to(obj, x, y)
            % This function calculates the angle between the vector connecting
            % the updraft center to the aircraft's position and the upwind
            % direction of the updraft (wind_dir).
            % Inputs:
            % x = Aircraft x position (m)
            % y = Aircraft y position (m)
            % Outputs:
            % angle_to_updraft (degrees)

            angle_from_x_axis = atan2d(y - obj.yPosition, x - obj.xPosition);
            if angle_from_x_axis < 0
                angle_from_x_axis = angle_from_x_axis + 360;
            end
            angle_from_updraft = angle_from_x_axis - obj.wind_dir;
        end

        function is_inside = is_inside(obj, x, y, z, zi)
            % This function checks if the aircraft is inside the updraft.
            % Inputs:
            % x = Aircraft x position (m)
            % y = Aircraft y position (m)
            % z = Aircraft height above ground (m)
            % Outputs:
            % is_inside = Boolean value indicating if the aircraft is inside the updraft

            is_inside = obj.distance_to(x,y) < obj.outer_radius(z,zi);
            
        end

        function ptemp_diff = ptemp_diff(obj,x,y)
            % This function calculates the potential temperature difference at the location x,y.
            % Outputs:
            % ptemp_diff = Potential temperature difference at the aircraft's position

            % Get the angle and relative distance of the aircraft to the updraft
            theta = obj.angle_to(x,y);
            rel_dist = obj.distance_to(x,y) ./ obj.outer_radius(0,0);
            rel_dist_uw = rel_dist.*cos(theta*pi/180);
            rel_dist_cw = rel_dist.*sin(theta*pi/180);
            
            % Calculate the potential temperature difference at the aircraft's position
            % by averaging the upwind and crosswind profiles based on the angle to the updraft
            ptemp_uw = obj.coeff_uw(1,1) + obj.coeff_uw(1,2)*cos(rel_dist_uw*obj.coeff_uw(1,6)) + obj.coeff_uw(1,3)*sin(rel_dist_uw*obj.coeff_uw(1,6)) + obj.coeff_uw(1,4)*cos(2*rel_dist_uw*obj.coeff_uw(1,6)) + obj.coeff_uw(1,5)*sin(2*rel_dist_uw*obj.coeff_uw(1,6));
            ptemp_cw = obj.coeff_cw(1,1) + obj.coeff_cw(1,2)*cos(rel_dist_cw*obj.coeff_cw(1,6)) + obj.coeff_cw(1,3)*sin(rel_dist_cw*obj.coeff_cw(1,6)) + obj.coeff_cw(1,4)*cos(2*rel_dist_cw*obj.coeff_cw(1,6)) + obj.coeff_cw(1,5)*sin(2*rel_dist_cw*obj.coeff_cw(1,6));
            
            ptemp_diff = cos(theta*pi/180)^2 * ptemp_uw + sin(theta*pi/180)^2 * ptemp_cw;

            % Multiply by ramp function if the aircraft is outside the updraft, such that the potential
            % temperature difference is multiplied by 1 at the outer radius and by zero at a distance of 3 outer radii 
            if obj.distance_to(x,y) > obj.outer_radius(0,0) && obj.distance_to(x,y) <= 3 * obj.outer_radius(0,0)
                ptemp_diff = ptemp_diff * (1 - (obj.distance_to(x,y) - obj.outer_radius(0,0)) / (2*obj.outer_radius(0,0)));
            elseif obj.distance_to(x,y) > 3 * obj.outer_radius(0,0)
                ptemp_diff = 0;
            end
        end

        function humidity_diff = humidity_diff(obj,x,y)
            % This function calculates the specific humidity difference at the aircraft's position.
            % Outputs:
            % humidity_diff = Specific humidity difference at the aircraft's position

            % Get the angle and relative distance of the aircraft to the updraft
            theta = obj.angle_to(x,y);
            rel_dist = obj.distance_to(x,y) / obj.outer_radius(0,0);
            rel_dist_uw = rel_dist*cos(theta*pi/180);
            rel_dist_cw = rel_dist*sin(theta*pi/180);

            % Calculate the specific humidity difference at the aircraft's position
            hum_uw = obj.coeff_uw(2,1) + obj.coeff_uw(2,2)*cos(rel_dist_uw*obj.coeff_uw(2,6)) + obj.coeff_uw(2,3)*sin(rel_dist_uw*obj.coeff_uw(2,6)) + obj.coeff_uw(2,4)*cos(2*rel_dist_uw*obj.coeff_uw(2,6)) + obj.coeff_uw(2,5)*sin(2*rel_dist_uw*obj.coeff_uw(2,6));
            hum_cw = obj.coeff_cw(2,1) + obj.coeff_cw(2,2)*cos(rel_dist_cw*obj.coeff_cw(2,6)) + obj.coeff_cw(2,3)*sin(rel_dist_cw*obj.coeff_cw(2,6)) + obj.coeff_cw(2,4)*cos(2*rel_dist_cw*obj.coeff_cw(2,6)) + obj.coeff_cw(2,5)*sin(2*rel_dist_cw*obj.coeff_cw(2,6));

            humidity_diff = cos(theta*pi/180)^2 * hum_uw + sin(theta*pi/180)^2 * hum_cw;

            % Multiply by ramp function if the aircraft is outside the updraft, such that the humidity
            % difference is multiplied by 1 at the outer radius and by zero at a distance of 3 outer radii 
            if obj.distance_to(x,y) > obj.outer_radius(0,0) && obj.distance_to(x,y) <= 3 * obj.outer_radius(0,0)
                humidity_diff = humidity_diff * (1 - (obj.distance_to(x,y) - obj.outer_radius(0,0)) / (2*obj.outer_radius(0,0)));
            elseif obj.distance_to(x,y) > 3 * obj.outer_radius(0,0)
                humidity_diff = 0;
            end
        end
    end

    methods (Static)
        function coeff = load_coeff_uw()
            % load fourier coefficients from .mat file
            data = load("coeff_uw.mat", "coeff_uw");
            % error if cannot load coefficients
            if isempty(data)
                error("Cannot load coefficients");
            end
            % error if coefficients are empty
            if isempty(data.coeff_uw)
                error("Coefficients are empty");
            end

            coeff = data.coeff_uw;

            % create vector of random perturbations
            perturbation = [randn(1, 6) * 0.2 + 1; randn(1, 6) * 0.2 + 1];

            % multiply coefficients by perturbation
            coeff = coeff .* perturbation;
        end
        function coeff = load_coeff_cw()
            % load fourier coefficients from .mat file
            data = load("coeff_cw.mat", "coeff_cw");
            % error if cannot load coefficients
            if isempty(data)
                error("Cannot load coefficients");
            end
            % error if coefficients are empty
            if isempty(data.coeff_cw)
                error("Coefficients are empty");
            end

            coeff = data.coeff_cw;

            % create vector of random perturbations
            perturbation = [randn(1, 6) * 0.2 + 1; randn(1, 6) * 0.2 + 1];

            % multiply coefficients by perturbation
            coeff = coeff .* perturbation;
        end
    end
end

