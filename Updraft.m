classdef Updraft
    properties
        xPosition {mustBeNumeric}
        yPosition {mustBeNumeric}
        gain {mustBeNumeric}
        timeSinceFormation {mustBeNumeric}
    end
    
    methods
        function obj = Updraft(x, y, gain)
            obj.xPosition = x;
            obj.yPosition = y;
            obj.gain = gain;
            obj.timeSinceFormation = 0;
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
            if r2 < 600
                r1r2 = .0011 * r2 + .14;
            else
                r1r2 = .8;
            end
            inner_radius = r1r2 * r2;
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
        function is_inside = is_inside(obj, x, y, z)
            % This function checks if the aircraft is inside the updraft.
            % Inputs:
            % x = Aircraft x position (m)
            % y = Aircraft y position (m)
            % z = Aircraft height above ground (m)
            % Outputs:
            % is_inside = Boolean value indicating if the aircraft is inside the updraft

            is_inside = false;
            % Check if the aircraft is inside the updraft
            if obj.distance_to(x,y) < obj.outer_radius(z,zi)
                is_inside = true;
            end
        end
    end
end
