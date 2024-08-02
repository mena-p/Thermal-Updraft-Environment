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
    end
end

