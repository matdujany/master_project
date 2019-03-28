//loadcells macro functions to easily show their values



//sends bytes until the end byte is reached. 
//Then, if a frame is found in the buffer, it is parsed and the values of the LC and IMU are updated
//returns boolean true if frame found, false otherwise

boolean send_frame_and_update_loadcells_old(){
  boolean update_success = false;
  while (!bool_end_byte_sent)
    send_frame_byte(flagVerbose);
  while (Serial2.available())
  {
    // Reads one byte from the rx port of Serial2 (load cells and IMU)
    get_loadcell_byte(0);

    // Boolean to check if frame has been found
    frame_found = check_frame(flagVerbose);
  }
  if (frame_found){
    wrapper_parser(flagVerbose);
    // Start of HEX to DEC conversion
    // First argument: flagVerbose, second argument: conversion mode
    // Mode 1: loadcell mode, Mode 2: IMU mode
    hex_to_float(flagVerbose, 1);
    hex_to_float(flagVerbose, 2);
    update_success = true;
  }
  else
    SerialUSB.println("No frame found");
  bool_end_byte_sent = false;
  return update_success;
}

void send_frame_and_update_loadcells(){
  frame_found = false; //set to false because we want to update it
  while (!frame_found){
    try_capture_1_frame();
  }
  SerialUSB.println("new frame success, updating loadcell values");
  wrapper_parser(flagVerbose);
  // Start of HEX to DEC conversion
  // First argument: flagVerbose, second argument: conversion mode
  // Mode 1: loadcell mode, Mode 2: IMU mode
  hex_to_float(flagVerbose, 1);
  hex_to_float(flagVerbose, 2);
  
}


//update the values of the LC and prints their latest values.
void show_value_LC(unsigned long delay_updates){
  send_frame_and_update_loadcells();
  print_loadcell_values();
  delay(delay_updates);
}

//measure the mean LC values (over nb_values_mean), with a delay (delay_frames) between each measure
void measure_mean_values_LC(uint8_t nb_values_mean, unsigned long delay_frames){
  uint8_t nb_captured_values = 0;
  float mean_values_LC[3*n_ard];
  for (int i=0; i<3*n_ard; i++){
    mean_values_LC[i] = 0;
  }
  //measuring a mean value
  while (nb_captured_values<nb_values_mean){
    send_frame_and_update_loadcells();
    for (int i=0; i<3*n_ard; i++){
      mean_values_LC[i] += ser_rx_buf.last_loadcell_data_float[i]/(float)nb_values_mean;
    }
    nb_captured_values++;
    delay(delay_frames);
  }
  //printing results
  for (int i_ard =0; i_ard<n_ard; i_ard++){
    SerialUSB.print("Loadcell ");SerialUSB.print(i_ard);
    SerialUSB.print(" mean channel values ");
    for (int j =0; j<3; j++){
      SerialUSB.print(mean_values_LC[j+3*i_ard]);
      SerialUSB.print("\t");
    }
    SerialUSB.println();
  }
  SerialUSB.println();
}