  /*
  AD7124 Full Test

  Prints out the voltages measured at pins AIN1/AIN, AIN3/AIN2, AIN5/AIN4 and
  AIN7/AIN6. Input voltages must be in the range between 0 and 2.5V.
  This is a complete test program that checks for errors and displays the
  contents of the AD7124 circuit registers.
  For a more accessible example see voltmeter.ino.

  For more on AD7124, see
  http://www.analog.com/media/en/technical-documentation/data-sheets/AD7124-4.pdf

  The circuit:
  - AD7124 connected on the MOSI, MISO, SCK and /SS pins (pin 10)
  - LED active in low state connected to pin 9.

  created 2018
  by epsilonrt https://github.com/epsilonrt

  This example code is in the public domain.

  https://github.com/epsilonrt/ad7124/tree/master/examples
*/
#include <stdlib.h>
#include <ad7124.h>
#include "Packet.h"
#include <TimerOne.h>

using namespace Ad7124;

// In order not to prefix the constants with Ad7124 :: !
//using namespace Ad7124;

#define DT 1000        // interrupt period of timer1 in microseconds, use multiples of hundred
#define I_LOADCELL 3   // Arduino-Loadcell number (written next to the # on loadcell sensor).
#define BAUD_RATE 500000

double cal_gain[3];
double cal_offset[3];

/* constants ================================================================ */
const int ledPin = 5;
const int ssPin = 10;
const int spiEnPin = 9;
const int spiMISOPin = 14;

const int rdyPin = 14; // inverted, DOUT (MISO) pin of the Chip

const double Gain = 128;

/* Calibration ============================================================== */
// Channel 1, 2, 3 --> x, y, z
// Values need to be determined yet
//const double cal_gain[]   = {14740, 14950, 13400};
//const double cal_offset[] = {-1.68, -3.33, 0.10};

/* Frame Handling============================================================ */
int send_data_flag=0; //make sure always new data is sent; not used in the loadcell setup
uint8_t last_byte=0x00;
uint8_t frame_type=0x00;
uint8_t frame_data_length=0x00;
uint8_t frame_location_counter=0x00;
uint8_t arduino_ID=0x00;
uint8_t arduino_ID_target=0x00;
uint8_t cc_byte=0x00;
uint8_t cc_byte_new=0x00;
uint8_t run_command=0x00;
uint8_t enable_reading=0;
uint32_t timestamp=0;

uint8_t loadcell_data[SENSOR_DATA_LENGTH]={0};

int i_loop = 0;

boolean bool_val_arr[4]     = {false};
//double  val_arr[3]          = {999} ;
// uint8_t val_arr[3 * 4]      = {0};
int rec                     = 0;

/* ========================================================================= */

double voltage;


/* macros =================================================================== */
// Evaluate assertion macro
// If the argument expression of this macro with functional form compares equal
// to zero (i.e., the expression is false), a message is written to the serial
// device and abort is called, terminating the program execution.
#define assert(e) ((e) ? (void)0 : __assert(__func__, __LINE__, #e))

/* public variables ========================================================= */
Ad7124Chip adc;

unsigned long tp, tc, tp2, tc2;


//03.05 : I got 6.87 ms as average for LC 6.
//03.05 : I got 6.91 ms as average for LC 9.
//I am leaving this function here for future possible use but it is not called
void timing_check_and_update_loadcells(){
  int n_reps = 10000;
  unsigned long time_start = millis();
  for (int i=0; i<n_reps; i++){
    check_and_update_loadcells();
  }
  unsigned long time_elapsed = millis() - time_start;
  float average_duration = float(time_elapsed)/float(n_reps);
  SerialUSB.print("Duration check_and_update_loadcells of loadcell (average in ms over ");
  SerialUSB.print(n_reps);
  SerialUSB.print(" repetitions) : ");
  SerialUSB.println(average_duration);  
}


