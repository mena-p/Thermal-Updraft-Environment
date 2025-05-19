# What is this?
This is a simulation environment that can be used to develop thermal detection and location algorithms for soaring flight. It simulates a glider collecting real-time temperature, humidity and pressure data which can be used to predict the location of thermals. Measurements are made by sensors placed at each wingtip and in the cockpit. The environment has been validated against real-world flight test data.

Atmospheric conditions are modeled by taking real-world data from NOAA's [Integrated Global Radiosonde Archive,](https://www.ncei.noaa.gov/products/weather-balloon/integrated-global-radiosonde-archive) while the temperature and humidity inside thermal updrafts are predicted according to a model developed based on experimental measurements. Multiple sources of measurement error, i.e. the airflow over the sensor and heat transfer between the aircraft and the measurement air are modeled to ensure an accurate prediction of temperature, humidity and pressure, reflecting the quantities a real glider would measure. The models composing the environment were tuned and validated against real-world data obtained from test flights.

<img width="899" alt="Top-level Simulink model" src="https://github.com/user-attachments/assets/bba6c1fb-c5ac-43ba-8f48-86732be454fd" />

# Before starting...
Ensure you are running Matlab and Simulink version 2024b and have installed the [Aerospace Blockset](https://ch.mathworks.com/products/aerospace-blockset.html), the [Aerospace Toolbox](https://ch.mathworks.com/products/aerospace-toolbox.html), the [Curve Fitting Toolbox](https://ch.mathworks.com/products/curvefitting.html), the [Mapping Toolbox](https://www.mathworks.com/products/mapping.html), the [Optimization Toolbox](https://ch.mathworks.com/products/optimization.html), and the [Global Optimization Toolbox](https://www.mathworks.com/products/global-optimization.html).

# Using the environment
Double-click the ThermalUpdraftModel.prj project file to open the project. This will open the GUI, the Simulink model, and the data inspector. 

Note: ALWAYS launch and use the GUI from the root directory of the project. 
Also, you'll need internet access when loading a flight for the first time so that
IGRA data can be downloaded.
An in-depth explanation of the GUI can be found on chapter 3 of the thesis.

![Simulation setup GUI](https://github.com/user-attachments/assets/53f4095e-f09b-4a9b-8067-920cb76e7d6f)

## Setup
You can use the GUI (the window titled "Soarsense") to set up the simulation. 
Begin by clicking the 'Load Flight' button and select an .igc or .mat file in the Flights/ 
folder to load a flight.
Then, place thermals at the desired locations with the detect, add, remove, and remove all thermals buttons. 
Search for atmospheric soundings on the day of the flight using the "find sounding" button. 
This can take a while on the first time a flight is loaded, since the IGRA station files need to be downloaded. 
You can monitor the progress on the command window. Soundings will appear in the table in the GUI.
Select at least one of them and click the "send to model" button.

Run the model and visualize the predicted and actual thermal directions in the Simulation tab of the GUI.
You can also click any of the logged signals or the file "Data Inspector.mldatx
to open the simulation data inspector.

The thermal detection algorithm should be implemented in the "SoarSense" block.

<img width="960" alt="Simulation GUI" src="https://github.com/user-attachments/assets/8f2fb101-ef16-46f7-9c1f-d9f7691efc3b" />

## Running with flight test data
If you wish to run the model directly using sensor data instead, do the setup as above but 
run the prepare_sensor_data.m script at the end (found in the Data preparation directory). 
Note: if you are using another file than the one provided, it should be in the same 
format as the "pedro_csv" file Leo created. It can be found in the Raw data folder. 
Then, open the simulink model and left click the sensor variant subsystem and click "block parameters".
Set the "use flight test data" variant of the sensor model to true and all other to false. 
Run the simulation normally.


# Improving the thermal model fits
The fit_thermal.mlx script can be used to improve the thermal model derived in chapter 5 of the thesis.
It includes the necessary instructions. You will find it in the data preparation directory.

# Re-tuning the sensor models
To re-tune the sensor models, use the tuneSensors.m script found in the Sensor directory.
The script contains the necessary instructions.

Note: if you wish to use other sounding data to tune the sensor, you can use the GUI to find and
download the necessary data. If you're using other sensor data than the one included,
it should be in the same format as the file created by Leo, "pedro_csv", 
found in the raw data directory.
