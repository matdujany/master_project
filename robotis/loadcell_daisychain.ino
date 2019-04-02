/* ===================================================================================================================================== */

///////////////////////////////////////////
// 1. LOADCELLS MACRO FUNCTION           //
///////////////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */
//printing loadcell and IMU values adds some delay between the updates
void show_value_DC(unsigned long delay_updates){
  send_frame_and_update_sensors();
  print_loadcell_values();
  print_IMU_values();
  delay(delay_updates);
}


//update the values of the LC and prints their latest values.
void show_value_LC(unsigned long delay_updates){
  send_frame_and_update_sensors();
  print_loadcell_values();
  delay(delay_updates);
}

void send_frame_and_update_sensors(){
  frame_found = false; //set to false because we want to update it
  while (!frame_found){
    try_capture_1_frame(1);
  
    if (flagVerbose){
      SerialUSB.println("Updating sensor values");
    }
  }
  wrapper_parser(flagVerbose);
  // Start of HEX to DEC conversion
  // Mode 1: loadcell mode, Mode 2: IMU mode
  hex_to_float(flagVerbose, 1);
  hex_to_float(flagVerbose, 2);
  correct_IMU_data();
  
}

//measure and prints the mean LC values (over nb_values_mean), with a delay (delay_frames) between each measure
void measure_mean_values_LC(uint8_t nb_values_mean, unsigned long delay_frames){
  uint8_t nb_captured_values = 0;
  float mean_values_LC[3*n_ard];
  for (int i=0; i<3*n_ard; i++){
    mean_values_LC[i] = 0;
  }
  //measuring a mean value
  while (nb_captured_values<nb_values_mean){
    send_frame_and_update_sensors();
    for (int i=0; i<3*n_ard; i++){
      mean_values_LC[i] += ser_rx_buf.last_loadcell_data_float[i]/(float)nb_values_mean;
    }
    nb_captured_values++;
    delay(delay_frames);
  }
  //printing results
  for (int i_ard =0; i_ard<n_ard; i_ard++){
    SerialUSB.print("Loadcell ");SerialUSB.print(i_ard+1);
    SerialUSB.print(" mean channel values ");
    for (int j =0; j<3; j++){
      SerialUSB.print(mean_values_LC[j+3*i_ard]);
      SerialUSB.print("\t");
    }
    SerialUSB.println();
  }
  SerialUSB.println();
}

void compute_duration_daisychain_ms(){
  int nb_values_mean = 100;
  duration_daisychain = 0;
  for (int i=0; i<nb_values_mean; i++ ){
    reinitalize_dc_state();
    unsigned long time_start_trial = millis();
    while(!bool_end_byte_sent){
      send_and_get_wrapper();
    }
    while( (!frame_found) & (millis()-time_start_trial<MAX_DELAY_FRAME) ){
      if (Serial2.available())
        get_dc_byte_wrapper();
    }
    unsigned long duration_trial=  millis()-time_start_trial;
    if (duration_trial>=MAX_DELAY_FRAME){
      SerialUSB.println("Frame fail, the average will be higher");
    }
    duration_daisychain += float(duration_trial)/float(nb_values_mean);
    delay(50);   
  }
  SerialUSB.print("Duration (in ms) daisychain (average over ");
  SerialUSB.print(nb_values_mean);
  SerialUSB.print(" trials), : ");
  SerialUSB.println(duration_daisychain);
}

/* ===================================================================================================================================== */

/////////////////////////////////
// 3. IMU                      //
/////////////////////////////////

void correct_IMU_data(){
  for (int i=0; i<3; i++){
    ser_rx_buf.last_IMU_acc_corrected[i] = ser_rx_buf.last_IMU_data_float[i]-offset_acc[i];
    ser_rx_buf.last_IMU_gyro_corrected[i] = ser_rx_buf.last_IMU_data_float[3+i]-offset_gyro[i];
  }
}


void update_IMU_offsets(){
  SerialUSB.println("Updating IMU offsets");
  switch_frame_IMU_recalib_mode();
  measure_offset_accelerometers(NB_VALUES_MEAN_UPDATE_OFFSET,DELAY_FRAMES_UPDATE_OFFSET);
  switch_frame_all_data_mode();
}

