# Before starting...
Make sure you are running Matlab version 2024a or above and have installed the [Aerospace Blockset](https://ch.mathworks.com/products/aerospace-blockset.html).
Clone the repository to your machine.

# Setting up
After cloning the repository, open the root folder in MATLAB and add the subdirectory `IGRA-Parser` to your PATH by right-clicking it in the "Current Folder" panel and choosing "Add to Path > Selected Folders."

Grab a [derived parameter file](https://www.ncei.noaa.gov/data/integrated-global-radiosonde-archive/access/derived-por/) from NOAA's [Integrated Global Radiosonde Archive](https://www.ncei.noaa.gov/products/weather-balloon/integrated-global-radiosonde-archive) and save it to the root directory. Parsing an entire derived parameter file may take a long time, so testing with a smaller file is recommended.

# Load atmospheric sounding data
The IGRA-Parser parses data from the atmospheric sounding. You can read more about it [here](https://github.com/mena-p/IGRA-Parser).
## Parse and filter a derived parameter file
Open the `load_data_live.mlx` script. Set the `filename` to your derived parameter (or test) file and run the first section of the script. All soundings are extracted from the file and filtered based on the presence of the mixed layer height parameter. An array of sounding objects containing only the soundings that have this parameter is saved to `filtered_soundings.mat` in the root directory, so you do not need to parse this file again in the future.

## Extract data for the Simulink model
Set the `sounding` variable to one of the soundings in the loaded MAT file, e.g., `filtered_soundings.mat(4)`, and run this section. The data needed for the model are extracted and capped at a maximum height, and missing data points are interpolated in a 1-meter interval. Data that are not needed are discarded. Then, the data are loaded into a sounding bus object named `sounding_data_bus` for use in Simulink. The structure of the sounding bus is defined in the file `sounding_bus.mat`. This section must run again if the chosen sounding is changed, or if Matlab restarts.

## Plot the sounding
Optionally, run the plotting section to see what the sounding looks like. Pressure, temperature, virtual temperature, and potential temperature are plotted over geopotential height. Dashed lines mark the mixed layer height and lifting condensation level.

# Open the model
After loading the atmospheric sounding data, the variables `num_Levels` and `sounding_data_bus` should have appeared in your workspace. Other variables are left over, but they are not needed in Simulink.
Open the model `model.slx`. The model has a panel (glider) where you can set initial values for the glider's position and velocity. There is also an airspeed indicator and an altimeter. Use the different scopes to read out data in real-time.
