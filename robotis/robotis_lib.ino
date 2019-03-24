/* ===================================================================================================================================== */
//
///////////////////////////////////////////////////////////////////////////
// LEARNING TO WALK: CONTROL OF ARBITRARY STRUCTURES IN MODULAR ROBOTICS //
///////////////////////////////////////////////////////////////////////////
//
// This file contains the functions used in the robotis main file. The library consist of the following parts:
// 1. INITIALIZATION
// 2. FRAME HANDLING
// 3. DATA PROCESSING
// 4. BLUETOOTH
// 5. DYNAMIXEL
// 6. TWITCHING AND LEARNING
// 7. DEBUG TOOLS
// 8. PRINT FUNCTIONS
//
//
// TO DO:
// - Replace parts of the code with push_byte where possible
// - update_oscillators_tegotae(): Replace hardcoded mapping by learned mapping
//
/* ------------------------------------------------------------------------------------------------------------------------------------- */

/* ===================================================================================================================================== */

/////////////////////////////////
// 1. INITIALIZATION           //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void init_ring_buffer()
{
  // initialize the ringbuffer

  ser_rx_buf.head = -1;
  ser_rx_buf.tail = 0;

  for (int i = 0; i < BUFFER_SIZE; i++) // init all buffer to 0
  {
    ser_rx_buf.buffer[i] = 0; // initialize the history to the same value... History of value is not used for position control.. but, useful for speed control
  }
}
/* ------------------------------------------------------------------------------------------------------------------------------------- */
void construct_initial_frame()
{
  //constructs the initial frame for the maximal number of arduinos loadcell

  // Fill in the initial frame
  initial_frame[0] = FRAME_SYNC_0;                                          // First start byte
  initial_frame[1] = FRAME_SYNC_1;                                          // Second start byte
  initial_frame[2] = 0;                                                     // Arduino ID
  initial_frame[3] = FRAME_TYPE_SENSOR_DATA;                                // Frame Type
  initial_frame[4] = SENSOR_DATA_LENGTH * MAX_NR_ARDUINO + IMU_DATA_LENGTH; // Data size

  // Filling in zeros as initial data for the load cells
  for (int i = 0; i < MAX_NR_ARDUINO; i++)
  {
    for (int j = 0; j < SENSOR_DATA_LENGTH; j++)
    {
      initial_frame[5 + j + (i * 13)] = 0;
    }
  }

  // Filling in zeros as initial data for the IMU
  for (int j = 0; j < IMU_DATA_LENGTH; j++)
  {
    initial_frame[5 + MAX_NR_ARDUINO * SENSOR_DATA_LENGTH + j] = 0;
  }

  // Fill in checksum as zero and lastly the end frame
  initial_frame[5 + MAX_NR_ARDUINO * SENSOR_DATA_LENGTH + IMU_DATA_LENGTH] = 0;
  initial_frame[5 + MAX_NR_ARDUINO * SENSOR_DATA_LENGTH + 1 + IMU_DATA_LENGTH] = END_FRAME;
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void init_circular_frame_array()
{
  // Initialize circular frame array

  // Initialize head
  frame_buf.head = 0;

  // Initialize frame array by taking the initial_frame
  for (int i = 0; i < MAX_FRAME_SIZE; i++)
  {
    frame_buf.buffer[i] = initial_frame[i];
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void reset_circular_frame_array()
{
  // Set new properties of circular frame array to make the frame tailor fit.

  // Use the number of detected Arduino's to:
  // 1. Set correct data length. Necessary to fill in the data correctly.
  frame_buf.buffer[4] = n_ard * SENSOR_DATA_LENGTH + IMU_DATA_LENGTH;

  // 2. Set the number of indices that needs to be skipped
  idx_skip = (MAX_NR_ARDUINO - n_ard) * SENSOR_DATA_LENGTH;

  // Put the setup in the initial state for a fresh start /////////////////////
  // Reset frame found boolean
  frame_found = false;

  // Reset the frame buffer head, which is needed in order to make cutting the empty cells work
  frame_buf.head = 0;

  // Flush the pipes
  Serial1.flush();
  Serial2.flush();
  Serial3.flush();
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void sleep_while_moving()
{
  // Sleep as long as servo's are moving

  int32_t n_moving = 1;

  while (n_moving > 0)
  {
    n_moving = 0;

    for (int k = 0; k < n_servos; k++)
    {
      n_moving += is_moving(id[k]);
    }
  }
  delay(250);
}

/* ===================================================================================================================================== */

/////////////////////////////////
// 2. FRAME HANDLING           //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

boolean send_frame_and_update_loadcells(){
  boolean update_success = false;
  while (!bool_end_byte_sent)
    send_frame_byte(1, 0);
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
    update_success = true;
  }
  else
    SerialUSB.println("No frame found");
  bool_end_byte_sent = false;
  return update_success;
}

void capture_frame(unsigned long delay_frames){
  while (!bool_end_byte_sent)
    send_frame_byte(1, 0);
  while(Serial2.available())
  {
    // Reads one byte from the rx port of Serial2 (load cells and IMU)
    get_loadcell_byte(0);

    // Boolean to check if frame has been found
    frame_found = check_frame(flagVerbose);
    if (frame_found)
      break;
  }
  if (frame_found){
    wrapper_parser(flagVerbose);

    // Start of HEX to DEC conversion
    // First argument: flagVerbose, second argument: conversion mode
    // Mode 1: loadcell mode, Mode 2: IMU mode
    hex_to_float(flagVerbose, 1);
    
    print_loadcell_values();
  }
  else
    SerialUSB.println("No frame found");
  delay(delay_frames);
  bool_end_byte_sent = false;
}

void show_value_LC(){
  boolean update_success = send_frame_and_update_loadcells();
  while (!update_success)
    update_success = send_frame_and_update_loadcells();
  print_loadcell_values();
}

void measure_mean_values_LC(uint8_t nb_values_mean, unsigned long delay_frames){
  uint8_t nb_captured_values = 0;
  float mean_values_LC[3*n_ard];
  for (int i=0; i<3*n_ard; i++){
    mean_values_LC[i] = 0;
  }
  boolean update_success = false;
  //measuring a mean value
  while (nb_captured_values<nb_values_mean){
    update_success = send_frame_and_update_loadcells();
    if (update_success){
      for (int i=0; i<3*n_ard; i++){
        mean_values_LC[i] += ser_rx_buf.last_loadcell_data_float[i]/(float)nb_values_mean;
      }
      nb_captured_values++;
    }
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

void send_and_get_wrapper(boolean bool_send)
{
  // Wrapper for sending and getting frame bytes

  // Send a initial_frame byte through tx port
  if (bool_send)
  {
    send_frame_byte(1, flagVerbose);
  }

  // Checks if there is data in the USART Buffer and transport it to the ring buffer
  if (Serial2.available())
  {

    // Reads one byte from the rx port.
    get_loadcell_byte(flagVerbose);

    // Boolean to check if frame has been found
    frame_found = check_frame(flagVerbose);

    if (frame_found)
    {
      SerialUSB.println("Frame Found");
    }
    else
    {
      // When there is nothing in the pipe.
    }
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void send_frame_byte(int frameMode, int flagVerbose)
{
  // Write frame or frame byte (depending on the frameMode) to the Serial2 tx bus

  byte sendOut;

  // Frame Mode 1: send only 1 byte /////////////
  if (frameMode == 1)
  {

    int idx_out;

    if (arduinos_counted)
    {
      // Select the byte to be send from the circular frame array
      if (frame_buf.head > 5 + n_ard * SENSOR_DATA_LENGTH)
      {

        // TODO replace 110 by MAX_FRAME_SIZE
        idx_out = (frame_buf.head + idx_skip) % 110;
      }
      else
      {
        idx_out = frame_buf.head;
      }
      sendOut = frame_buf.buffer[idx_out];
    }
    else
    {
      // Select the byte to be send from the circular frame array
      sendOut = frame_buf.buffer[frame_buf.head];
    }

    // Update the head of the circular frame array
    frame_buf.head = ((frame_buf.head + 1) % (MAX_FRAME_SIZE - idx_skip));

    // If the last byte of the frame is being send: switch bool_end_byte_sent to true
    if (idx_out == MAX_FRAME_SIZE - 1)
    {
      bool_end_byte_sent = true;
    }
    if (flagVerbose)
    {
      SerialUSB.print("Send out: \t");
      SerialUSB.println(sendOut);
    }

    Serial2.write(sendOut);
  }

  // Frame Mode 2: send whole frame //////////////
  else if (frameMode == 2)
  {
    // Write initial_frame to tx port
    Serial2.write(initial_frame, sizeof(initial_frame));
  }
  else
  {
    SerialUSB.println("Mode does not exist");
  }
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
    //SerialUSB.println("Checksum mismatch");
    //SSerialUSB.print("Computed checksum : "); SerialUSB.println(checksum_calc,HEX);
    //SSerialUSB.print("Frame checksum : "); SerialUSB.println(checksum_frame,HEX);
    //Sprint_buffer();
  }

  if (flagVerbose)
  {
    print_check_checksum(ismatch, checksum_calc, checksum_frame);
  }
  return ismatch;
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void get_loadcell_byte(int flagVerbose)
{
  // Read byte from USART buffer and write it to ring buffer

  // Read byte from the USART buffer
  byte inByte = Serial2.read();

  // Update the head index
  ser_rx_buf.head = BUFFER_NEXT(ser_rx_buf.head);

  // Write the read byte to the ring buffer
  ser_rx_buf.buffer[ser_rx_buf.head] = inByte;

  // Verbose mode
  if (flagVerbose)
  {
    print_get_loadcell_byte(inByte);
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

  // 1. End byte
  if (ser_rx_buf.buffer[ser_rx_buf.head] == END_FRAME) // may have more than 1 byte, I sould suggest at least 2
  {
    int idx_tmp = (ser_rx_buf.head - (MAX_FRAME_SIZE - idx_skip - 1)) & (BUFFER_SIZE - 1);

    // 2. First start byte
    if (ser_rx_buf.buffer[(ser_rx_buf.head - (MAX_FRAME_SIZE - idx_skip - 1)) & (BUFFER_SIZE - 1)] == FRAME_SYNC_0) // Reads first start byte (0xFF)
    {
      // 3. Second start byte
      if (ser_rx_buf.buffer[(ser_rx_buf.head - (MAX_FRAME_SIZE - idx_skip - 2)) & (BUFFER_SIZE - 1)] == FRAME_SYNC_1) // Reads first start byte (0xAA)
      {
        // Determine new tail and make sure it is circular
        ser_rx_buf.tail = (ser_rx_buf.head - (MAX_FRAME_SIZE - idx_skip - 1)) & (BUFFER_SIZE - 1);

        // Calculate checksum for the data in the ser_rx_buf buffer
        bool_checksum = check_checksum(flagVerbose);

        // 4. Checksum comparison
        if (bool_checksum)
        {
          if (flagVerbose)
          {
            print_check_frame();
          }
          all_frames_found++;
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
void update_bool_send_byte()
{

  /*
  SerialUSB.println(bool_end_byte_sent);
   SerialUSB.println(!bool_interval);
   SerialUSB.println();
   */

  // If end byte has been send
  if (bool_end_byte_sent)
  {

    // If current time is not smaller than the frame sampling time
    if (!bool_interval)
    {
      // Reset boolean that indicates that the end byte has been send
      // And reset the loop index at which the first frame byte has been send
      bool_end_byte_sent = false;
      i_loop_frame = i_loop;
    }
  }
  else if (time_diff >= TIME_INTERVAL_TWITCH) {
    SerialUSB.println("time diff superior to time interval twitch");
  } 

  // SAMPLING_MODE = 1 : It will sample at it's fastest frequency possible.
  // SAMPLING_MODE = 2 : Servo updates will stop, thereby providing a clear indication that the sampling frequency is high.
  if (SAMPLING_MODE == 1)
  {

    // Send bytes as long as the end byte has not been sent.
    bool_send_byte = !bool_end_byte_sent;
  }
  
  else if (SAMPLING_MODE == 2)
  {
    // Boolean to send a byte:  - if current time is smaller than the frame sampling time
    //                          - if end byte has not been send
    bool_send_byte = bool_interval && !bool_end_byte_sent;

    if (time_diff >= (OUTPUT__DATA_INTERVAL + 10) && bool_walk)
    {
      Serial3.write("Can't keep up with the sampling frequency. Execution terminated (try: sampling mode 1)!\n");

      // Stop all servo updates.
      bool_walk = false;
    }
  }
  else
  {
    SerialUSB.println("Sampling Mode Error: mode does not exist. Adjust the mode in constants.h");
  }
}

/* ===================================================================================================================================== */

/////////////////////////////////
// 3. DATA PROCESSING          //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void count_arduinos_wrapper(int flagVerbose)
{
  // Wrapper to count the number of connected loadcell arduinos

  int i = 0;

  // Keep sending bytes until whole frame is found
  while (!frame_found)
  {

    // Send and get byte
    send_and_get_wrapper(1);

    // A small delay between the frames being send
    if (bool_end_byte_sent)
    {
      delay(10);
    }

    // A small delay between the frame bytes being send
    delay(1);

    // Reset boolean
    bool_end_byte_sent = false;

    // If no full frame has been received after 1000 loops, throw error and break out of the loop
    // Most likely the frame bytes are not received properly (suggestion: check baud rate, wiring or code of the loadcells/IMU)
    if (i > 1000)
    {
      SerialUSB.println("[ERROR] count_arduinos_wrapper(): Can not count the number of Arduino's");
      break;
    }
    i++;
  }

  // Parse the received frame
  wrapper_parser(flagVerbose);

  // Count the number of arduinos given the parsed frame
  // Verbose mode: prints then number of counted arduino's
  count_arduinos(1);
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void count_arduinos(int flagVerbose)
{
  // Count the number of loadcell arduino's given that the frame has been parsed

  // Initialize temporary variables
  byte byte_tmp;
  byte byte_sum_tmp;

  // Reset n_ard (old value was: n_ard = MAX_NR_ARDUINO)
  n_ard = 0;

  // Loop over the maximum number of available arduinos
  for (int i_ard = 0; i_ard < MAX_NR_ARDUINO; i_ard++)
  {

    // Loop over all bytes of particular arduino
    for (int j = 0; j < SENSOR_DATA_LENGTH - 1; j++)
    {

      // Read byte and write to temporary variable
      byte_tmp = ser_rx_buf.last_loadcell_data[i_ard * (SENSOR_DATA_LENGTH - 1) + j];

      // If one of the bytes has a nonzero value, it apparently is a Arduino
      if (byte_tmp != 0)
      {
        n_ard++;
        break; // If a byte is found, don't search any further and get the data of the next arduino
      }
    }
  }

  arduinos_counted = true;

  // Verbose mode
  if (flagVerbose)
  {
    SerialUSB.print("Number of (loadcell) arduino's counted: ");
    SerialUSB.println(n_ard);
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
float get_float_value(byte dataArr[], int mode, int flagVerbose)
{
  // Transform array of 4 HEX numbers to floating point.
  // The value 999 is returned in case the mode is not set correctly.

  // Declare variable
  unsigned long fourByte;

  // Bitwise operations to construct float value
  // LSB mode
  if (mode == 1)
  {
    fourByte = (dataArr[0] << 8 * 3) + (dataArr[1] << 8 * 2) + (dataArr[2] << 8 * 1) + (dataArr[3] << 8 * 0);
  }
  // MSB mode
  else if (mode == 2)
  {
    fourByte = (dataArr[3] << 8 * 3) + (dataArr[2] << 8 * 2) + (dataArr[1] << 8 * 1) + (dataArr[0] << 8 * 0);
  }
  else
  {
    SerialUSB.println("Warning: invalid endianess mode for get_float_value()");
    return 999;
  }

  // Some pointing and dereferencing magic to obtain floating point value
  float floatValue = *(float *)&fourByte;

  // Verbose mode
  if (flagVerbose)
  {
    print_get_float_value(dataArr, floatValue, mode);
  }
  return floatValue;
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void hex_to_float(int flagVerbose, int mode)
{
  // Convert all values of the loadcell data to float values

  // Declaration of local variables
  int i_float;
  byte tmp[4];
  float tmp_fl;
  int data_length;

  // Set data_length for the particular mode
  // Mode 1: loadcell mode; Mode 2: IMU mode
  (mode == 1) ? data_length = n_ard * SENSOR_DATA_LENGTH : (mode == 2) ? data_length = IMU_DATA_LENGTH : data_length = -1;

  // If mode does not exist, print error.
  if (data_length == -1)
  {
    SerialUSB.println("Error in hex_to_float(): Mode does not exist.");
  }

  // Looping over all elements in loadcell_data
  for (int i = 0; i < data_length; i++)
  {

    // Select data for the particular mode
    // Mode 1: loadcell mode; Mode 2: IMU mode
    (mode == 1) ? tmp[i % 4] = ser_rx_buf.last_loadcell_data[i] : tmp[i % 4] = ser_rx_buf.last_IMU_data[i];

    // If the 4th byte has been read, convert the 4 byte array to a float and store it in tmp_fl.
    // Write value of tmp_fl to struct containing the data.
    if ((i + 1) % 4 == 0)
    {
      tmp_fl = get_float_value(tmp, 2, 0);

      // Write data to either last_loadcell_data_float (mode 1) or last_IMU_data_float (mode 2) array in struct ser_rx_buf
      (mode == 1) ? ser_rx_buf.last_loadcell_data_float[(i) / 4] = tmp_fl : ser_rx_buf.last_IMU_data_float[(i) / 4] = tmp_fl;

      // Verbose mode
      if (flagVerbose)
      {
        // Verbose for the particular mode
        // Mode 1: loadcell mode; Mode 2: IMU mode
        //(mode == 1) ? print_hex_to_float_loadcell(i, tmp, tmp_fl) : (mode == 2) ? print_hex_to_float_IMU(i, tmp, tmp_fl) : SerialUSB.println("");
        if (mode == 1)
          print_hex_to_float_loadcell(i, tmp, tmp_fl);
        if (mode == 2)
          print_hex_to_float_IMU(i, tmp, tmp_fl);
      }
    }
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void parse_data_loadcell(int flagVerbose)
{
  // Parse the data from the loadcell

  // Declarations / initalizations
  int i_ard = 0; // Keep track of the arduino being processed in the frame
  int i_data;

  // Loop over data (3 * 4 bytes + 1 timestamp per arduino)
  for (int k = 0; k < n_ard * SENSOR_DATA_LENGTH; k++)
  {

    // Index of data in the ring buffer
    i_data = ((ser_rx_buf.tail + 5) + k) % BUFFER_SIZE;

    // If iteration is at SENSOR_DATA_LENGTH'th index, it should write to timestamp array.
    // Else, write to data array.
    if ((k + 1) % SENSOR_DATA_LENGTH == 0)
    {
      if (flagVerbose)
      {
        SerialUSB.print("Timestamp: \t");
        SerialUSB.println(ser_rx_buf.buffer[i_data], HEX);
      }
      ser_rx_buf.timestamp_loadcell[i_ard] = ser_rx_buf.buffer[i_data]; // Timestamp
      i_ard++;
    }
    else
    {
      ser_rx_buf.last_loadcell_data[k - i_ard] = ser_rx_buf.buffer[i_data]; // Loadcell data
    }
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void parse_data_IMU()
{
  // Parse the data from the IMU

  int i_data;
  int offset = n_ard * SENSOR_DATA_LENGTH;

  for (int k = offset; k < offset + IMU_DATA_LENGTH; k++)
  {

    // Index of data in the ring buffer
    i_data = ((ser_rx_buf.tail + 5) + k) % BUFFER_SIZE;

    if ((k + 1 - offset) % IMU_DATA_LENGTH == 0)
    { // could actually be k = offset +IMU_DATA_LENGTH -1
      if (0)
      {
        SerialUSB.print("Timestamp IMU: \t");
        SerialUSB.println(ser_rx_buf.buffer[i_data], HEX);
      }

      ser_rx_buf.timestamp_IMU = ser_rx_buf.buffer[i_data]; // Timestamp
    }
    else
    {
      ser_rx_buf.last_IMU_data[k - offset] = ser_rx_buf.buffer[i_data]; // IMU data
    }
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void wrapper_parser(int flagVerbose)
{
  // Wrapper function to parse data of loadcells and IMU

  parse_data_loadcell(flagVerbose);
  parse_data_IMU();

  // Verbose mode
  if (flagVerbose)
  {
    print_parser();
  }
}

/* ===================================================================================================================================== */

/////////////////////////////////
// 4. BLUETOOTH                //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void read_bluetooth_command(int flagVerbose)
{
  // Read Bluetooth input stream from Serial3 rx bus

  // Read data from USART buffer
  while (Serial3.available())
  {
    bluetooth_command[head] = Serial3.read();
    head = (head + 1) % BLUE_FRAME_LENGTH;
    blue_command_new = true;
  }

  // Verbose mode
  if (flagVerbose)
  {
    print_read_bluetooth_command();
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void exe_blue_command(int flagVerbose)
{
  // Execute bluetooth command

  // First byte should be 0xB1
  if (bluetooth_command[0] != 0xB1)
  {
    SerialUSB.println("Bluetooth command not valid: First byte doesn't equal the start byte of the Bluetooth command.");
  }
  else
  {
    // Bluetooth command list
    // For subprograms that take a lot of time ('Start Gait' and 'Start Detection Loop' for example),
    // it is best to implement it setting flags in the loop() function instead of running the function here.
    // This way, data still gets collected in between the different states of the subprogram.
    if (bluetooth_command[1] == 0xB0)
    {
      //SerialUSB.println("[START] Gait");
      bool_walk = true;
    }
    else if (bluetooth_command[1] == 0xB1)
    {
      //SerialUSB.println("[STOP] Gait");
      bool_walk = false;
    }
    else if (bluetooth_command[1] == 0xB2)
    {
      //SerialUSB.println("[START] Stretch pose");
      bool_walk = false;
      //TODO : recode pose_stretch
      //pose_stretch();
    }
    else if (bluetooth_command[1] == 0xB3)
    {
      //SerialUSB.println("[START] Walk pose");
      bool_walk = false;
      pose_stance();
    }
    else if (bluetooth_command[1] == 0xB4)
    {
      //SerialUSB.println("[RESET] phase shift");
      reset_servo_offset();
    }
    else if (bluetooth_command[1] == 0xB5)
    {
      // Open slot
    }
    else if (bluetooth_command[1] == 0xB6)
    {
      twitch_main();
    }
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void construct_initial_frame_blue(byte arduino_target)
{
  // Frame to send to the daisy chain. Not needed anymore!
  initial_frame_blue[0] = FRAME_SYNC_0;   // First start byte
  initial_frame_blue[1] = FRAME_SYNC_1;   // Second start byte
  initial_frame_blue[2] = 0;              // Arduino ID
  initial_frame_blue[3] = 0x13;           // Frame Type
  initial_frame_blue[4] = 2;              // Data size
  initial_frame_blue[5] = arduino_target; // Target Arduino ID
  initial_frame_blue[6] = 0x00;           // Command
  initial_frame_blue[7] = 0x00;           // Checksum
  initial_frame_blue[8] = END_FRAME;      // End frame
}

/* ===================================================================================================================================== */

/////////////////////////////////
// 5. DYNAMIXEL                //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

void init_port_and_packet_handler()
{
  portHandler = dynamixel::PortHandler::getPortHandler(DEVICE_NAME);
  packetHandler = dynamixel::PacketHandler::getPacketHandler(PROTOCOL_VERSION);
  // Open port
  if (portHandler->openPort())
  {
    Serial.print("Succeeded to open the port!\n");
  }
  else
  {
    Serial.print("Failed to open the port!\n");
    Serial.print("Press any key to terminate...\n");
    return;
  }

  // Set port baudrate
  if (portHandler->setBaudRate(BAUDRATE_DXL))
  {
    Serial.print("Succeeded to change the baudrate!\n");
  }
  else
  {
    Serial.print("Failed to change the baudrate!\n");
    Serial.print("Press any key to terminate...\n");
    return;
  }
}

void init_dynamixel()
{
  // Initialize dynamixels
  init_port_and_packet_handler();
  count_dynamixels();

  // starting the oscillation at the given positions
  /*
  if (start_at_location)
  {
    SerialUSB.println("starting oscillations at given positions");
    reset_servo_offset();
  }
  */

  //Dxl.jointMode(id); //jointMode() is to use position mode, NOT SURE IF THIS IS NEEDED IN THE BROADCAST MODE
  //KIND OF NOT IF ALL THE SEERVOS ARE SET UP CORRECTLY, CHECK WITH ROBOPLUS
  SerialUSB.println("setup of Dynamixel complete");

  t_offset = millis();
  t_old = millis();
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */

void reset_servo_offset()
{
  for (int i = 0; i < n_servos; i++)
  {
    uint16_t tmp = read_present_position(id[i]);
    if (tmp > amplitude)
    {
      tmp = amplitude;
    } // making sure the asin is defined
    if (tmp < -amplitude)
    {
      tmp = -amplitude;
    }

    servo_offset[i] = asin(double(tmp)/double(amplitude));
    //SerialUSB.print("servo offset: ");
    //SerialUSB.println(servo_offset[i]);
  }
}

void count_dynamixels()
{
  uint16_t w; //just a receiver for the present position test, we are not interested in the actual value but in the communication test result.
  SerialUSB.print("Search for all servos at baud rate: ");
  SerialUSB.println(BAUDRATE_DXL);
  for (int i = 0; i < 254; i++)
  {
    if (packetHandler->read2ByteTxRx(portHandler, i, ADDR_PRESENT_POSITION, &w) == COMM_SUCCESS)
    {
      id[n_servos] = i;
      n_servos++;
    }
    if (n_servos>MAX_NR_SERVOS){
      SerialUSB.println("The number of servos found is higher than MAX_NR_SERVOS !!!");
      SerialUSB.println("Entering empty infinite loop to prevent anything bad");
      while (1);
    }
  }

  if (n_servos == 0)
    SerialUSB.println("I found no servos :(");
  else{
    SerialUSB.print("Found "); SerialUSB.print(n_servos); SerialUSB.print(" servos, IDs: ");
    for (int i=0; i < n_servos; i++){
      SerialUSB.print(id[i]);
      SerialUSB.print("\t");
    }
    SerialUSB.println();
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
uint16_t deg2pos(int deg)
{
  // Converting degrees to position (1024 positions for 300 degrees)
  uint16_t pos = uint16_t((deg + 150) * 3.413);
  return pos;
}

float pos2deg(uint16_t pos)
{
  // Converting degrees to position (1024 positions for 300 degrees)
  float deg = (pos - 512) / 3.413;
  return deg;
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
uint16_t rad2pos(float rad)
{
  // Converting rad to position
  uint16_t pos = word((rad + 2.618) * 195.57);
  return pos;
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
float pos2rad(uint16_t pos)
{
  // Converting position to rad
  pos = pos - 512;
  float rad = pos / 195.57;
  return rad;
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
/*void pose_stance()
{
  for (int i = 0; i < n_servos; i++)
  {
    set_goal_position(id[i], 512);
  }
}
*/

void pose_stance()
{
  uint16_t  goal_positions_stance[n_servos];
  for (int i = 0; i < n_servos; i++)
  {
    goal_positions_stance[i]= 512;
  } 
  syncWrite_position_n_servos(n_servos, id, goal_positions_stance); 
}

//TODO : maybe change the limits of goal position
void set_goal_position(uint8_t servo_id, uint16_t goal_position)
{
  packetHandler->write2ByteTxRx(portHandler, servo_id, ADDR_GOAL_POSITION, goal_position);
}

void set_compliance_margin(uint8_t servo_id, uint8_t value)
{
  packetHandler->write1ByteTxRx(portHandler, servo_id, ADDR_CW_COMPLIANCE_MARGIN, value);
  packetHandler->write1ByteTxRx(portHandler, servo_id, ADDR_CCW_COMPLIANCE_MARGIN, value);
}

void set_punch(uint8_t servo_id, uint16_t value)
{
  packetHandler->write2ByteTxRx(portHandler, servo_id, ADDR_PUNCH, value);
}

void set_compliance_slope(uint8_t servo_id, uint8_t value)
{
  packetHandler->write1ByteTxRx(portHandler, servo_id, ADDR_CW_COMPLIANCE_SLOPE, value);
  packetHandler->write1ByteTxRx(portHandler, servo_id, ADDR_CCW_COMPLIANCE_SLOPE, value);
}

uint16_t read_present_position(uint8_t servo_id)
{
  uint16_t present_position = 0; // Present position
  packetHandler->read2ByteTxRx(portHandler, servo_id, ADDR_PRESENT_POSITION, &present_position);
  return present_position;
}

int16_t read_present_load(uint8_t servo_id)
{
  int16_t load = 0;
  uint16_t present_load_raw = 0; // Present position
  packetHandler->read2ByteTxRx(portHandler, servo_id, ADDR_PRESENT_LOAD, &present_load_raw);
  if (present_load_raw > 1024)
    load = present_load_raw - 1024;
  else
    load = -present_load_raw;
  return load;
}

uint8_t is_moving(uint8_t servo_id)
{
  uint8_t is_moving = 0;
  packetHandler->read1ByteTxRx(portHandler, servo_id, ADDR_IS_MOVING, &is_moving);
  return is_moving;
}

void syncWrite_position_n_servos(uint8_t n_servos_write, uint8_t *servo_ids, uint16_t *goal_positions)
{
  dynamixel::GroupSyncWrite groupSyncWrite(portHandler, packetHandler, ADDR_GOAL_POSITION, 2); //goal position is 2 bytes in AX.

  // Add goal position value to the Syncwrite storage
  uint8_t position_in_bytes[2];
  for (int i = 0; i < n_servos_write; i++)
  {
    position_in_bytes[0] = DXL_LOBYTE(goal_positions[i]);
    position_in_bytes[1] = DXL_HIBYTE(goal_positions[i]);
    groupSyncWrite.addParam(servo_ids[i], position_in_bytes);
  }
  // Syncwrite goal position -->  send packez
  groupSyncWrite.txPacket();

  // Clear syncwrite parameter storage
  groupSyncWrite.clearParam();
}


void syncWrite_same_punch_all_servos(uint16_t punch_value){
  dynamixel::GroupSyncWrite groupSyncWrite(portHandler, packetHandler, ADDR_PUNCH, 2); //punch is 2 bytes in AX.

  // Add punch value to the Syncwrite storage
  uint8_t punch_value_in_bytes[2] = {DXL_LOBYTE(punch_value), DXL_HIBYTE(punch_value)};
  for (int i = 0; i < n_servos; i++)
  {
    groupSyncWrite.addParam(id[i], punch_value_in_bytes);
  }
  // Syncwrite goal position -->  send packet
  groupSyncWrite.txPacket();

  // Clear syncwrite parameter storage
  groupSyncWrite.clearParam();
}

void syncWrite_1_byte_all_servos(uint8_t adress, uint8_t value){
  dynamixel::GroupSyncWrite groupSyncWrite(portHandler, packetHandler, adress, 1); 
  //1 byte in AX.

  // Add value to the Syncwrite storage
  for (int i = 0; i < n_servos; i++)
  {
    groupSyncWrite.addParam(id[i], &value);
  }
  // Syncwrite goal position -->  send packet
  groupSyncWrite.txPacket();

  // Clear syncwrite parameter storage
  groupSyncWrite.clearParam();
}

void syncWrite_compliance_margin_all_servo(uint8_t value){
  syncWrite_1_byte_all_servos(ADDR_CW_COMPLIANCE_MARGIN,value);
  syncWrite_1_byte_all_servos(ADDR_CCW_COMPLIANCE_MARGIN,value);
}

void syncWrite_compliance_slope_all_servo(uint8_t value){
  syncWrite_1_byte_all_servos(ADDR_CW_COMPLIANCE_SLOPE,value);
  syncWrite_1_byte_all_servos(ADDR_CCW_COMPLIANCE_SLOPE,value);
}


void restaure_default_motor_parameters(uint8_t servo_id)
{
  //these are the default parameters given in the AX12A manual
  set_compliance_margin(servo_id, 1);
  set_compliance_slope(servo_id, 32);
  set_punch(servo_id, 32);
}

void make_servo_compliant(uint8_t servo_id)
{
  set_compliance_margin(servo_id, SOFT_COMPLIANCE_MARGIN);
  set_compliance_slope(servo_id, SOFT_COMPLIANCE_SLOPE);
  set_punch(servo_id, SOFT_PUNCH);
}

void make_servo_stiff(uint8_t servo_id)
{
  set_compliance_margin(servo_id, STIFF_COMPLIANCE_MARGIN);
  set_compliance_slope(servo_id, STIFF_COMPLIANCE_SLOPE);
  set_punch(servo_id, STIFF_PUNCH);
}

void restaure_default_parameters_all_motors()
{
  for (int i_servo = 0; i_servo < n_servos; i_servo++)
  {
    restaure_default_motor_parameters(id[i_servo]);
  }
  delay(1000);
  SerialUSB.println("all motor parameters set to default");
}

void make_all_servos_compliant()
{
  for (int i_servo = 0; i_servo < n_servos; i_servo++)
  {
    make_servo_compliant(id[i_servo]);
  }
  //SerialUSB.println("All servos are set to compliant parameters");
}

void make_all_servos_stiff()
{
  for (int i_servo = 0; i_servo < n_servos; i_servo++)
  {
    make_servo_stiff(id[i_servo]);
  }
  //SerialUSB.println("All servos are set to stiff parameters");
}

void change_all_motor_parameters_syncWrite(uint8_t compliance_margin, uint8_t compliance_slope, uint16_t punch){
  syncWrite_compliance_margin_all_servo(compliance_margin);
  syncWrite_compliance_slope_all_servo(compliance_slope);
  syncWrite_same_punch_all_servos(punch);
}

void make_all_servos_stiff_syncWrite(){
  change_all_motor_parameters_syncWrite(STIFF_COMPLIANCE_MARGIN,STIFF_COMPLIANCE_SLOPE,STIFF_PUNCH);
}

void make_all_servos_compliant_syncWrite(){
  change_all_motor_parameters_syncWrite(SOFT_COMPLIANCE_MARGIN,SOFT_COMPLIANCE_SLOPE,SOFT_PUNCH);
}


void restaure_default_parameters_all_motors_syncWrite()
{
  change_all_motor_parameters_syncWrite(1,32,32);
  //SerialUSB.println("all motor parameters set to default");
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void init_phase_shift()
{
  // Initialize phase_shift

  ////// LEG 1
  // Servo number: 2
  phase_shift[0] = 0.5 * pi;
  // Servo number: 3
  phase_shift[1] = 1.25 * pi;

  ////// LEG 2
  // Servo number: 13
  phase_shift[2] = 0.5 * pi;
  // Servo number: 14
  phase_shift[3] = 1.25 * pi;

  ////// LEG 3
  // Servo number: 15
  phase_shift[4] = 1.5 * pi;
  // Servo number: 16
  phase_shift[5] = 0.25 * pi;

  ////// LEG 4
  // Servo number: 17
  phase_shift[6] = 1.5 * pi;
  // Servo number: 18
  phase_shift[7] = 0.25 * pi;

  for (int i_s = 0; i_s < 8; i_s++)
  {
    SerialUSB.print("Phase shift [Servo ");
    SerialUSB.print(id[i_s]);
    SerialUSB.print("]:");
    SerialUSB.println(phase_shift[i_s]);
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void init_servo_offset()
{
  // Initialize servo offset values in a way that at the lowest point, the leg pushes off in the forward direction.

  int factor = 1;
  //  double amplitude_tmp[] = {pi, pi};
  float amplitude_tmp[] = {amplitude_arr[0], amplitude_arr[1]};

  servo_offset[0] = -factor * amplitude_tmp[0];
  servo_offset[1] = 0;

  servo_offset[2] = factor * amplitude_tmp[0];
  servo_offset[3] = 0;

  servo_offset[4] = factor * amplitude_tmp[0];
  servo_offset[5] = 0;

  servo_offset[6] = -factor * amplitude_tmp[0];
  servo_offset[7] = 0;

  if (0)
  {
    for (int i_s = 0; i_s < 8; i_s++)
    {
      SerialUSB.print("Servo offset [Servo ");
      SerialUSB.print(id[i_s]);
      SerialUSB.print("]:");
      SerialUSB.println(servo_offset[i_s]);
    }
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void update_oscillators_tegotae()
{
  // Update the state of the oscillators
  //double N_s;
  //double N_h;

  ///////////////////////////////////////////////////////////////////////
  // Hardcoded mapping
  // To be replaces by the learned mapping.

  // Force in z direction
  float N_s_lc1 = ser_rx_buf.last_loadcell_data_float[2 + 0 * 3];
  float N_s_lc2 = ser_rx_buf.last_loadcell_data_float[2 + 1 * 3];
  float N_s_lc3 = ser_rx_buf.last_loadcell_data_float[2 + 2 * 3];
  float N_s_lc4 = 0;

  // Force in y direction
  float N_h_lc1 = ser_rx_buf.last_loadcell_data_float[1];
  float N_h_lc2 = ser_rx_buf.last_loadcell_data_float[1 + 1 * 3];
  float N_h_lc3 = ser_rx_buf.last_loadcell_data_float[1 + 2 * 3];
  float N_h_lc4 = 0;

  // Leg:         // Left front     // Right front    // Left rear      // Right rear
  float N_s[] = {N_s_lc3, N_s_lc3, N_s_lc2, N_s_lc2, N_s_lc1, N_s_lc1, N_s_lc2, N_s_lc2};
  float N_h[] = {N_h_lc3, N_h_lc3, N_h_lc2, N_h_lc2, N_h_lc1, N_h_lc1, N_h_lc2, N_h_lc2};

  ///////////////////////////////////////////////////////////////////////

  t_current = millis();

  for (int i = 0; i < n_servos; i++)
  {
    //            omega            Tvertical                        Thorizontal
    phi_dot[i] = 2 * pi * frequency + sigma_s * N_s[i] * cos(phi[i]) + sigma_p * N_h[i] * cos(phi[i]);
    phi[i] = phi[i] + phi_dot[i] * (t_current - t_old) / 1000;

    float val_tmp = amplitude_arr[i % 2] * sin(phi[i] + phase_shift[i]) + servo_offset[i];

    // Limit theta to 400 to 600 range
    pos[i] = rad2pos(val_tmp);
    if (pos[i] < 400)
    {
      pos[i] = 400;
    }
    if (pos[i] > 600)
    {
      pos[i] = 600;
    }

    set_goal_position(id[i], pos[i]);
  }
  t_old = t_current;
}

/* ===================================================================================================================================== */

/////////////////////////////////
// 6. TWITCHING AND LEARNING   //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

void twitch_record_wrapper(){
  SerialUSB.print("Step Amplitude : "); SerialUSB.println(STEP_AMPL);
  SerialUSB.print("Learning rate : "); SerialUSB.println(LEARNING_RATE);
  SerialUSB.print("Duration part 0 : "); SerialUSB.println(DURATION_PART0);
  SerialUSB.print("Duration part 1 : "); SerialUSB.println(DURATION_PART1);
  SerialUSB.print("Duration part 2 : "); SerialUSB.println(DURATION_PART2);
  SerialUSB.print("Compliant Mode : "); SerialUSB.println(COMPLIANT_MODE);
  SerialUSB.print("Recentering : "); SerialUSB.println(RECENTERING_TWITCH);

  SerialUSB.println();
  
  // Execute twitching procedure n_twitch times.
  for(int i_twitch = 0; i_twitch < N_TWITCHES; i_twitch++){

    // Preparations for the twitching process.
    restaure_default_parameters_all_motors_syncWrite();
    pose_stance();               // Set servo positions to stance pose
    sleep_while_moving();        // Sleep until the servo's reached their imposed positions
    //reset_servo_offset();        // Reset offset of servo's
    delay(3000);
    
    // EXECUTE TWITCHING PROCESS
    twitch_main();

    // Print weight matrix and sdot
    //print_sdot_oja();
    print_weights();
    print_weights_pos();
    SerialUSB.print("Max computation time p1 (in ms) : ");
    SerialUSB.println(max_time_computation_p1);SerialUSB.println();
    SerialUSB.print("Checksum mismatch counter value : ");SerialUSB.println(count_checksum_mismatches);SerialUSB.println();
  }
  

  
  Serial3.println(1500);
  SerialUSB.print("Total number of frames found : ");
  SerialUSB.println(all_frames_found);
    
  restaure_default_parameters_all_motors_syncWrite();
  pose_stance();
}

void twitch_main()
{

  ///////////////////////////////////////////////////////////////////////////
  /// Initialisation of variables and settings
  ///////////////////////////////////////////////////////////////////////////

  // Size of the step of the step function
  uint16_t ampl_step_pos = STEP_AMPL * 3.413;

  // Initialisation of variables:
  uint16_t pos_command;
  int n_frames_tmp = 0;
  int interv_arr[] = {DURATION_PART0, DURATION_PART1, DURATION_PART2};
  int n_frames_part[3];
  for (int i=0; i<3;i++)
    n_frames_part[i]=int(interv_arr[i]/TIME_INTERVAL_TWITCH);

  int dir_sign[] = {-1, 1};
  int i_action = 0;

  ///////////////////////////////////////////////////////////////////////////
  /// Learning Loop
  ///////////////////////////////////////////////////////////////////////////
  if (COMPLIANT_MODE==1){
    make_all_servos_compliant_syncWrite();
    //make_all_servos_compliant();
  }
  if (COMPLIANT_MODE==2){
    make_all_servos_stiff_syncWrite();   
    //make_all_servos_stiff(); 
  }

  for (uint8_t i_servo = 0; i_servo < n_servos; i_servo++)
  {
    if (COMPLIANT_MODE==1){
      make_servo_stiff(id[i_servo]);
    }

    // Loop over directions
    for (uint8_t i_dir = 0; i_dir < 2; i_dir++)
    {

      // Reset variables for learning
      reset_twitch_variables();

      // Loop over parts of actual twitching process:  - part 0:  servo waits in initial position
      //                                               - part 1:  servo goes to step position.
      //                                               - part 2:  servo goes from step position to initial position
      for (uint8_t i_part = 0; i_part < 3; i_part++)
      {

        // Select interval duration
        int interv_dur = interv_arr[i_part];

        // Perform part specific actions before recording (sending servo commands)
        twitch_pre_action(i_part, i_servo, dir_sign[i_dir], ampl_step_pos);

        // Keep looping until required number of frames is reached
        while (n_frames_tmp < n_frames_part[i_part])
        {

          // If it is the start of a new frame, initialize timestamp.
          if (i_loop_frame == i_loop - 1)
          {
            timestamp = millis();
          }

          // Calculate if time taken to send the current frame
          // and if this difference is smaller (or not) than the frame sample frequency
          time_diff = millis() - timestamp;
          bool_interval = time_diff <= TIME_INTERVAL_TWITCH;

          // Update the value of the boolean 'bool_send_byte'
          update_bool_send_byte();

          // Send one byte if time is right (meaning if bool_send_byte == true)
          if (bool_send_byte)
          {
            send_frame_byte(1, 0);
          }


          if (Serial2.available())
          {
            // Reads one byte from the rx port of Serial2 (load cells and IMU)
            get_loadcell_byte(0);

            // Boolean to check if frame has been found
            frame_found = check_frame(flagVerbose);
          }

          if (frame_found)
          {
            unsigned long start_time;
            if (i_part == 1)
              start_time = millis();

            // Increase number of collected frames
            n_frames_tmp++;

            if (i_part == 1)
              twitch_part1_moving(i_servo, dir_sign[i_dir], ampl_step_pos, n_frames_tmp, n_frames_part[i_part]);

            // Parse data
            wrapper_parser(flagVerbose);

            // Start of HEX to DEC conversion
            // First argument: flagVerbose, second argument: conversion mode
            // Mode 1: loadcell mode, Mode 2: IMU mode
            hex_to_float(flagVerbose, 1);
            hex_to_float(flagVerbose, 2);

            twitch_calculate_s_dot();

            // Learning during part 1
            if (i_part == 1)
              twitch_part1_learning(n_frames_tmp, i_servo, i_action, dir_sign[i_dir]);
            else
            {
              update_load_pos_values();
            }
            
            //Printing results Matlab
            printing_serial3_lpdata(i_part);

            // Reset frame_found boolean
            frame_found = false;

            if (i_part == 1){
              int time_computation = millis()-start_time;
              max_time_computation_p1 = std::max(max_time_computation_p1,time_computation);
            }
          }
          i_loop++;
        }
        n_frames_tmp = 0;
      }

      // Counting number of actions (total = number of servo's * 2 directions)
      i_action++;
    }
    
    if (COMPLIANT_MODE==1){
      if (RECENTERING_TWITCH==1){
        make_all_servos_stiff_syncWrite();
        //make_all_servos_stiff();
        pose_stance();
        delay(RECENTERING_DELAY);
        make_all_servos_compliant_syncWrite();
        //make_all_servos_compliant();
       
      }
      make_servo_compliant(id[i_servo]);
    }

  }
}

void printing_serial3_lpdata(uint8_t i_part){
  for (int i = 0; i < n_servos; i++)
  {
    Serial3.println(last_motor_pos[i]);
    Serial3.println(last_motor_load[i]);
    Serial3.println(last_motor_timestamp[i]);
  }
  Serial3.println(i_part);  
}

void twitch_part1_moving(uint8_t i_servo, int dir_sign, uint16_t ampl_step_pos, int n_frames_tmp, int n_frames_tot)
{
    uint16_t command_pos = 512 + dir_sign * ampl_step_pos * double(n_frames_tmp) / double(n_frames_tot);
    set_goal_position(id[i_servo], command_pos);
}

void twitch_part1_learning(int n_frames, int i_servo, int i_action, int dir_sign)
{
  uint16_t new_motor_pos;
  int16_t new_motor_load;
  unsigned long new_motor_timestamp;
  for (int i = 0; i < n_servos; i++)
  {
      new_motor_pos = read_present_position(id[i]);
      new_motor_load = read_present_load(id[i]);
      new_motor_timestamp = millis();
      m_dot_pos[i] = float(new_motor_pos - last_motor_pos[i]) / float(new_motor_timestamp - last_motor_timestamp[i]);
      last_motor_pos[i] = new_motor_pos;
      last_motor_load[i] = new_motor_load; 
      last_motor_timestamp[i] = new_motor_timestamp;
  }

  float m_learning = dir_sign*m_dot_pos[i_servo];
  twitch_learning_prog(i_action, m_learning);

}

void update_load_pos_values(){
  for (int i = 0; i < n_servos; i++)
  {
    last_motor_pos[i] = read_present_position(id[i]);
    last_motor_load[i] = read_present_load(id[i]);
    last_motor_timestamp[i] = millis();
  }
}

void twitch_learning_prog(int i_action, float m_learning)
{

  // Initialisation of local variables
  float alpha = LEARNING_RATE; // Learning rate is set by constant LEARNING_RATE
  float weight_delta;
  float s_dot_select;
  float weight;
  int i_dir;

  // Samples used for learning are subjected to conditions as defined by check_learning_conditions()
  for (int j_sensor = 0; j_sensor < n_ard * 3 + IMU_USEFUL_CHANNELS; j_sensor++)
  {

    // Select data from array
    s_dot_select = s_dot_last[j_sensor];

    // Select weight from array
    weight = learning.weights[j_sensor][i_action];

    // Apply Oja's differential learning rule
    weight_delta = oja_diff_learning_rule(m_learning, s_dot_select, weight);

    // Print information at will
    if (j_sensor == 1 && 0)
    {
      SerialUSB.print(s_dot_select);
      SerialUSB.print("\t");
      SerialUSB.print(weight);
      SerialUSB.print("\t");
      SerialUSB.println(weight_delta);
    }

    // Apply weight update rule
    learning.weights[j_sensor][i_action] = weight + alpha * weight_delta;
  }

  for (int j_motor_sensor = 0; j_motor_sensor < n_servos; j_motor_sensor++){
    s_dot_select = m_dot_pos[j_motor_sensor];
    weight = learning.weights_pos[j_motor_sensor][i_action];
    weight_delta = oja_diff_learning_rule(m_learning, s_dot_select, weight);
    learning.weights_pos[j_motor_sensor][i_action] = weight + alpha * weight_delta;

  }


}

void reset_twitch_variables()
{
  // Reset variables used in the twitching process

  for (int j_tmp = 0; j_tmp < n_ard * 3 + IMU_USEFUL_CHANNELS; j_tmp++)
  {
    s_dot_last[j_tmp] = 0;
    /*
    s_dot_peak[j_tmp][0] = 0;
    s_dot_peak[j_tmp][1] = 0;
    s_dot_sq_err[j_tmp] = 0;
    s_dot_mean_pseudo[j_tmp] = 0;
    s_dot_mean[j_tmp] = 0;
    s_dot_std[j_tmp] = 0;
    learning.peak_sign[j_tmp] = 0;
    learning.ss_sign[j_tmp] = 0;


    if (j_tmp < n_ard * 3)
    {
      val_old[j_tmp] = 0;
      s_ss_part0[j_tmp] = 0;
      s_ss_part1[j_tmp] = 0;
    }
    */
  }
}


/* ------------------------------------------------------------------------------------------------------------------------------------- */
float oja_diff_learning_rule(float m, float s_dot, float weight)
{
  // Oja's differential learning rule
  return -1 * (m * s_dot + m * m * weight);
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void twitch_pre_action(int i_part, int i_servo, int sign, uint16_t ampl_step_pos)
{
  if (i_part == 0)
  {
    set_goal_position(id[i_servo], 512);
  }
  else if (i_part == 2)
  {
    set_goal_position(id[i_servo], 512);
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */

void twitch_calculate_s_dot()
{

  // Initialization of local variables to compute derivatives of laodcell measurements
  float val_new;
  float timestamp_new;
  float t_delta;

  // Loop over all channels /////////////////////////////////////////////////
  for (int i_tmp = 0; i_tmp < n_ard * 3 + IMU_USEFUL_CHANNELS; i_tmp++)
  {

    // Loadcell channels /////////////////
    if (i_tmp < n_ard * 3)
    {

      // Get LC data
      val_new = ser_rx_buf.last_loadcell_data_float[i_tmp];

      // Define new timestamp
      timestamp_new = (int)ser_rx_buf.timestamp_loadcell[i_tmp / 3];

      // Convert ring buffer to continuous time line (i.e. value 256 will be 256 instead of 256 % 255 = 1)
      if (timestamp_new - timestamp_old[i_tmp] < 0)
      {
        t_delta = float((timestamp_new + 256) - timestamp_old[i_tmp]) / 1000;
      }
      else
      {
        t_delta = float(timestamp_new - timestamp_old[i_tmp]) / 1000;
      }

      // Calculate s_dot value
      s_dot_last[i_tmp] = (val_new - val_old_lc[i_tmp]) / t_delta;

      // Print information at will
      if (i_tmp == 1 && 0)
      {
        SerialUSB.print(t_delta, 5);
        SerialUSB.print(" \t");
        SerialUSB.print(int(timestamp_new));
        SerialUSB.print(" \t");
        SerialUSB.print(int(timestamp_old[1]));
        SerialUSB.print(" \n");
      }

      // Define old timestamp (should be after t_delta has been calculated for this step)
      timestamp_old[i_tmp] = timestamp_new;

      // Saving values for next iteration
      val_old_lc[i_tmp] = val_new;
    }

    // IMU channels /////////////////
    else
    {
      // IMU data : no differenciation needed.
      s_dot_last[i_tmp] = ser_rx_buf.last_IMU_data_float[i_tmp - n_ard * 3];
    }
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
int get_sign(float val)
{
  return (val < 0) ? -1 : (val > 0) ? 1 : 0;
}

/* ===================================================================================================================================== */

/////////////////////////////////
// 7. DEBUG TOOLS                //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void print_buffer()
{
  // Print contents of ring buffer
  for (int i = 0; i < BUFFER_SIZE; i++)
  {

    if (i == ser_rx_buf.head)
    {
      SerialUSB.print("h:");
    }
    if (i == ser_rx_buf.tail)
    {
      SerialUSB.print("t:");
    }
    SerialUSB.print("0x");
    if (ser_rx_buf.buffer[i]<16)
      SerialUSB.print("0");
    SerialUSB.print(ser_rx_buf.buffer[i], HEX);
    SerialUSB.print(", ");
    if ((i + 1) % 33 == 0)
    {
      SerialUSB.print("\n");
    }
  }
  SerialUSB.print("Head value: \t");
  SerialUSB.println(ser_rx_buf.head);
  SerialUSB.print("Tail value: \t");
  SerialUSB.println(ser_rx_buf.tail);  
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void pause()
{
  // Pause until keyboard input is given
  while (!SerialUSB.available())
  {
    delay(10);
  }
  SerialUSB.read();
}

/* ===================================================================================================================================== */

/////////////////////////////////
// 8. PRINT FUNCTIONS          //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void print_parser()
{
  SerialUSB.println("\nwrapper_parser()");
  SerialUSB.print("Load sensor data: \t");

  for (int i = 0; i < n_ard * SENSOR_DATA_LENGTH - n_ard; i++)
  {
    SerialUSB.print(ser_rx_buf.last_loadcell_data[i], HEX);

    if ((i + 1) % 12 == 0)
    {
      SerialUSB.print("\n\t\t\t");
    }
    else if ((i + 1) % 4 == 0)
    {
      SerialUSB.print("\t");
    }
    else
    {
      SerialUSB.print(',');
    }
  }

  SerialUSB.print("\nTimestamps: \t\t");

  for (int i = 0; i < n_ard; i++)
  {
    SerialUSB.print(ser_rx_buf.timestamp_loadcell[i], HEX);
    SerialUSB.print(", ");
  }

  SerialUSB.print("\n\nIMU data: \t\t");
  for (int i = 0; i < IMU_DATA_LENGTH - 1; i++)
  {
    SerialUSB.print(ser_rx_buf.last_IMU_data[i], HEX);

    if ((i + 1) % 12 == 0)
    {
      SerialUSB.print("\n\t\t\t");
    }
    else if ((i + 1) % 4 == 0)
    {
      SerialUSB.print("\t");
    }
    else
    {
      SerialUSB.print(',');
    }
  }

  SerialUSB.print("\nTimestamp: \t\t");
  SerialUSB.print(ser_rx_buf.timestamp_IMU, HEX);

  SerialUSB.print("\n\n-End of wrapper_parser()-------------------------------\n");
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void print_read_bluetooth_command()
{
  for (int i = 0; i < BLUE_FRAME_LENGTH; i++)
  {
    SerialUSB.print(bluetooth_command[i], HEX);
  }
  SerialUSB.print("\n");
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void print_get_float_value(byte dataArr[], float floatValue, int mode)
{
  SerialUSB.println("getFloatValue()");
  SerialUSB.print("Mode: ");
  SerialUSB.print(mode);
  SerialUSB.print('\n');

  for (int i = 0; i < 4; i++)
  {
    SerialUSB.print(dataArr[i], HEX);
    SerialUSB.print(", ");
  }

  SerialUSB.print(" converted to:  ");
  SerialUSB.print(floatValue);
  SerialUSB.print("\n\n");
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */

void print_hex_to_float_loadcell(int i, byte tmp[], float tmp_fl)
{
  if ((i - 3) == 0)
  {
    SerialUSB.print("\nhex_to_float_loadcell()");
  }

  if ((i - 3) % 12 == 0)
  {
    int i_ard = (i + 1) / 12;
    SerialUSB.print("\nArduino ");
    SerialUSB.print(i_ard + 1);
    SerialUSB.print("\n");
  }

  if (i == 0)
  {
    SerialUSB.print("hex_to_float_loadcell()");
  }

  SerialUSB.print("The obtained 4 bytes are: \t");

  for (int j = 0; j < 4; j++)
  {
    SerialUSB.print(tmp[j], HEX);
    SerialUSB.print("\t");
  }

  SerialUSB.print("Converted to:  ");
  SerialUSB.print(tmp_fl, 6);
  SerialUSB.print("\n");
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void print_hex_to_float_IMU(int i, byte tmp[], float tmp_fl)
{
  if (i - 3 == 0)
  {
    SerialUSB.println("\nhex_to_float_IMU()");
    SerialUSB.println("IMU");
  }

  SerialUSB.print("The obtained 4 bytes are: \t");

  for (int j = 0; j < 4; j++)
  {
    SerialUSB.print(tmp[j], HEX);
    SerialUSB.print("\t");
  }

  SerialUSB.print("Converted to:  ");
  SerialUSB.print(tmp_fl, 6);
  SerialUSB.print("\n");
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void print_check_checksum(bool ismatch, uint8_t checksum_calc, uint8_t checksum_frame)
{
  SerialUSB.println("\ncalculate_checksum()");
  SerialUSB.print("Frame checksum: \t");
  SerialUSB.println(checksum_frame, HEX);
  SerialUSB.print("Calculated checksum: \t");
  SerialUSB.println(checksum_calc, HEX);

  if (!ismatch)
  {
    SerialUSB.println("Checksums don\'t match!");
  }
  SerialUSB.print("\n");
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void print_get_loadcell_byte(byte inByte)
{
  SerialUSB.print("0x");
  SerialUSB.print(inByte, HEX);
  SerialUSB.print(", ");
  if (inByte == 0x55)
  {
    SerialUSB.print("\n");
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void print_check_frame()
{
  for (int i = 0; i < BUFFER_SIZE; i++)
  {
    SerialUSB.print(ser_rx_buf.buffer[i], HEX);
    SerialUSB.print(", ");
    if (((i + 1) % 30) == 0)
    {
      SerialUSB.print("\n");
    }
    if ((i + 1) == ser_rx_buf.head)
    {
      SerialUSB.print("h(");
      SerialUSB.print(i);
      SerialUSB.print("):");
    }
    else if ((i + 1) == ser_rx_buf.tail)
    {
      SerialUSB.print("t(");
      SerialUSB.print(i);
      SerialUSB.print("):");
    }
  }
  SerialUSB.print("\n");
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void print_weights()
{
  static int counter = 1;

  SerialUSB.print("weights{");
  SerialUSB.print(counter);
  SerialUSB.println("} = [ ...");
  for (int j_tmp = 0; j_tmp < n_ard * 3 + IMU_USEFUL_CHANNELS; j_tmp++)
  {
    for (int i_action = 0; i_action < n_servos * 2; i_action++)
    {
      SerialUSB.print(learning.weights[j_tmp][i_action], 5);
      SerialUSB.print("   \t  ");
    }
    SerialUSB.print("; ... \n");
  }
  SerialUSB.println("];\n");

  counter++;
}

void print_weights_pos()
{
  static int counter_pos = 1;

  SerialUSB.print("weights_pos{");
  SerialUSB.print(counter_pos);
  SerialUSB.println("} = [ ...");
  for (int j_sens_motor = 0; j_sens_motor < n_servos; j_sens_motor++)
  {
    for (int i_action = 0; i_action < n_servos * 2; i_action++)
    {
      SerialUSB.print(learning.weights_pos[j_sens_motor][i_action], 5);
      SerialUSB.print("   \t  ");
    }
    SerialUSB.print("; ... \n");
  }
  SerialUSB.println("];\n");

  counter_pos++;
}

/*
void print_sdot_oja(){
  static int counter_oja = 1;
  
  SerialUSB.print("s_dot_oja{");
  SerialUSB.print(counter_oja);
  SerialUSB.println("} = [ ...");
  for(int j_tmp = 0; j_tmp < n_ard * 3 + IMU_USEFUL_CHANNELS; j_tmp++){
    for(int i_action = 0; i_action < n_servos * 2; i_action++){
      SerialUSB.print(learning.s_dot_oja[j_tmp][i_action],5);
      SerialUSB.print("   \t  ");
    }
   SerialUSB.print("; ... \n");
  }
  SerialUSB.println("];\n");
  
  counter_oja++;
}
*/

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void print_data_columns()
{
  for (int i = 0; i < n_ard * SENSOR_DATA_LENGTH / 4; i++)
  {
    SerialUSB.print(ser_rx_buf.last_loadcell_data_float[i]);
    SerialUSB.print("\t");
  }
  SerialUSB.print("|||\t");
  for (int i = 0; i < IMU_DATA_LENGTH / 4; i++)
  {
    SerialUSB.print(ser_rx_buf.last_IMU_data_float[i]);
    SerialUSB.print("\t");
  }
  SerialUSB.println("");
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void print_servo_offset()
{
  for (int i = 0; i < n_servos; i++)
  {
    SerialUSB.print(servo_offset[i]);
    SerialUSB.print(", ");
  }
  SerialUSB.print("\n");
}

void print_loadcell_values(){
  for (int i_ard =0; i_ard<n_ard; i_ard++){
    SerialUSB.print("Loadcell ");SerialUSB.print(i_ard);
    SerialUSB.print(" channel values ");
    for (int j =0; j<3; j++){
      SerialUSB.print(ser_rx_buf.last_loadcell_data_float[j+3*i_ard]);
      SerialUSB.print("\t");
    }
    SerialUSB.println();
  }
  SerialUSB.println();
}