thermal = Updraft(0,0,1);
thermal2 = Updraft(500,500,1);
thermals = {thermal thermal2};

[T,q,p] = thermal_model(0,0,700,thermals,sounding_data_bus);
