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
  SerialUSB.println("setup of Dynamixel complete");
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */

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

uint16_t check_goal_position(uint16_t goal_position){
  uint16_t pos = goal_position;
  uint16_t saturation = 150;
  if (abs(pos-512)>saturation){
    SerialUSB.print("Warning position value ");
    SerialUSB.print(pos);
    SerialUSB.println(" is higher than saturation");
    if (pos>512)
      pos = 512 + saturation;
    else
      pos = 512 - saturation;
  }
  return pos;
}

//TODO : maybe change the limits of goal position
void set_goal_position(uint8_t servo_id, uint16_t goal_position)
{
  uint16_t goal_position_checked = check_goal_position(goal_position);
  packetHandler->write2ByteTxRx(portHandler, servo_id, ADDR_GOAL_POSITION, goal_position_checked);
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
  delay(10);
}

void syncWrite_position_n_servos(uint8_t n_servos_write, uint8_t *servo_ids, uint16_t *goal_positions)
{
  dynamixel::GroupSyncWrite groupSyncWrite(portHandler, packetHandler, ADDR_GOAL_POSITION, 2); //goal position is 2 bytes in AX.

  // Add goal position value to the Syncwrite storage
  uint8_t position_in_bytes[2];
  for (int i = 0; i < n_servos_write; i++)
  {
    uint16_t goal_position_checked = check_goal_position(goal_positions[i]);
    position_in_bytes[0] = DXL_LOBYTE(goal_position_checked);
    position_in_bytes[1] = DXL_HIBYTE(goal_position_checked);
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


void syncWrite_2bytes_n_servos(uint8_t n_servos_write, uint8_t *servo_ids, uint16_t *two_bytes_array, uint8_t adress)
{
  dynamixel::GroupSyncWrite groupSyncWrite(portHandler, packetHandler, adress, 2); //write 2 bytes at adress

  // Add goal position value to the Syncwrite storage
  uint8_t array_in_bytes[2];
  for (int i = 0; i < n_servos_write; i++)
  {
    array_in_bytes[0] = DXL_LOBYTE(two_bytes_array[i]);
    array_in_bytes[1] = DXL_HIBYTE(two_bytes_array[i]);
    groupSyncWrite.addParam(servo_ids[i], array_in_bytes);
  }
  // Syncwrite goal position -->  send packez
  groupSyncWrite.txPacket();

  // Clear syncwrite parameter storage
  groupSyncWrite.clearParam();
}

void syncWrite_1byte_n_servos(uint8_t n_servos_write, uint8_t *servo_ids, uint8_t *bytes_array, uint8_t adress)
{
  dynamixel::GroupSyncWrite groupSyncWrite(portHandler, packetHandler, adress, 1); //write 1 byte at adress

  // Add goal position value to the Syncwrite storage
  for (int i = 0; i < n_servos_write; i++)
  {
    uint8_t value = bytes_array[i];
    groupSyncWrite.addParam(servo_ids[i], &value);
  }
  // Syncwrite goal position -->  send packez
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

void change_motor_parameters_movement_learning(uint8_t servo_id){
  set_compliance_margin(servo_id,MOV_LEARNING_COMPLIANCE_MARGIN);
  set_compliance_slope(servo_id,MOV_LEARNING_COMPLIANCE_SLOPE);
  set_punch(servo_id,MOV_LEARNING_PUNCH);
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

void change_parameters_all_motors_recentering_syncWrite()
{
  change_all_motor_parameters_syncWrite(RECENTERING_COMPLIANCE_MARGIN,RECENTERING_COMPLIANCE_SLOPE,RECENTERING_PUNCH);
  //SerialUSB.println("all motor parameters set to recentering");
}

void syncWrite_compliance_margins(uint8_t n_servos_write, uint8_t *servo_ids, uint8_t *compliance_margins_array){
  syncWrite_1byte_n_servos(n_servos_write,servo_ids,compliance_margins_array,ADDR_CW_COMPLIANCE_MARGIN);
  syncWrite_1byte_n_servos(n_servos_write,servo_ids,compliance_margins_array,ADDR_CCW_COMPLIANCE_MARGIN);
}

void syncWrite_compliance_slopes(uint8_t n_servos_write, uint8_t *servo_ids, uint8_t *compliance_slopes_array){
  syncWrite_1byte_n_servos(n_servos_write,servo_ids,compliance_slopes_array,ADDR_CW_COMPLIANCE_SLOPE);
  syncWrite_1byte_n_servos(n_servos_write,servo_ids,compliance_slopes_array,ADDR_CCW_COMPLIANCE_SLOPE);
}

void syncWrite_punchs(uint8_t n_servos_write, uint8_t *servo_ids, uint16_t *punchs_array){
  syncWrite_2bytes_n_servos(n_servos_write,servo_ids,punchs_array,ADDR_PUNCH);
}