// -----------------------------------------------------------------------------
void setup() {
  int ret;

  pinMode (ledPin, OUTPUT);
  digitalWrite (ledPin, 1);

  pinMode (spiEnPin, OUTPUT);
  digitalWrite (spiEnPin, 1); // enable SPI

  //Initialize serial and wait for port to open:
  Serial1.begin(BAUD_RATE);

  Timer1.initialize(DT);         // initialize timer1
  Timer1.attachInterrupt(update_sensors_timers);

  delay(1000);

  Serial1.flush();

/////////////////////////////////////////////////////////////////

  if (I_LOADCELL == 1){
    cal_gain[0]   = 13780;
    cal_gain[1]   = 13827;
    cal_gain[2]   = 12504;
    cal_offset[0] = -0.34; 
    cal_offset[1] = -0.06; 
    cal_offset[2] = 0.20;
  }
  else if (I_LOADCELL == 3){
    cal_gain[0]   = 13530;
    cal_gain[1]   = 13660;
    cal_gain[2]   = 12240;
    cal_offset[0] = -3.53; 
    cal_offset[1] = -3.38; 
    cal_offset[2] = 0.83;
  }
  else if (I_LOADCELL == 4){
    cal_gain[0]   = 13230;
    cal_gain[1]   = 13330;
    cal_gain[2]   = 12385;
    cal_offset[0] = -3.05; 
    cal_offset[1] = -1.73; 
    cal_offset[2] = -0.03;
  }
  else if (I_LOADCELL == 5){
    cal_gain[0]   = 13607;
    cal_gain[1]   = 13823;
    cal_gain[2]   = 12354;
    cal_offset[0] = -1.60; 
    cal_offset[1] = -3.16; 
    cal_offset[2] = 0.08;
  }
  else if (I_LOADCELL == 6){
    cal_gain[0]   = 13712;
    cal_gain[1]   = 13614;
    cal_gain[2]   = 12254;
    cal_offset[0] = -0.27; 
    cal_offset[1] = -1.65; 
    cal_offset[2] = -2.69;
  }
  else if (I_LOADCELL == 9){
    cal_gain[0]   = 13124;
    cal_gain[1]   = 13301;
    cal_gain[2]   = 12441;
    cal_offset[0] = 0.94; 
    cal_offset[1] = 3.25; 
    cal_offset[2] = -0.18;
  }
  else if (I_LOADCELL == 11){
    cal_gain[0]   = 13516;
    cal_gain[1]   = 13481;
    cal_gain[2]   = 12418;
    cal_offset[0] = 0.66; 
    cal_offset[1] = 1.49; 
    cal_offset[2] = -1.91;
  }
  else if (I_LOADCELL == 12){
    cal_gain[0]   = 13761;
    cal_gain[1]   = 13823;
    cal_gain[2]   = 12550;
    cal_offset[0] = -1.3; 
    cal_offset[1] = -2.11; 
    cal_offset[2] = 0.61;
  }
////////////////////////////////////////////////////

  // Initializes the AD7124 device, the pin /CS (/SS)
  ret = adc.begin (ssPin);
  assert (ret == 0);

  //Serial.println (F ("\nSetting up 3 channels with:"));
  for (uint8_t i = 0; i < 3; i++) {

    // ConfigNumber ReferenceVoltageSource, PGA, bipolar
    ret = adc.setConfig (i, RefIn1, Pga128, true);
    assert (ret == 0);
    printreg (Config_0 + i);


    //ret = adc.setConfigFilter (i, Sinc4Filter, 2047); // 9.4sps when single channel is used... in multi channels sps is roughly 1/4 of this value (even a bit less)
    //ret = adc.setConfigFilter (i, Sinc4Filter, 384);  // 50sps ... for example when multi channels are used, this gives 60 sps?
    //ret = adc.setConfigFilter (i, Sinc4Filter, 60);   // 320sps
    //ret = adc.setConfigFilter (i, Sinc4Filter, 30);   // 640sps
    ret = adc.setConfigFilter (i, Sinc4Filter, 15);   // 1280sps         // CRM or one faster  // CCM nice one !
    //ret = adc.setConfigFilter (i, Sinc4Filter, 8);    // 2400sps           // THIS SEEMS TO BE A GOOD ONE THAT WE CAN READ IN CRM CONSECUTIVELY DIFFERENT CHANNELS OR MAYBE ONE SLOWER ... NEED TO CHECK WITH LOGIC ANALYZER MAYBE
    //ret = adc.setConfigFilter (i, Sinc4Filter, 4);    // 4800sps
    //ret = adc.setConfigFilter (i, Sinc4Filter, 2);    // 9600sps
    //ret = adc.setConfigFilter (i, Sinc4Filter, 1);    // 19200sps
    //ret = adc.setConfigFilter (i, Sinc4FastFilter, 384);  // 2.63sps
    //ret = adc.setConfigFilter (i, Sinc4FastFilter, 120);  // 8.42sps
    //ret = adc.setConfigFilter (i, Sinc4FastFilter, 24);   // 42.11sps
    //ret = adc.setConfigFilter (i, Sinc4FastFilter, 20);   // 50.53sps
    //ret = adc.setConfigFilter (i, Sinc4FastFilter, 2);    // 505.26sps
    //ret = adc.setConfigFilter (i, Sinc4FastFilter, 1);    // 1010.53sps
    assert (ret == 0);
    printreg (Filter_0 + i);

    //ret = adc.setChannel (i, i, (i * 2 + 1), AVSSInput);
    ret = adc.setChannel (i, i, 2 * i, (i * 2 + 1));
    assert (ret == 0);
    printreg (Channel_0 + i);
  }

  // Calibration parameters 
  for (uint8_t i = 0; i < 3; i++) {
    printreg (Offset_0 + i);
    printreg (Gain_0 + i);
  }

  // Enabling channels 
  for (uint8_t i = 0; i < 3; i++) {
    int enabled = adc.enableChannel (i);
    printreg (Channel_0 + i);
  }

  // ADC CONTROL REG 
  printreg (ADC_Control);

  //Serial.println (F ("\nSetting up ADC for Operation: Continuous mode (either Conversion or Read), FullPower"));
  /* // // DATA WITHOUT STATUS IS NOT AN OPTION FOR US
    //ret = adc.setAdcControl (StandbyMode, FullPower, true);
    //ret = adc.setAdcControl (ContinuousMode, FullPower, true);
    //ret = adc.setRegister(ADC_Control, 0x1180);  // ContinuousMode, FullPower, NoStatus
  */
  ret = adc.setRegister(ADC_Control, 0x1580);  // ContinuousConversionMode, FullPower, WithStatus
  //ret = adc.setRegister(ADC_Control, 0x1D80);  // ContinuousReadMode, FullPower, WithStatus
  assert (ret == 0);
  //printreg (ADC_Control);

// DATA COLLECTION ///////////////////////////////////////////////////////////

check_and_update_loadcells();

// End of DATA COLLECTION ///////////////////////////////////////

  tp = micros();
  tc = micros();
  tp2 = micros();
  tc2 = micros();

}











