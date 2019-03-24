#include <DynamixelSDK.h>

// AX-series Control table address
#define ADDR_GOAL_POSITION              30
#define ADDR_PRESENT_POSITION           36    
#define ADDR_PRESENT_LOAD               40         
#define ADDR_IS_MOVING                  46               
#define ADDR_CW_COMPLIANCE_MARGIN       26
#define ADDR_CCW_COMPLIANCE_MARGIN      27
#define ADDR_CW_COMPLIANCE_SLOPE        28
#define ADDR_CCW_COMPLIANCE_SLOPE       29
#define ADDR_PUNCH                      48

// Protocol version
#define PROTOCOL_VERSION    1.0 // AX supports only Protocol Version 1.0 --> syncWrite OK but no syncRead
#define BAUDRATE_DXL      1000000
#define DEVICE_NAME         "1" //DEVICENAME "1" -> Serial1(OpenCM9.04 DXL TTL Ports)

#define MAX_SERVOS      16

#define SOFT_COMPLIANCE_MARGIN          50  //uint8_t value
#define SOFT_COMPLIANCE_SLOPE           1   //uint8_t value
#define SOFT_PUNCH                      1   //uint16_t value
#define STIFF_COMPLIANCE_MARGIN         0
#define STIFF_COMPLIANCE_SLOPE          32           
#define STIFF_PUNCH                     32

#define STEP_AMPL_DEG    15

uint8_t id[MAX_SERVOS];
uint8_t n_servos = 0;

dynamixel::PortHandler *portHandler;     //for communication with Dynamixels
dynamixel::PacketHandler *packetHandler; //for communication with Dynamixels

int n_twitches = 2;
unsigned long beginning_duration = 2000; //in ms
unsigned long part0_duration = 5000; //in ms
unsigned long part1_duration = 2000; //in ms
unsigned long part2_duration = 2000; //in ms
unsigned long recentering_duration = 1000; //in ms

unsigned long nb_samples_dynamic = 0;
unsigned long nb_samples_static = 0;
unsigned long total_duration_dynamic = 0;
unsigned long total_duration_static = 0;

unsigned long global_start_time;

uint16_t pos_step_twitch = STEP_AMPL_DEG * 3.413;

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

