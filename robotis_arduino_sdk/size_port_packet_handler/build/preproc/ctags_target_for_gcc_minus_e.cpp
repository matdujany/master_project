# 1 "\\\\files2\\data\\dujany\\My Documents\\master_project\\code\\robotis_arduino_sdk\\size_port_packet_handler\\size_port_packet_handler.ino"
# 1 "\\\\files2\\data\\dujany\\My Documents\\master_project\\code\\robotis_arduino_sdk\\size_port_packet_handler\\size_port_packet_handler.ino"
/*

   Dynamixel : AX-series with Protocol 1.0

   Controller : OpenCM9.04C + OpenCM 485 EXP

   Power Source : SMPS 12V 5A



   AX-Series are connected to Dynamixel BUS on OpenCM 485 EXP board or DXL TTL connectors on OpenCM9.04

   http://emanual.robotis.com/docs/en/parts/controller/opencm485exp/#layout



   This example will test only one Dynamixel at a time.

*/
# 12 "\\\\files2\\data\\dujany\\My Documents\\master_project\\code\\robotis_arduino_sdk\\size_port_packet_handler\\size_port_packet_handler.ino"
# 13 "\\\\files2\\data\\dujany\\My Documents\\master_project\\code\\robotis_arduino_sdk\\size_port_packet_handler\\size_port_packet_handler.ino" 2

// AX-series Control table address
# 25 "\\\\files2\\data\\dujany\\My Documents\\master_project\\code\\robotis_arduino_sdk\\size_port_packet_handler\\size_port_packet_handler.ino"
// Protocol version






//uint8_t id[MAX_SERVOS];
//uint8_t n_servos = 0;

dynamixel::PortHandler *portHandler; //for communication with Dynamixels
dynamixel::PacketHandler *packetHandler; //for communication with Dynamixels