// -----------------------------------------------------------------------------
void loop() {

  
int flagVerbose = 0;
double outData;
int i;
uint8_t inByte, outByte;

// check if data is available
if(Serial1.available()){
  inByte = Serial1.read();
  //SerialUSB.print("Read byte: \t");
  //SerialUSB.println(inByte);
  outByte=inByte; //if nothing is happening send back what is received
  
  if((inByte == FRAME_SYNC_0)  && frame_location_counter==0)
  {
    frame_location_counter=1;
    cc_byte=0x00;
    cc_byte_new=0x00;
    frame_type=0x00;
    arduino_ID=0x00;
    enable_reading=0;
    //send_data_flag=0;
  }  


  
  if((inByte == FRAME_SYNC_1) && (last_byte == FRAME_SYNC_0))
  {
    frame_location_counter=2;

  }

  // POSITIONAL COUNTER
  else if(frame_location_counter==2)
  {
    frame_location_counter++;
    outByte=inByte+1;
    arduino_ID=outByte;
  }

  // FRAME TYPE
  else if(frame_location_counter==3)
  {
    frame_location_counter++;
    frame_type=inByte;
  }

  // FRAME DATA LENGTH
  else if(frame_location_counter==4){
    frame_location_counter++;
    frame_data_length=inByte;
  }  
  
  // FRAME DATA
  else if(frame_location_counter > 4 && frame_location_counter <= (4+frame_data_length))
  {
    cc_byte+=inByte;

    // INSERT READINGS FROM SENSORS
    if ( (frame_type==FRAME_TYPE_RECORDING)||(frame_type==FRAME_TYPE_NORMAL)||(frame_type==FRAME_TYPE_IMU_UPDATE_OFF))
    {
      uint8_t place_holder_arduino_no = 1 + (uint8_t) (frame_location_counter-5) / SENSOR_DATA_LENGTH;    // Keeps track to which Arduino the inByte belongs.
      uint8_t byte_no=(frame_location_counter-5) % SENSOR_DATA_LENGTH;                                    // Number of the byte in data array
      if (place_holder_arduino_no==arduino_ID)
      {
        if (byte_no==(SENSOR_DATA_LENGTH-1))
        {
          loadcell_data[byte_no]=timestamp;
          //send_data_flag = 0;
        }
        outByte=loadcell_data[byte_no];
      }
      else{ //if ID doesn't match, do nothing
      }
    }

    cc_byte_new+=outByte;
    frame_location_counter++;
  }  
  
  
    // CHECKSUM
    else if (frame_location_counter==(5+frame_data_length) && frame_data_length != 0)
    {
      i_loop++;
      // What does this statement accomplish?
      // It basically takes the checksum in the previous frame and the calculation of the checksum based on the data of the previous frame
      // and then it compares the two.
      if (inByte!=cc_byte){
        outByte=~cc_byte_new;
        run_command=0;
      }
      else
      {
        outByte=cc_byte_new;
        
        if (run_command==1)
        {
          run_command++;
        }
      }
      frame_location_counter++;
    }

    else if (frame_location_counter==(6+frame_data_length))
    {
      //end frame check or whatever else
      if (inByte!=END_FRAME)
      {
        run_command=0;
      }
      else
      {
        if (run_command==2)
        {
          run_command++;
        }
        // inByte=END_FRAME;
        // outByte=END_FRAME;
        frame_location_counter=0; //reset the frame location counter
        enable_reading = 1; //enable loadcells reading
      }
    }
    // Maybe raises problems: replace by frame_size - 1 ?
    if(frame_location_counter>255){
      frame_location_counter=0;
    }
    //SerialUSB.print("t, byte sent : \t");
    //SerialUSB.println(outByte);
    Serial1.write(outByte);

/*
    if(inByte == 0x55){
      Serial.println(frame_data_length);
    }
*/

    last_byte=inByte;  

    //Serial.println("Enable reading:");
    // Serial.println(enable_reading);

    if (enable_reading==1){
      check_and_update_loadcells();
    }

}

}