void init_port_and_packet_handler()
{
  portHandler = dynamixel::PortHandler::getPortHandler(DEVICE_NAME);
  packetHandler = dynamixel::PacketHandler::getPacketHandler(PROTOCOL_VERSION);
  // Open port
  if (portHandler->openPort())
  {
    SerialUSB.print("Succeeded to open the port!\n");
  }
  else
  {
    SerialUSB.print("Failed to open the port!\n");
    SerialUSB.print("Press any key to terminate...\n");
    return;
  }

  // Set port baudrate
  if (portHandler->setBaudRate(BAUDRATE_DXL))
  {
    SerialUSB.print("Succeeded to change the baudrate!\n");
  }
  else
  {
    SerialUSB.print("Failed to change the baudrate!\n");
    SerialUSB.print("Press any key to terminate...\n");
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

int16_t read_present_load(uint8_t servo_id)
{
  int16_t load = 0;
  uint16_t present_load_raw = 0; // Present position
  packetHandler->read2ByteTxRx(portHandler, servo_id, ADDR_PRESENT_LOAD, &present_load_raw);
  if (present_load_raw>1024)
    load = present_load_raw-1024;
  else
    load = -present_load_raw;
  return load;
}


void set_goal_position(uint8_t servo_id, uint16_t goal_position)
{
  packetHandler->write2ByteTxRx(portHandler, servo_id, ADDR_GOAL_POSITION, goal_position);
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

void center_motor(uint8_t servo_id){
  set_goal_position(servo_id,512);
}

void center_all_motors()
{
  for (int i_servo = 0; i_servo < n_servos; i_servo++)
  {
    center_motor(id[i_servo]);
  }
  SerialUSB.println("all motors are centered");
  delay(1000);
}

void restaure_default_parameters(uint8_t servo_id)
{
  set_compliance_margin(servo_id, 1);
  set_compliance_slope(servo_id, 32);
  set_punch(servo_id, 32);
}

void restaure_default_parameters_all_motors()
{
  for (int i_servo = 0; i_servo < n_servos; i_servo++)
  {
    restaure_default_parameters(id[i_servo]);
  }
  delay(1000);
  SerialUSB.println("all motor parameters set to default");
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

void make_all_servos_compliant()
{
  for (int i_servo = 0; i_servo < n_servos; i_servo++)
  {
    make_servo_compliant(id[i_servo]);
  }
  SerialUSB.println("All servos are set to compliant parameters");
}

void make_all_servos_stiff()
{
  for (int i_servo = 0; i_servo < n_servos; i_servo++)
  {
    make_servo_stiff(id[i_servo]);
  }
  SerialUSB.println("All servos are set to stiff parameters");
}

void printSerialUSB_func(int16_t (*func)(uint8_t), uint8_t servo_id){
  SerialUSB.println(func(servo_id));
}

void printSerial3_position(uint8_t servo_id){
  Serial3.println(read_present_position(servo_id));
}

void printSerial3_load(uint8_t servo_id){
  Serial3.println(read_present_load(servo_id));
}

void printSerial3_both(uint8_t servo_id){
  Serial3.println(read_present_position(servo_id));
  Serial3.println(read_present_load(servo_id));
}

void printSerial3_position_ts(uint8_t servo_id){
  Serial3.println(read_present_position(servo_id));
  Serial3.println(double(micros()-global_start_time)/(double(1000)));
}

void printSerial3_load_ts(uint8_t servo_id){
  Serial3.println(read_present_load(servo_id));
  Serial3.println(double(micros()-global_start_time)/(double(1000)));
}

void printSerial3_both_ts(uint8_t servo_id){
  Serial3.println(read_present_position(servo_id));
  Serial3.println(read_present_load(servo_id));
  Serial3.println(double(micros()-global_start_time)/(double(1000)));
}

//just a wrapper function returning an int16 from present position, does not add any delay in the execution
int16_t read_present_position_int16(uint8_t servo_id){
  int16_t present_position = read_present_position(servo_id);
  return present_position;
}

void compare_timing_readpresentpos_int16(uint8_t servo_id){
  int nb_repeats = 10000;
  unsigned long time_start=millis();
  for (int i=0; i<nb_repeats; i++){
    read_present_position_int16(servo_id);
  }
  unsigned long  time_end =millis();
  SerialUSB.println((double)(time_end-time_start)/(double)(nb_repeats));

  unsigned long time_start2=millis();
  for (int i=0; i<nb_repeats; i++){
    read_present_position(servo_id);
  }
  unsigned long  time_end2 =millis();
  SerialUSB.println((double)(time_end2-time_start2)/(double)(nb_repeats)); 
}

void compare_timing_printTime(){
  int nb_repeats = 10000;
  unsigned long time_start = micros();
  for (int i=0; i<nb_repeats; i++){
    Serial3.println(micros());
  }
  unsigned long time_end = micros();
  SerialUSB.print("Time in micros per operation to print micros() in Serial3 :");
  SerialUSB.println((double)(time_end-time_start)/(double)(nb_repeats));

  unsigned long time_start2 = micros();
  for (int i=0; i<nb_repeats; i++){
    Serial3.println(micros()-time_start2);
  }
  unsigned long time_end2 = micros();
  SerialUSB.print("Time in micros per operation to print micros()-time_start2 in Serial3 :");
  SerialUSB.println((double)(time_end2-time_start2)/(double)(nb_repeats)); 
}

unsigned long record_static(unsigned long duration, void (*func_rec_print)(uint8_t))
{
  unsigned long current_time = 0; //current_time_in_ms
  unsigned long start_time = millis();
  while (current_time < duration)
  {
    for (int i_servo = 0; i_servo < n_servos; i_servo++)
    {
      func_rec_print(id[i_servo]);
    }
    nb_samples_static++;
    current_time = millis() - start_time;
  }
  return current_time;
}

unsigned long record_progressive_twitch(unsigned long step_duration, uint8_t servo_id, int dir_sign, void (*func_rec_print)(uint8_t))
{
  uint16_t command_pos = 512;
  unsigned long current_time = 0; //current_time_in_ms
  double step_duration_double = double(step_duration);
  unsigned long start_time = millis();
  while (current_time < step_duration)
  {
    command_pos = 512 + dir_sign * pos_step_twitch * double(current_time) / step_duration_double;
    set_goal_position(servo_id, command_pos);
    for (int i_servo = 0; i_servo < n_servos; i_servo++)
    {
      func_rec_print(id[i_servo]);
    }
    nb_samples_dynamic++;
    current_time = millis() - start_time;
  }
  return current_time;
}

void run_progressive_twitch(int mode, void (*func_rec_print)(uint8_t))
{
  // mode = 0 : record position 
  // mode = 1 : record load 

  int dir_sign[] = {-1, 1};

  if (mode == 0)
    make_all_servos_compliant();
  else 
    make_all_servos_stiff();

  for (int i_servo = 0; i_servo < n_servos; i_servo++)
  {
    //the motor that will move should be stiff
    if (mode == 0)
      make_servo_stiff(id[i_servo]);

    for (int i_dir = 0; i_dir < 2; i_dir++)
    {
      //goes from 512 to up or down position slowly
      total_duration_dynamic += record_progressive_twitch(part0_duration, id[i_servo], dir_sign[i_dir], func_rec_print);
      //stay in this position for part1 duration
      total_duration_static += record_static(part1_duration,func_rec_print);
      //goes back to centering for part2 duration
      set_goal_position(id[i_servo], 512);
      total_duration_static += record_static(part2_duration,func_rec_print);
    }

    //the motors are set back to their default parameters, which will cause them to move to their last position (512 for everyone) if they were too compliant
    // or to stop vibrating if they were too stiff
    restaure_default_parameters_all_motors();
    
    total_duration_static += record_static(recentering_duration,func_rec_print);

    //the motors are made compliant again for the next servo.
    if (mode == 0)
      make_all_servos_compliant();
  }
}


void run_progressive_twitch_wrapper(int mode, boolean record_both){
  // mode = 0 : the main record is position, motors compliant
  // mode = 1 : the main record is load, motors stiff
  // if record_both set to true, position and load will be recorded but it will slow down the sampling time (factor 2).
  void (*func_rec_print)(uint8_t);
  if (mode == 0)
    func_rec_print = &printSerial3_position_ts;
  else 
    func_rec_print = &printSerial3_load_ts;
  if (record_both)
    func_rec_print = &printSerial3_both_ts;

  global_start_time = micros();
  total_duration_static += record_static(beginning_duration,func_rec_print); //to have initial data value
  for (int i_twitch = 0; i_twitch < n_twitches; i_twitch++)
  {
    run_progressive_twitch(mode,func_rec_print);
  }  
}

void setup()
{
  while(!SerialUSB);
  init_port_and_packet_handler();
  count_servos();
  delay(5000);


  Serial3.begin(2000000); //for sending to Matlab via ftdi.
  Serial3.flush();
  restaure_default_parameters_all_motors();
  center_all_motors();

  //compare_timing_printTime();

  
  // mode = 0 : the main record is position, motors compliant
  // mode = 1 : the main record is load, motors stiff
  // if record_both set to true, position and load will be recorded but it will slow down the sampling time (factor 2).
  int mode = 0;
  boolean record_both = false;
  run_progressive_twitch_wrapper(mode,record_both);


  //Sending the results
  Serial3.println(record_both);
  Serial3.println(n_twitches);
  Serial3.println(beginning_duration);
  Serial3.println(part0_duration);
  Serial3.println(part1_duration);
  Serial3.println(part2_duration);
  Serial3.println(recentering_duration);
  Serial3.println(nb_samples_static);
  Serial3.println(nb_samples_dynamic);
  Serial3.println(total_duration_static);
  Serial3.println(total_duration_dynamic);
  Serial3.println(n_servos);
  Serial3.println(1500); //to tell Matlab it can stop recording

  restaure_default_parameters_all_motors();
  
  
}

void loop()
{
  // put your main code here, to run repeatedly:
}