void switch_frame_IMU_recalib_mode(){
  frame_buf.buffer[3]  = FRAME_TYPE_IMU_RECALIB;
  slow_dc_mode = true;
}

void switch_frame_all_data_mode(){
  frame_buf.buffer[3]  = FRAME_TYPE_SENSOR_DATA;
  slow_dc_mode = false;
  
}

void measure_offset_accelerometers(int nb_values_mean, unsigned long delay_frames){
  int nb_captured_values = 0;
  for (int i=0; i<3; i++){
    offset_acc[i] = 0;
    offset_gyro[i] = 0;
  }
  //measuring a mean value
  while (nb_captured_values<nb_values_mean){
    send_frame_and_update_sensors();
    for (int i=0; i<3; i++){
      offset_acc[i] += ser_rx_buf.last_IMU_data_float[i]/(float)nb_values_mean;
      offset_gyro[i] += ser_rx_buf.last_IMU_data_float[3+i]/(float)nb_values_mean;      
    }
    nb_captured_values++;
    delay(delay_frames);
  }
  //printing results
  SerialUSB.print("IMU accelerometer mean channel values ");
  for (int i =0; i<3; i++){
    SerialUSB.print(offset_acc[i]);
    SerialUSB.print("\t");
  }
  SerialUSB.println();

  SerialUSB.print("IMU gyroscope mean channel values ");
  for (int i =0; i<3; i++){
    SerialUSB.print(offset_gyro[i]);
    SerialUSB.print("\t");
  }
  SerialUSB.println();
  SerialUSB.println();

}
/* ===================================================================================================================================== */

/////////////////////////////////
// 3. FRAME HANDLING           //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */


void reinitalize_dc_state(){
  bool_end_byte_sent = false;
  frame_buf.head=0;
  frame_found = false;  
}

void time_daisychain_run_init(){
  SerialUSB.println(try_capture_1_frame(0));
  delay(100);
}



unsigned long try_capture_1_frame(int flagVerbose){
  reinitalize_dc_state();
  unsigned long time_start_trial = millis();
  while(!bool_end_byte_sent){
    send_and_get_wrapper();
  }
  while( (!frame_found) & (millis()-time_start_trial<2*duration_daisychain) ){
    if (Serial2.available())
      get_dc_byte_wrapper();
  }
  unsigned long time_stop = millis()-time_start_trial;
  if (flagVerbose){
    if  (!frame_found) {
      SerialUSB.println("no frame found !");
    }
    else{
      SerialUSB.print("frame found in "); SerialUSB.print(time_stop);
      SerialUSB.println(" ms");
    }
  }
  return time_stop;
}


void send_and_get_wrapper()
{
  send_frame_byte(flagVerbose); //flagVerbose
  if (Serial2.available())
    get_dc_byte_wrapper();
}