/* internal public functions ================================================ */

// -----------------------------------------------------------------------------
// Prints AD7124 register value
void printreg (int reg) {
  char name[16];

  if (Ad7124Register::copyRegisterName (reg, name) > 0) {
    long value = adc.getRegister (reg);

    if (value >= 0) {
      /*
            Serial.print (name);
            Serial.print ("(0x");
            Serial.print (reg, HEX);
            Serial.print (") = 0x");
            Serial.println (value, HEX);
      */
    }
  }
}

// -----------------------------------------------------------------------------
// Print assertion function
// a message is written to the serial device and abort is called, terminating
// the program execution.
void __assert (const char *__func, int __lineno, const char *__sexp) {

  /*
    Serial.print ("Error in ");
    Serial.print (__func);
    Serial.print ("(): line ");
    Serial.print (__lineno);
    Serial.print (", assertion failed: ");
    Serial.print (__sexp);
    Serial.println (", abort !");
  */

  delay (1000); // leave time for the message to appear before aborting
  abort();
}


// ----------------------------------------------------------------------------


void exe_blue_command(byte inByte){

  if(inByte == 0x00){
    digitalWrite(ledPin, LOW);
  }
  else if (inByte == 0x01){
    digitalWrite(ledPin, HIGH);
  }

}

double convert_voltage_to_force(double voltage, int i_loadcell) {
  return cal_gain[i_loadcell] * voltage + cal_offset[i_loadcell];
}

