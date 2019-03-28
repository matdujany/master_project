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

using namespace Ad7124;


// Set which channel to calibrate:

#define I_LOADCELL 6
#define I_AXIS     1
#define BAUD_RATE  500000

double cal_gain[3];
double cal_offset[3];

// In order not to prefix the constants with Ad7124 :: !
//using namespace Ad7124;

/* constants ================================================================ */
const int ssPin       = 10;
const int spiEnPin    = 9;
const int spiMISOPin  = 14;
const int rdyPin      = 14; // inverted, DOUT (MISO) pin of the Chip
const double Gain     = 128;

/* Calibration ============================================================== */
// Channel 1, 2, 3 --> x, y, z
// Values need to be determined yet

double voltage;
double voltage_arr[3];
double voltage_arr_mean_values[3];
double force_arr[3];
double force_arr_mean_values[3];

boolean bool_val_arr[4]     = {false};
int rec                     = 0;

/* macros =================================================================== */
// Evaluate assertion macro
// If the argument expression of this macro with functional form compares equal
// to zero (i.e., the expression is false), a message is written to the serial
// device and abort is called, terminating the program execution.
#define assert(e) ((e) ? (void)0 : __assert(__func__, __LINE__, #e))

/* public variables ========================================================= */
Ad7124Chip adc;

// -----------------------------------------------------------------------------

// Prints AD7124 register value
void printreg (int reg) {
  char name[16];

  if (Ad7124Register::copyRegisterName (reg, name) > 0) {
    long value = adc.getRegister (reg);
    if (value >= 0) {
//      /*
            Serial.print (name);
            Serial.print ("(0x");
            Serial.print (reg, HEX);
            Serial.print (") = 0x");
            Serial.println (value, HEX);
//      */
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
      force_tmp         = convert_voltage_to_force(voltage, chnl);
      force_arr[chnl]   = force_tmp;
      voltage_arr[chnl] = voltage;

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
    // Reset array
    bool_val_arr[i]         = false;
  }
  
  // Reset bool_val_arr[3], which is the boolean that indicates whether all channels have new data or not
  bool_val_arr[3]   = {false};
}


void check_and_update_loadcells(){

  reset_vars();
  
  while(bool_val_arr[3] == false){
    get_data();
    check_data_complete();
  }  
}

void compute_mean_lc_values(int nb_values_mean, unsigned long delay_frames){
  for (int i = 0; i < 3; i++) {
    voltage_arr_mean_values[i]=0;  
  }
  for (int k = 0; k < nb_values_mean; k++){
    check_and_update_loadcells();
    for (int i = 0; i < 3; i++) {
      voltage_arr_mean_values[i]+= voltage_arr[i]/nb_values_mean;  
    }
    delay(500);    
  }
  for (int i = 0; i < 3; i++) {
      force_arr_mean_values[i]=  convert_voltage_to_force(voltage_arr_mean_values[i],i);  
  }
}


// -----------------------------------------------------------------------------
void setup() {

  int ret;

  pinMode (spiEnPin, OUTPUT);
  digitalWrite (spiEnPin, 1); // enable SPI

  //Initialize serial and wait for port to open:
  Serial1.begin(BAUD_RATE);

  delay(3000);

  if (I_LOADCELL == 1){
    cal_gain[0]   = 13780;
    cal_gain[1]   = 13827;
    cal_gain[2]   = 12504;
    cal_offset[0] = -0.34; 
    cal_offset[1] = -0.06; 
    cal_offset[2] = 0.20;
  }
  else if (I_LOADCELL == 4){
    cal_gain[0]   = 13230;
    cal_gain[1]   = 13330;
    cal_gain[2]   = 12385;
    cal_offset[0] = -3.05; 
    cal_offset[1] = -1.72; 
    cal_offset[2] = -0.03;
  }
  else if (I_LOADCELL == 5){
    cal_gain[0]   = 13612;
    cal_gain[1]   = 13785;
    cal_gain[2]   = 12294;
    cal_offset[0] = -1.58; 
    cal_offset[1] = -3.20; 
    cal_offset[2] = 0.06;
  }
  else if (I_LOADCELL == 6){
    cal_gain[0]   = 13712;
    cal_gain[1]   = 13764;
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
    cal_gain[0]   = 13515;
    cal_gain[1]   = 13480;
    cal_gain[2]   = 12418;
    cal_offset[0] = 0.66; 
    cal_offset[1] = 1.49; 
    cal_offset[2] = -1.91;
  }

  Serial1.flush();

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
/*
cal_offset[0] = -force_arr[0];
cal_offset[1] = -force_arr[1];
cal_offset[2] = -force_arr[2];
*/
Serial.print("F_x");
Serial.print("\t\t");
Serial.print("F_y");
Serial.print("\t\t");
Serial.print("F_z");
Serial.print("\n");

}



// -----------------------------------------------------------------------------
void loop() {
  compute_mean_lc_values(15,200);
  //check_and_update_loadcells();

  // Print info:

//  /*
  Serial.print(voltage_arr_mean_values[0], 8);
  Serial.print("\t"); 
  Serial.print(voltage_arr_mean_values[1], 8);
  Serial.print("\t");  
  Serial.print(voltage_arr_mean_values[2], 8);
  Serial.print("\t");    
  Serial.print(force_arr_mean_values[0] / 9.81, 8);
  Serial.print("\t");    
  Serial.print(force_arr_mean_values[1] / 9.81, 8);
  Serial.print("\t");
  Serial.print(force_arr_mean_values[2] / 9.81, 8);
  Serial.print("\n");
// */

  if(Serial.available())
  {
    char temp = Serial.read();
    if(temp == '+' || temp == 'a')
      cal_gain[I_AXIS] += 10;
    else if(temp == '-' || temp == 'z')
      cal_gain[I_AXIS] -= 10;
    else if(temp == 'p'){
      Serial.print("\nReport for loadcell ");
      Serial.println(I_LOADCELL);
      Serial.println("-------------------------");
      Serial.print("Gain: \t\t");
      Serial.println((int) cal_gain[I_AXIS]);
      Serial.print("Offset: \t");
      Serial.println(cal_offset[I_AXIS], 8);
      delay(4000);
    }  
    else if(temp == 'r'){
      Serial.print("\nReset offset for loadcell channel ");
      Serial.println(I_AXIS);
      Serial.println("-------------------------");
      Serial.print("Old offset: \t");      
      Serial.println(cal_offset[I_AXIS]);

      cal_offset[I_AXIS] = cal_offset[I_AXIS] - force_arr[I_AXIS];
      Serial.print("New offset: \t");      
      Serial.println(cal_offset[I_AXIS]);      
      Serial.print("in KG: ");      
      Serial.println( (cal_offset[I_AXIS] - force_arr[I_AXIS]) / 9.81);      
      delay(4000);
    }
  }  
}