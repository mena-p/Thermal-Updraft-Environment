# How-to

## Prepare atmospheric sounding data
### Parse and filter a derived parameter file
Grab a [derived parameter file](https://www.ncei.noaa.gov/data/integrated-global-radiosonde-archive/access/derived-por/) from NOAA's [Integrated Global Radiosonde Archive](https://www.ncei.noaa.gov/products/weather-balloon/integrated-global-radiosonde-archive). Open the load_data_live.mlx script. Set the filename to your file and run the first section of the script. All soundings will be extracted from the file and filtered based on the presence of the mixed layer height parameter. An array of the soundings that have this parameter is saved to filtered_soundings.mat, so you do not need to parse this file again in the future.

### Extract data for the Simulink model
Set the "sounding" variable to one of the soundings in the loaded MAT file, and run this section. The data needed for the model is extracted and capped at a maximum height, and missing data points are interpolated in a 1 meter interval. Then, the data is loaded into a sounding bus object named "sounding_data_bus" to be used in Simulink. The sounding bus is defined in the file sounding_bus.mat. 

### Plot the sounding
Optionally, run the plotting section to see how the sounding looks like. Pressure, temperature, virtual temperature and potential temperature are plotted over geopotential height. The mixed layer height and lifting condensation level are marked by dashed lines.

# IGRA-Parser
NOAA's [Integrated Global Radiosonde Archive](https://www.ncei.noaa.gov/products/weather-balloon/integrated-global-radiosonde-archive) is a large archive of atmospheric sounding data. The IGRA-Parser can extract data from sounding or derived parameter files into a more versatile data format for MATLAB. 

The data are extracted into an array of sounding objects, each containing all the information in the sounding, such as station ID, date, time, location, number of measurements, measurement data, etc. The file to be parsed must be in the [sounding file format](https://www.ncei.noaa.gov/data/integrated-global-radiosonde-archive/doc/igra2-data-format.txt) or in the [parameter file format](https://www.ncei.noaa.gov/data/integrated-global-radiosonde-archive/doc/igra2-derived-format.txt) of IGRA v2 or v2.2.

## Usage
See the script main.m for an example.

To parse a sounding or derived parameter file use
```
parsed_soundings = parse_sounding('GMM00010868-data.txt');

parsed_soundings = parse_derived('GMM00010868-drvd.txt');
```
This returns a vector of sounding objects.

To filter soundings based on the presence of the mixed layer height parameter use the function filter_soundings(). It returns a filtered vector of sounding objects.
```
filtered_soundings = filter_soundings(parsed_soundings);
```
If you only need measurements up to a certain height, you can cap the sounding with:
```
capped_sounding = remove_values_above(sounding, max_height);
```
The max_height parameter is interpreted as a height in meters if it is greater than 50. Otherwise, it is interpreted as a factor, and the maximum height is max_height\*mixed layer height.

To plot pressure, temperature, potential temperature and virtual temperature profiles over geopotential height, use the function plot_sounding(). The profiles are plotted up to the height of factor\*mixed layer height. The default factor is 1.3.
```
plot_sounding(sounding, factor);
```
If you are only interested in the mixed layer height, lifting condensation level, geopotential heights, pressure, temperature, potential temperature, virtual temperature, (saturation) vapor pressure, and the relative humidity, you can remove all other values from the sounding with
```
reduced_sounding = extract_sounding_data(sounding);
```

