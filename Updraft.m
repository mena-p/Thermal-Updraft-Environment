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
    end
end

