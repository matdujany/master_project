
///DYNAMIXEL FUNCTIONS

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

void count_servos()
{
  uint16_t w; //just a receiver for the present position test, we are not interested in the actual value but in the communication test result.
  SerialUSB.print("Search for all servos at baud rate: ");
  SerialUSB.println(BAUDRATE_DXL);
  for (int i = 0; i < 254; i++)
  {
    if (packetHandler->read2ByteTxRx(portHandler, i, ADDR_PRESENT_POSITION, &w) == COMM_SUCCESS)
    {
      id[n_servos] = i;
      SerialUSB.print("Found servo ID : ");
      SerialUSB.println(id[n_servos]);
      n_servos++;
    }
  }
  if (n_servos == 0)
    SerialUSB.println("I found no servos :(");
}

uint16_t read_present_position(uint8_t servo_id)
{
  uint16_t present_position = 0; // Present position
  packetHandler->read2ByteTxRx(portHandler, servo_id, ADDR_PRESENT_POSITION, (uint16_t *)&present_position);
  return present_position;
}

void set_goal_position(uint8_t servo_id, uint16_t goal_position)
{
  packetHandler->write2ByteTxRx(portHandler, servo_id, ADDR_GOAL_POSITION, goal_position);
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

void set_compliance_margin(uint8_t servo_id, uint8_t value){
  packetHandler->write1ByteTxRx(portHandler, servo_id, ADDR_CW_COMPLIANCE_MARGIN, value); 
  packetHandler->write1ByteTxRx(portHandler, servo_id, ADDR_CCW_COMPLIANCE_MARGIN, value); 
}

void set_punch(uint8_t servo_id, uint16_t value){
  packetHandler->write2ByteTxRx(portHandler, servo_id, ADDR_PUNCH, value);
}

void set_compliance_slope(uint8_t servo_id, uint8_t value){
  packetHandler->write1ByteTxRx(portHandler, servo_id, ADDR_CW_COMPLIANCE_SLOPE, value); 
  packetHandler->write1ByteTxRx(portHandler, servo_id, ADDR_CCW_COMPLIANCE_SLOPE, value); 
}

uint16_t read_present_position_detailed(uint8_t servo_id)
{
  uint8_t dxl_error = 0;              // Dynamixel error
  int dxl_comm_result = COMM_TX_FAIL; // Communication result
  uint16_t present_position = 0;      // Present position
  dxl_comm_result = packetHandler->read2ByteTxRx(portHandler, servo_id, ADDR_GOAL_POSITION, (uint16_t *)&present_position, &dxl_error);
  if (dxl_comm_result != COMM_SUCCESS)
  {
    packetHandler->getTxRxResult(dxl_comm_result);
  }
  else if (dxl_error != 0)
  {
    packetHandler->getRxPacketError(dxl_error);
  }
  return present_position;
}

void set_goal_position_detailed(uint8_t servo_id, uint16_t goal_position)
{
  uint8_t dxl_error = 0;              // Dynamixel error
  int dxl_comm_result = COMM_TX_FAIL; // Communication result
  dxl_comm_result = packetHandler->write2ByteTxRx(portHandler, servo_id, ADDR_GOAL_POSITION, goal_position, &dxl_error);
  if (dxl_comm_result != COMM_SUCCESS)
  {
    packetHandler->getTxRxResult(dxl_comm_result);
  }
  else if (dxl_error != 0)
  {
    packetHandler->getRxPacketError(dxl_error);
  }
}

void center_all_servos()
{
  for (int i = 0; i < n_servos; i++)
  {
    set_goal_position(id[i], 512);
  }
}

void restaure_default_motor_parameters(int servo_id){
  //these are the default parameters given in the AX12A manual
  set_compliance_margin(servo_id,1);
  set_compliance_slope(servo_id,32);  
  set_punch(servo_id,32);
}

///LOADCELL FUNCTIONS

void capture_frame(unsigned long delay_frames){
  while (!bool_end_byte_sent)
    send_frame_byte(1, 0);
  while(Serial2.available())
  {
    // Reads one byte from the rx port of Serial2 (load cells and IMU)
    get_loadcell_byte(0);

    // Boolean to check if frame has been found
    frame_found = check_frame(flagVerbose);
  }
  if (frame_found)
    //print_loadcell_values()
  else
    SerialUSB.println("No frame found");
  delay(delay_frames);
  bool_end_byte_sent = false;
}


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

void Serial3write_load_and_pos_during_twitch()
{
  for (int i = 0; i < n_servos; i++)
  {
    Serial3.println(read_present_position(id[i]));
    Serial3.println(read_present_load(id[i]));
  }
}
