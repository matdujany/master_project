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
  frame_buf.frame_size = MAX_FRAME_SIZE; //for the moment, the frame has the maximal length

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

  // 2. Set correct frame size and adapt content of the buffer;
  frame_buf.frame_size = 5 + n_ard * SENSOR_DATA_LENGTH + IMU_DATA_LENGTH + 2;

  //3. adapt content of the buffer;
  frame_buf.buffer[MAX_FRAME_SIZE-1] = 0; //contained end frame before
  frame_buf.buffer[frame_buf.frame_size-1] = END_FRAME;

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

/////////////////////////////////
// 3. DATA PROCESSING          //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void count_arduinos_wrapper(int flagVerbose)
{
  // Wrapper to count the number of connected loadcell arduinos

  int i = 0;

  reinitalize_dc_state();

  // Keep sending bytes until whole frame is found
  while (!frame_found)
  {
    try_capture_1_frame();
    i++;
    // If no full frame has been received after 1000 loops, throw error and break out of the loop
    // Most likely the frame bytes are not received properly (suggestion: check baud rate, wiring or code of the loadcells/IMU)
    if (i > 1000)
    {
      SerialUSB.println("[ERROR] count_arduinos_wrapper(): Can not count the number of Arduino's");
      break;
    }
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
    SerialUSB.print("Number of arduinos (loacells) counted: ");
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
  (mode == 1) ? data_length = n_ard * (SENSOR_DATA_LENGTH-1) : (mode == 2) ? data_length = (IMU_DATA_LENGTH-1) : data_length = -1;

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

/////////////////////////////////
// 5. DYNAMIXEL MOVING         //
/////////////////////////////////


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
    SerialUSB.print("Loadcell ");SerialUSB.print(i_ard+1);
    SerialUSB.print(" channel values ");
    for (int j =0; j<3; j++){
      SerialUSB.print(ser_rx_buf.last_loadcell_data_float[j+3*i_ard]);
      SerialUSB.print("\t");
    }
    SerialUSB.print(", timestamp ");
    SerialUSB.println(ser_rx_buf.timestamp_loadcell[i_ard],DEC);
  }
  SerialUSB.println();
}
void print_IMU_values(){
  SerialUSB.print("IMU channel values ");
  for (int j =0; j<6; j++){
    SerialUSB.print(ser_rx_buf.last_IMU_data_float[j]);
    SerialUSB.print("\t");
  }
  SerialUSB.print(", timestamp ");
  SerialUSB.println(ser_rx_buf.timestamp_IMU,DEC);
  SerialUSB.println();
}