void init_port_and_packet_handler()
{
  portHandler = dynamixel::PortHandler::getPortHandler("1" /*DEVICENAME "1" -> Serial1(OpenCM9.04 DXL TTL Ports)*/);
  packetHandler = dynamixel::PacketHandler::getPacketHandler(1.0 /* AX supports only Protocol Version 1.0 --> syncWrite OK but no syncRead*/);
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
  if (portHandler->setBaudRate(1000000))
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

/*

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



void timing_set_position_1servo(uint8_t servo_id)

{

  SerialUSB.print("Working on servo ");

  SerialUSB.println(servo_id);

  int nb_repeats = 10000;

  SerialUSB.print("Timing set position with write2ByteTxRx method (Dxl sdk), nb_repeats ");

  SerialUSB.println(nb_repeats);

  unsigned long time_start = millis();

  for (int i = 0; i < nb_repeats; i++)

  {

    set_goal_position(servo_id, 512);

  }

  float duration = float((millis() - time_start)) / nb_repeats;

  SerialUSB.print("Result per operation in milliseconds ");

  SerialUSB.println(duration);

}



void timing_print_position_1servo(uint8_t servo_id)

{

  SerialUSB.print("Working on servo ");

  SerialUSB.println(servo_id);

  int nb_repeats = 10000;

  SerialUSB.print("Timing print position with read2ByteTxRx method (Dxl sdk) and Serial3.println, nb_repeats ");

  SerialUSB.println(nb_repeats);

  unsigned long time_start = millis();

  for (int i = 0; i < nb_repeats; i++)

  {

    Serial3.println(read_present_position(servo_id));

  }

  float duration = float((millis() - time_start)) / nb_repeats;

  SerialUSB.print("Result per operation in milliseconds ");

  SerialUSB.println(duration);

}



void timing_read_position_1servo(uint8_t servo_id)

{

  SerialUSB.print("Working on servo ");

  SerialUSB.println(servo_id);

  int nb_repeats = 10000;

  SerialUSB.print("Timing read position with read2ByteTxRx method (Dxl sdk), nb_repeats ");

  SerialUSB.println(nb_repeats);

  unsigned long time_start = millis();

  for (int i = 0; i < nb_repeats; i++)

  {

    read_present_position(servo_id);

  }

  float duration = float((millis() - time_start)) / nb_repeats;

  SerialUSB.print("Result per operation in milliseconds ");

  SerialUSB.println(duration);

}



// does not work with AX 12A (support only protocol 1.0 and this requires protocol 2.0)

void syncRead_position_2servo(uint8_t servo_id1, uint8_t servo_id2)

{

  int32_t dxl1_present_position = 0, dxl2_present_position = 0; // Present position

  dynamixel::GroupSyncRead groupSyncRead(portHandler, packetHandler, ADDR_PRESENT_POSITION, 2);



  bool dxl_addparam_result = false; // addParam result

  // Add parameter storage for Dynamixel#1 present position value

  dxl_addparam_result = groupSyncRead.addParam(servo_id1);



  // Add parameter storage for Dynamixel#2 present position value

  dxl_addparam_result = groupSyncRead.addParam(servo_id2);

  int dxl_comm_result = COMM_TX_FAIL; // Communication result

  dxl_comm_result = groupSyncRead.txRxPacket();

  if (dxl_comm_result != COMM_SUCCESS)

    packetHandler->getTxRxResult(dxl_comm_result);



  bool dxl_getdata_result = false; // GetParam result

  // Check if groupsyncread data of Dynamixel#1 is available

  dxl_getdata_result = groupSyncRead.isAvailable(servo_id1, ADDR_PRESENT_POSITION, 2);//present position is 2 bytes in AX



  // Check if groupsyncread data of Dynamixel#2 is available

  dxl_getdata_result = groupSyncRead.isAvailable(servo_id2, ADDR_PRESENT_POSITION, 2);//present position is 2 bytes in AX



  // Get Dynamixel#1 present position value

  dxl1_present_position = groupSyncRead.getData(servo_id1, ADDR_PRESENT_POSITION, 2);//present position is 2 bytes in AX

  SerialUSB.println(dxl1_present_position);



  // Get Dynamixel#2 present position value

  dxl2_present_position = groupSyncRead.getData(servo_id2, ADDR_PRESENT_POSITION, 2);//present position is 2 bytes in AX

  SerialUSB.println(dxl2_present_position);

}



void syncWrite_position_2servos(uint8_t servo_id1, uint8_t servo_id2, uint16_t goal_position1, uint16_t goal_position2)

{

  dynamixel::GroupSyncWrite groupSyncWrite(portHandler, packetHandler, ADDR_GOAL_POSITION, 2); //goal position is 2 bytes in AX.



  // Add Dynamixel#1 goal position value to the Syncwrite storage

  uint8_t position1_in_bytes[2] = {DXL_LOBYTE(goal_position1), DXL_HIBYTE(goal_position1)};

  groupSyncWrite.addParam(servo_id1, position1_in_bytes);

  uint8_t position2_in_bytes[2] = {DXL_LOBYTE(goal_position2), DXL_HIBYTE(goal_position2)};

  groupSyncWrite.addParam(servo_id2, position2_in_bytes);



  // Syncwrite goal position

  int dxl_comm_result = COMM_TX_FAIL;

  dxl_comm_result = groupSyncWrite.txPacket();

  if (dxl_comm_result != COMM_SUCCESS)

    packetHandler->getTxRxResult(dxl_comm_result);



  // Clear syncwrite parameter storage

  groupSyncWrite.clearParam();

}



void syncWrite_position_n_servos_detailed(uint8_t n_servos_write, uint8_t *servo_ids, uint16_t *goal_positions)

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

  // Syncwrite goal position --> detailed version

  int dxl_comm_result = COMM_TX_FAIL;

  dxl_comm_result = groupSyncWrite.txPacket();

  if (dxl_comm_result != COMM_SUCCESS)

    packetHandler->getTxRxResult(dxl_comm_result);



  // Syncwrite goal position --> fast version

  //groupSyncWrite.txPacket();



  // Clear syncwrite parameter storage

  groupSyncWrite.clearParam();

}



void timing_syncWrite_4_servos(uint8_t *servo_ids)

{

  SerialUSB.print("Working on 4 servos");

  int nb_repeats = 10000;

  SerialUSB.print("Timing write goal position with groupSyncWrite method (Dxl sdk), nb_repeats ");

  SerialUSB.println(nb_repeats);

  uint16_t goal_positions[4] = {512, 512, 512, 512};

  unsigned long time_start = millis();

  for (int i = 0; i < nb_repeats; i++)

  {

    syncWrite_position_n_servos(4, servo_ids, goal_positions);

  }

  float duration = float((millis() - time_start)) / nb_repeats;

  SerialUSB.print("Result per operation in milliseconds ");

  SerialUSB.println(duration);

}



void timing_setPosition_all_servos()

{

  SerialUSB.print("Working on 4 servos");

  int nb_repeats = 10000;

  SerialUSB.print("Timing write goal position with write2ByteTxRx method (Dxl sdk), nb_repeats ");

  SerialUSB.println(nb_repeats);

  unsigned long time_start = millis();

  for (int i = 0; i < nb_repeats; i++)

  {

    for (int j = 0; j < n_servos; j++)

    {

      set_goal_position(id[j], 512);

    }

  }

  float duration = float((millis() - time_start)) / nb_repeats;

  SerialUSB.print("Result per block of operation (4 servos) in milliseconds ");

  SerialUSB.println(duration);

}



void restaure_default_motor_parameters(int servo_id){

  //these are the default parameters given in the AX12A manual

  set_compliance_margin(servo_id,1);

  set_compliance_slope(servo_id,32);  

  set_punch(servo_id,32);

}

*/
# 345 "\\\\files2\\data\\dujany\\My Documents\\master_project\\code\\robotis_arduino_sdk\\size_port_packet_handler\\size_port_packet_handler.ino"
void setup()
{
  // put your setup code here, to run once:
  Serial.begin(115200);
  while (!Serial)
    ;

  init_port_and_packet_handler();
   /*

  count_servos();

  

  center_all_servos();

  for (int i = 0; i < n_servos; i++)

    restaure_default_motor_parameters(id[i]);



  

  Serial3.begin(2000000);



  syncWrite_position_2servos(id[0], id[1], 480, 540);

  delay(2000);

  SerialUSB.println(read_present_position(id[0]));

  SerialUSB.println(read_present_position(id[1]));



  SerialUSB.println("Trying sync Read");

  syncRead_position_2servo(id[0], id[1]);



  uint8_t ids_write[3] = {id[0], id[1], id[2]};

  uint16_t positions[3] = {460, 490, 530};

  syncWrite_position_n_servos(3, ids_write, positions);

  delay(2000);

  for (int i = 0; i < n_servos; i++)

    SerialUSB.println(read_present_position(id[i]));



  uint8_t servo_ids_timing[4] = {id[0], id[1], id[2], id[3]};

  timing_syncWrite_4_servos(servo_ids_timing);



  SerialUSB.println("without sync");

  timing_setPosition_all_servos();

  */
# 385 "\\\\files2\\data\\dujany\\My Documents\\master_project\\code\\robotis_arduino_sdk\\size_port_packet_handler\\size_port_packet_handler.ino"
}

void loop()
{
}
// put your main code here, to run repeatedly:
