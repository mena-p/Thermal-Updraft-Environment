# Before starting...
Ensure you are running Matlab and Simulink version 2024b and have installed the [Aerospace Blockset](https://ch.mathworks.com/products/aerospace-blockset.html), the [Aerospace Toolbox](https://ch.mathworks.com/products/aerospace-toolbox.html), the [Curve Fitting Toolbox](https://ch.mathworks.com/products/curvefitting.html), the [Mapping Toolbox](https://www.mathworks.com/products/mapping.html), and the [Global Optimization Toolbox](https://www.mathworks.com/products/global-optimization.html).
Clone the repository to your machine.

# Using the environment
Double-click the ThermalUpdraftModel.prj project file to open the project. This will open the GUI, the Simulink model, and the data inspector. 

You can use the GUI to set up the simulation. Load an IGC file, run the automatic thermal detection or add thermals manually, and search for atmospheric soundings on the day of the flight. Select at least one sounding from the table and send the data to the model. 

Run the model and visualize the simulation's output in the simulation data inspector or in the Simulation tab of the GUI. 

If you wish to run the model directly using sensor data instead, do the setup normally but run the prepare_sensor_data.m script at the end (found in the Data preparation directory). The sensor data should be in the same format as the "pedro_csv" file Leo created. It can be found in the Raw data folder. Then, select the "use flight test data" variant of the sensor model, and run the simulation normally.

The thermal detection algorithm should be implemented in the "SoarSense" block.

Note: ALWAYS launch and use the GUI from the root directory of the project. An in-depth explanation of the GUI can be found on chapter 3 of the thesis.

# Improving the thermal model fits
The fit_thermal.mlx script can be used to improve the thermal model derived in chapter 5 of the thesis. It includes the necessary instructions. You will find it in the data preparation directory.

# Re-tuning the sensor models
To re-tune the sensor models, use the tuneSensors.m script found in the Sensor directory. The sounding data used to tune can be extracted from a sounding using the GUI, and the sensor data should be provided in the same format as the file created by Leo, "pedro_csv", found in the raw data directory. 
