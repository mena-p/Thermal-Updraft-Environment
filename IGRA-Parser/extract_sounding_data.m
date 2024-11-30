function reduced_sounding = extract_sounding_data(sounding)
    % Extract and return only the relevant data in a sounding,
    % and return a reduced sounding object. If a row contains missing
    % reported geopotential height values, they are filled with the
    % corresponding calculated geopotential height values. Rows that
    % still contain missing reported geopotential height values are
    % removed.
    %
    % The following parameters are extracted:
    % - station ID
    % - mixed layer height
    % - lifting condensation level
    % The following profiles are extracted:
    % - geopotential heights
    % - pressure profile
    % - temperature profile
    % - potential temperature profile
    % - virtual temperature profile
    % - vapor pressure profile
    % - saturated vapor pressure profile
    % - relative humidity profile
    %
    % Input: sounding - a sounding object
    % Output: reduced_sounding - a reduced sounding containing only the 
    % extracted values, and no missing geopotential height and humidity values.

    % Initialize a reduced sounding object and copy the relevant attributes
    %reduced_sounding.stationID = sounding.stationID;
    if isfield(sounding, 'lat') && isfield(sounding, 'lon')
        reduced_sounding.lat = sounding.lat;
        reduced_sounding.lon = sounding.lon;
    end
    reduced_sounding.mixedLayerHeight = sounding.mixedLayerHeight;
    reduced_sounding.LCLheight = sounding.LCLheight;

    % Extract the relevant columns from the sounding data table
    reduced_sounding.derived = sounding.derived(:,["REPGPH","CALCGPH","PRESS","TEMP","PTEMP","VTEMP","VAPPRESS","SATVAP","REPRH","CALCRH"]);

    % If a row contains missing REPGPH values, fill it with the corresponding 
    % CALCPGH values
    reduced_sounding.derived.REPGPH(isnan(reduced_sounding.derived.REPGPH)) = reduced_sounding.derived.CALCGPH(isnan(reduced_sounding.derived.REPGPH));

    % If some rows still contain missing REPGPH values, remove them
    reduced_sounding.derived = rmmissing(reduced_sounding.derived,'DataVariables','REPGPH');

    % Remove the CALCGPH column
    reduced_sounding.derived.CALCGPH = [];

    % If a row contains missing REPRH values, fill it with the corresponding 
    % CALCRH values
    reduced_sounding.derived.REPRH(isnan(reduced_sounding.derived.REPRH)) = reduced_sounding.derived.CALCRH(isnan(reduced_sounding.derived.REPRH));

    % If some rows still contain missing REPRH values, remove them
    reduced_sounding.derived = rmmissing(reduced_sounding.derived,'DataVariables','REPRH');

    % Remove the CALCRH column
    reduced_sounding.derived.CALCRH = [];
  
    disp('Extracted and sanitized sounding data')
end