void get_data(){

  // Declare variables
  int64_t value;
  int64_t data;
  unsigned long datal;
  unsigned long err;
  unsigned long rdy_n;
  double force_tmp;
  int8_t chnl;


/* // DATA WITHOUT STATUS IS NOT AN OPTION FOR US
    //value = adc.read (i);                 // Single read mode. standby. should return 24 bit value (16,777,215) (to long container, 32 bits -2,147,483,648,+2,147,483,647)
    //value = adc.getData ();               // can be usef for CCM, does not return status
    //value = adc.getRegister(Data);        // similar to getData function
  
  //value = adc.getDataWithStatusCRM ();  // just 4 byte read including status. takes 88us, super fast. BUT REQUIRES EXTRA CHEKS THAT ARE NOT IMPLEMENTED YET
*/

  // Get new value from ADC
  value = adc.getDataWithStatusCCM ();    // sends 0x42 and reads 4 bytes including status. Each reading (5 byte opeartion) takes like 1.3ms for some reason. There is some waiting involved.

  // Process data
  data = value & 0xFFFFFF00;
  datal = (unsigned long)data;
  datal = datal >> 8;
  chnl = value & 0xF;
  err = (unsigned long)value & 0x40;  // flag to specify if there was an error.
  err = err >> 6;                     // either 1 (faulty) or 0 (ok) ... can be used for a check maybe....
  rdy_n = (unsigned long)value & 0x80;  // flag to specify if channel was ready to read.
  rdy_n = rdy_n >> 7;

  if (value >= 0) {

    // value, gain, vref, bipolar
    voltage = Ad7124Chip::toVoltage ((long)datal, Gain, 3.3, true);

    // If there was already data collected for channel chnl, the data gets updated with the new value.
    // Only update when no error occured.
    if (err == 0) {

      // Convert voltage to force
      force_tmp     = convert_voltage_to_force(voltage, chnl);

      // Copy values of force_tmp to data array
      memcpy(&loadcell_data[chnl * 4],&force_tmp,sizeof(voltage));

      // Set boolean to true if data is obtained for a particular channel
      bool_val_arr[chnl] = true;
      
    }
  }
  else {
    // Fail
  }  
  
}




void check_data_complete(){
    int i = 0;

    // Check conditions: if all channels have data, bool_val_arr[3] = true.
    for ( ; i < 3; i++) {
      if ( !bool_val_arr[i] )
        break;
    }
    bool_val_arr[3] = (i == 3);
}

void reset_vars(){

  // Looping over all channels
  for (int i = 0; i < 3; i++) {
    // Reset arrays (boolean and data)

    bool_val_arr[i]         = false;
    for(int j = 0; j < 4; j++){
      loadcell_data[i * 4 + j]        = 0  ;
    }
  }
  
  // Reset bool_val_arr[3], which is the boolean that indicates whether all channels have new data or not
  bool_val_arr[3]   = {false};
  enable_reading = 0;
  // timestamp = 0;  
}


void check_and_update_loadcells(){

  reset_vars();
  
  while(bool_val_arr[3] == false){
    get_data();
    check_data_complete();
  } 
}

// update the timer
void update_sensors_timers(void) {
  timestamp++;
}



void print_loadcelldata(){

  for(int k = 0; k<4 ; k++){
    Serial.print(loadcell_data[k], HEX);
    Serial.print(", ");
  }
  Serial.print("\t\t");
  for(int k = 4; k<8 ; k++){
    Serial.print(loadcell_data[k], HEX);
    Serial.print(", ");
  }
  Serial.print("\t\t");
  for(int k = 8; k<12 ; k++){
    Serial.print(loadcell_data[k], HEX);
    Serial.print(", ");
  }
  Serial.print('\n');

}