void get_dc_byte_wrapper(){
  // Reads one byte from the rx port.
  get_loadcell_byte(flagVerbose); //flagVerbose
  // Boolean to check if frame has been found
  frame_found = check_frame(flagVerbose); //flagVerbose
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void send_frame_byte(int flagVerbose)
{
  // Write 1 frame byte to the Serial2 tx bus

  byte sendOut;
  sendOut = frame_buf.buffer[frame_buf.head];
  
  if (flagVerbose)
  {
    SerialUSB.print("Frame buffer head index: ");
    SerialUSB.print(frame_buf.head);
    SerialUSB.print(", send out: ");
    SerialUSB.println(sendOut);
  }

  // If the last byte of the frame is being send: switch bool_end_byte_sent to true
  if (frame_buf.head == frame_buf.frame_size - 1)
  {
    bool_end_byte_sent = true;
    nb_end_bytes_sent++;
  }

  // Update the head of the circular frame array
  frame_buf.head = ((frame_buf.head + 1) % frame_buf.frame_size);


  Serial2.write(sendOut);
  if (slow_dc_mode){
    count_sent_byte ++;
    if (count_sent_byte>20){
      delay(1);
      count_sent_byte = 0;
      //SerialUSB.println("slowing down emisssion to help ...");
    }
  }

}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void get_loadcell_byte(int flagVerbose)
{
  // Read byte from USART buffer and write it to ring buffer

  // Read byte from the USART buffer
  byte inByte = Serial2.read();

  // Update the head and index
  ser_rx_buf.head = BUFFER_NEXT(ser_rx_buf.head);

  // Write the read byte to the ring buffer
  ser_rx_buf.buffer[ser_rx_buf.head] = inByte;

  // Verbose mode
  if (flagVerbose)
  {
    SerialUSB.print("Received: "); SerialUSB.println(inByte);
    //print_get_loadcell_byte(inByte);
    if (inByte == END_FRAME)  
    {
    print_buffer();
    /*
    bool temp_frame_found = check_frame(1);
    while(!SerialUSB.available());
    while (SerialUSB.available()){
      SerialUSB.read();
    */ 
    }
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
int check_frame(int flagVerbose)
{
  // Check if a frame is collected
  // There are 4 conditions, comparing:   1. End byte
  //                                      2. First start byte
  //                                      3. Second start byte
  //                                      4. Checksum comparison

  if (flagVerbose){
    //SerialUSB.print("Head index: "); SerialUSB.print(ser_rx_buf.head);
    //SerialUSB.print(", value : "); SerialUSB.print(ser_rx_buf.buffer[ser_rx_buf.head]);
  }
  // 1. End byte
  if (ser_rx_buf.buffer[ser_rx_buf.head] == END_FRAME)
  {
    int idx_tail_tmp = ((ser_rx_buf.head - frame_buf.frame_size+1) & (BUFFER_SIZE - 1));
    if (flagVerbose){
      SerialUSB.print("potential tail index: "); SerialUSB.print(idx_tail_tmp);
    }
    // 2. First start byte
    if (ser_rx_buf.buffer[idx_tail_tmp] == FRAME_SYNC_0) // Reads first start byte (0xFF)
    {
      // 3. Second start byte
      if (ser_rx_buf.buffer[(idx_tail_tmp+1) & (BUFFER_SIZE - 1)] == FRAME_SYNC_1) // Reads first start byte (0xAA)
      {
        // Determine new tail and make sure it is circular
        ser_rx_buf.tail = idx_tail_tmp;
        if (flagVerbose){
          SerialUSB.print("confirmed tail index: "); SerialUSB.print(ser_rx_buf.tail);
        }

        // Calculate checksum for the data in the ser_rx_buf buffer
        bool_checksum = check_checksum(flagVerbose);

        // 4. Checksum comparison
        if (bool_checksum)
        {
          if (flagVerbose)
          {
            //print_check_frame();
          }
          //SerialUSB.println("Frame found!");
          nb_frames_found++;
          return true;
        }
        else
          return false;
      }
      else
        return false;
    }
    else
      return false;
  }
  else
    return false;
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
boolean check_checksum(int flagVerbose)
{
  // Compare checksum that is found in the frame (checksum_frame) to the checksum as calculated from the data bytes in the frame (checksum_calc)

  // Declare variables
  uint8_t checksum_calc = 0x00;
  uint8_t checksum_frame;
  if (ser_rx_buf.head==0){
    checksum_frame= ser_rx_buf.buffer[BUFFER_SIZE - 1];
  }
  else
  {
    checksum_frame=ser_rx_buf.buffer[ser_rx_buf.head - 1];
  }
  
  int i_lim;
  int tmp_count;
  bool ismatch;

  // Select dataset in the unparsed frame to calculate checksum
  // Indices of data: 5 to MAX_NR_ARDUINO*SENSOR_DATA_LENGTH+IMU_DATA_LENGTH + 5
  int i_data_start = ser_rx_buf.tail + 5;

  // Total Data Length                                 // Index of start of data
  for (int i = i_data_start; i < (n_ard * SENSOR_DATA_LENGTH + IMU_DATA_LENGTH) + (5 + ser_rx_buf.tail); i++)
  {

    // Correct index in case i > BUFFER_SIZE
    i_lim = i & (BUFFER_SIZE - 1);

    checksum_calc += ser_rx_buf.buffer[i_lim];
  }

  // Apply return criteria
  if (checksum_calc == checksum_frame)
  {
    ismatch = true;
  }
  else
  {
    count_checksum_mismatches++;
    ismatch = false;
  }

  if (flagVerbose)
  {
    print_check_checksum(ismatch, checksum_calc, checksum_frame);
  }
  return ismatch;
}


/* ===================================================================================================================================== */
