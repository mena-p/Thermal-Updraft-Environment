classdef Updraft
    properties
        latitude {mustBeNumeric}
        longitude {mustBeNumeric}
        gain {mustBeNumeric}
        timeSinceFormation {mustBeNumeric}
        wind_dir {mustBeNumeric}
        coeff_uw {mustBeNumeric}
        coeff_cw {mustBeNumeric}
        mean_radius {mustBeNumeric}
        radius_uw {mustBeNumeric}
        radius_cw {mustBeNumeric}
    end

    methods
        function obj = Updraft(lat, lon, zi)
            obj.latitude = lat;
            obj.longitude = lon;
            obj.gain = max(0.25,1+randn(1));
            obj.timeSinceFormation = 0;
            obj.wind_dir = rand(1)*360;
            obj.coeff_uw = Updraft.load_coeff_uw();
            obj.coeff_cw = Updraft.load_coeff_cw();
            obj.mean_radius = outer_radius(obj,zi);
            obj.radius_uw = downwind_radius(obj,zi);
            obj.radius_cw = crosswind_radius(obj,zi);
        end

        function outer_radius = outer_radius(obj,zi)
            % This function calculates the outer radius of the updraft at a given height.
            % Inputs:
            % z = Aircraft height above ground (m)
            % zi = Mixed layer height (m)
            % Outputs:
            % outer_radius = Outer radius of the updraft at the given height (m)
            % 
            % The outer radius is fixed since Hardt's model does not include 
            % a vertical profile of the updraft size

            % This is the mean radius, the crosswind and downwind radii still need to be calculated
            outer_radius = 0.5 * (0.4 + 0.6*rand(1)) * zi;
        end

        function inner_radius = inner_radius(obj,zi)
            % This function calculates the outer radius of the updraft at a given height.
            % Inputs:
            % z = Aircraft height above ground (m)
            % zi = Mixed layer height (m)
            % Outputs:
            % outer_radius = Outer radius of the updraft at the given height (m)

            % The inner radius is zero since Hardt's model does not include
            % an inner radius
            inner_radius = 0;
        end

        function dw_radius = downwind_radius(obj,zi)
            % This function calculates the downwind radius of the updraft at a given height.
            % Inputs:
            % z = Aircraft height above ground (m)
            % zi = Mixed layer height (m)
            % Outputs:
            % dw_radius = Downwind radius of the updraft at the given height (m)

            % The downwind radius is fixed since Hardt's model does not include 
            % a vertical profile of the updraft size
            dw_radius = 4/3 * obj.mean_radius;
        end

        function cw_radius = crosswind_radius(obj,zi)
            % This function calculates the crosswind radius of the updraft at a given height.
            % Inputs:
            % z = Aircraft height above ground (m)
            % zi = Mixed layer height (m)
            % Outputs:
            % cw_radius = Crosswind radius of the updraft at the given height (m)

            % The crosswind radius is fixed since Hardt's model does not include 
            % a vertical profile of the updraft size
            cw_radius = 2/3 * obj.mean_radius;
        end

        function dist = distance_to(obj, lat, lon)
            % This function calculates the linear distance from the aircraft to the updraft
            % on a wgs84 ellipsoid.
            % Inputs:
            % lat = Aircraft latitude (degrees)
            % lon = Aircraft longitude (degrees)
            % Outputs:
            % dist = Distance from the aircraft to the updraft (m)
            wgs84 = wgs84Ellipsoid();
            coder.extrinsic('distance');
            dist = zeros(1);
            dist = distance(lat, lon, obj.latitude, obj.longitude, wgs84);
        end

        function dist = elliptical_dist_to(obj, lat, lon)
            
            % returns 1 if the point is at the boundary of the thermal, 2
            % if at the boundary of a thermal twice as large, etc.                     

            % convert lat/lon to local NED centered at updraft position
            [x,y,~] = geodetic2ned(lat, lon, 0, obj.latitude, obj.longitude, 0, wgs84Ellipsoid());
            alpha = obj.wind_dir;
            rx = obj.radius_uw;
            ry = obj.radius_cw;       

            dist = ((x)*cosd(alpha) + (y)*sind(alpha)).^2/rx^2 + ((x)*sind(alpha) - (y)*cosd(alpha)).^2/ry^2;
        end

        function angle_from_updraft = angle_to(obj, lat, lon)
            % This function calculates the angle of the rhumb line connecting
            % the updraft center to the aircraft's position and the upwind
            % direction of the updraft (wind_dir).
            % Inputs:
            % lat = Aircraft latitude (degrees)
            % lon = Aircraft longitude (degrees)
            % Outputs:
            % angle_to_updraft (degrees)
            wsg84 = wgs84Ellipsoid();
            coder.extrinsic('azimuth');
            angle_to_north = zeros(1);
            angle_to_north = azimuth("rh",lat,lon,obj.latitude,obj.longitude,wsg84,"degrees");
            angle_from_updraft = angle_to_north - obj.wind_dir;
            if angle_from_updraft < 0
                angle_from_updraft = angle_from_updraft + 360;
            end
        end

        function is_inside = is_inside(obj, lat, lon, alt, zi)
            % This function checks if the aircraft is inside the updraft.
            % Inputs:
            % lat = Aircraft latitude (degrees)
            % lon = Aircraft longitude (degrees)
            % alt = Aircraft height above ground (m)
            % Outputs:
            % is_inside = Boolean value indicating if the aircraft is inside the updraft
            
            %is_inside = obj.distance_to(lat,lon) < obj.outer_radius(zi);
            
            is_inside = elliptical_dist_to(obj, lat, lon) <= 1;
        end

        function ptemp_diff = ptemp_diff(obj,lat,lon)
            % This function calculates the potential temperature difference at the location lat,lon.
            % Outputs:
            % ptemp_diff = Potential temperature difference at the aircraft's position

            % Get the angle and relative distance of the aircraft to the updraft
            theta = obj.angle_to(lat,lon);
            dist = obj.distance_to(lat,lon);

            % Calculate the x and y components of the distance vector from the updraft to the aircraft
            deltaX = cosd(theta) * dist;
            deltaY = sind(theta) * dist;

            % Normalize from an ellipse to a circle
            deltaX = deltaX/obj.radius_uw;
            deltaY = deltaY/obj.radius_cw;

            % Calculate relative distance from the updraft in the unit circle
            rel_dist = sqrt(deltaX^2 + deltaY^2);
            
            % Calculate the potential temperature difference at the aircraft's position
            % by averaging the upwind and crosswind profiles based on the angle to the updraft
            ptemp_uw = obj.coeff_uw(1,1) + ...
                obj.coeff_uw(1,2)*cos(rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,3)*sin(rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,4)*cos(2*rel_dist*obj.coeff_uw(1,18)) ...
                + obj.coeff_uw(1,5)*sin(2*rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,6)*cos(3*rel_dist*obj.coeff_uw(1,18)) ...
                + obj.coeff_uw(1,7)*sin(3*rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,8)*cos(4*rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,9)*sin(4*rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,10)*cos(5*rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,11)*sin(5*rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,12)*cos(6*rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,13)*sin(6*rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,14)*cos(7*rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,15)*sin(7*rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,16)*cos(8*rel_dist*obj.coeff_uw(1,18))...
                + obj.coeff_uw(1,17)*sin(8*rel_dist*obj.coeff_uw(1,18));

            ptemp_cw = obj.coeff_cw(1,1) + ...
                obj.coeff_cw(1,2)*cos(rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,3)*sin(rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,4)*cos(2*rel_dist*obj.coeff_cw(1,18)) ...
                + obj.coeff_cw(1,5)*sin(2*rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,6)*cos(3*rel_dist*obj.coeff_cw(1,18)) ...
                + obj.coeff_cw(1,7)*sin(3*rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,8)*cos(4*rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,9)*sin(4*rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,10)*cos(5*rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,11)*sin(5*rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,12)*cos(6*rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,13)*sin(6*rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,14)*cos(7*rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,15)*sin(7*rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,16)*cos(8*rel_dist*obj.coeff_cw(1,18))...
                + obj.coeff_cw(1,17)*sin(8*rel_dist*obj.coeff_cw(1,18));
            
            % Average based on angle
            ptemp_diff = obj.gain*(cos(theta*pi/180)^2 * ptemp_uw...
                + sin(theta*pi/180)^2 * ptemp_cw);

            % Multiply by ramp function if the aircraft is outside the updraft, such that the potential
            % temperature difference is multiplied by 1 at the outer radius and by zero at a distance of 3 outer radii
            dist = elliptical_dist_to(obj, lat, lon);
            if dist > 1 && dist <= 3
                ptemp_diff = ptemp_diff * (1.5 - 0.5 * dist);	
            elseif dist > 3
                ptemp_diff = 0;
            end
        end

        function humidity_diff = humidity_diff(obj,lat,lon)
            % This function calculates the specific humidity difference at the aircraft's position.
            % Outputs:
            % humidity_diff = Specific humidity difference at the aircraft's position

            % Get the angle and relative distance of the aircraft to the updraft
            theta = obj.angle_to(lat,lon);
            dist = obj.distance_to(lat,lon);

            % Calculate the x and y components of the distance vector from the updraft to the aircraft
            deltaX = cosd(theta) * dist;
            deltaY = sind(theta) * dist;

            % Normalize from an ellipse to a circle
            deltaX = deltaX/obj.radius_uw;
            deltaY = deltaY/obj.radius_cw;

            % Calculate relative distance from the updraft in the unit circle
            rel_dist = sqrt(deltaX^2 + deltaY^2);

            % Calculate the specific humidity difference at the aircraft's position
            hum_uw = obj.coeff_uw(2,1) + ...
                obj.coeff_uw(2,2)*cos(rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,3)*sin(rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,4)*cos(2*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,5)*sin(2*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,6)*cos(3*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,7)*sin(3*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,8)*cos(4*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,9)*sin(4*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,10)*cos(5*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,11)*sin(5*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,12)*cos(6*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,13)*sin(6*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,14)*cos(7*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,15)*sin(7*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,16)*cos(8*rel_dist*obj.coeff_uw(2,18))...
                + obj.coeff_uw(2,17)*sin(8*rel_dist*obj.coeff_uw(2,18));

            hum_cw = obj.coeff_cw(2,1) + ...
                obj.coeff_cw(2,2)*cos(rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,3)*sin(rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,4)*cos(2*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,5)*sin(2*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,6)*cos(3*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,7)*sin(3*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,8)*cos(4*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,9)*sin(4*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,10)*cos(5*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,11)*sin(5*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,12)*cos(6*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,13)*sin(6*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,14)*cos(7*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,15)*sin(7*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,16)*cos(8*rel_dist*obj.coeff_cw(2,18))...
                + obj.coeff_cw(2,17)*sin(8*rel_dist*obj.coeff_cw(2,18));
            
            % Average based on angle
            humidity_diff = obj.gain*(cos(theta*pi/180)^2 * hum_uw ...
                + sin(theta*pi/180)^2 * hum_cw);

            % Multiply by ramp function if the aircraft is outside the updraft, such that the potential
            % temperature difference is multiplied by 1 at the outer radius and by zero at a distance of 3 outer radii
            % Size of ellipsed that passes through the point
            dist = elliptical_dist_to(obj, lat, lon);
            if dist > 1 && dist <= 3
                humidity_diff = humidity_diff * (1.5 - 0.5 * dist);	
            elseif dist > 3
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
            perturbation = [1 randn(1, 17) * 0.0002 + 1;  1 randn(1, 17) * 0.0002 + 1];

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
            perturbation = [1 randn(1, 17) * 0.0002 + 1;  1 randn(1, 17) * 0.0002 + 1];

            % multiply coefficients by perturbation
            coeff = coeff .* perturbation;
        end
    end
end