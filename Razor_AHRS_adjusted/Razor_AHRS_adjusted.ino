

/*****************************************************************/
/*********** USER SETUP AREA! Set your options here! *************/
/*****************************************************************/

// HARDWARE OPTIONS
/*****************************************************************/
// Select your hardware here by uncommenting one line!
//#define HW__VERSION_CODE 10125 // SparkFun "9DOF Razor IMU" version "SEN-10125" (HMC5843 magnetometer)
#define HW__VERSION_CODE 10736 // SparkFun "9DOF Razor IMU" version "SEN-10736" (HMC5883L magnetometer)
//#define HW__VERSION_CODE 10183 // SparkFun "9DOF Sensor Stick" version "SEN-10183" (HMC5843 magnetometer)
//#define HW__VERSION_CODE 10321 // SparkFun "9DOF Sensor Stick" version "SEN-10321" (HMC5843 magnetometer)
//#define HW__VERSION_CODE 10724 // SparkFun "9DOF Sensor Stick" version "SEN-10724" (HMC5883L magnetometer)


// OUTPUT OPTIONS
/*****************************************************************/
// Set your serial port baud rate used to send out data here!
#define OUTPUT__BAUD_RATE 500000 //57600 works, 115200 is bad. 250k and 500k should work

// Sensor data output interval in milliseconds
// This may not work, if faster than 20ms (=50Hz)
// Code is tuned for 20ms, so better leave it like that
#define OUTPUT__DATA_INTERVAL 20  // in milliseconds

// Output mode definitions (do not change)
#define OUTPUT__MODE_CALIBRATE_SENSORS 0 // Outputs sensor min/max values as text for manual calibration
#define OUTPUT__MODE_ANGLES 1 // Outputs yaw/pitch/roll in degrees
#define OUTPUT__MODE_SENSORS_CALIB 2 // Outputs calibrated sensor values for all 9 axes
#define OUTPUT__MODE_SENSORS_RAW 3 // Outputs raw (uncalibrated) sensor values for all 9 axes
#define OUTPUT__MODE_SENSORS_BOTH 4 // Outputs calibrated AND raw sensor values for all 9 axes
// Output format definitions (do not change)
#define OUTPUT__FORMAT_TEXT 0 // Outputs data as text
#define OUTPUT__FORMAT_BINARY 1 // Outputs data as binary float

// Select your startup output mode and format here!
int output_mode = OUTPUT__MODE_ANGLES;
int output_format = OUTPUT__FORMAT_TEXT;

// Select if serial continuous streaming output is enabled per default on startup.
#define OUTPUT__STARTUP_STREAM_ON true  // true or false

// If set true, an error message will be output if we fail to read sensor data.
// Message format: "!ERR: reading <sensor>", followed by "\r\n".
boolean output_errors = false;  // true or false

// Bluetooth
// You can set this to true, if you have a Rovering Networks Bluetooth Module attached.
// The connect/disconnect message prefix of the module has to be set to "#".
// (Refer to manual, it can be set like this: SO,#)
// When using this, streaming output will only be enabled as long as we're connected. That way
// receiver and sender are synchronzed easily just by connecting/disconnecting.
// It is not necessary to set this! It just makes life easier when writing code for
// the receiving side. The Processing test sketch also works without setting this.
// NOTE: When using this, OUTPUT__STARTUP_STREAM_ON has no effect!
#define OUTPUT__HAS_RN_BLUETOOTH false  // true or false

// Calibration 27.03 Matthieu:

#define ACCEL_X_MIN ((float) -265)
#define ACCEL_X_MAX ((float) 280)
#define ACCEL_Y_MIN ((float) -277)
#define ACCEL_Y_MAX ((float) 273)
#define ACCEL_Z_MIN ((float) -299)
#define ACCEL_Z_MAX ((float) 240)

// "magn x,y,z (min/max) = -511.00/581.00  -516.00/568.00  -489.00/486.00"
//#define MAGN_X_MIN ((float) -511)
//#define MAGN_X_MAX ((float) 581)
//#define MAGN_Y_MIN ((float) -516)
//#define MAGN_Y_MAX ((float) 568)
//#define MAGN_Z_MIN ((float) -489)
//#define MAGN_Z_MAX ((float) 486)

// Extended magn
#define CALIBRATION__MAGN_USE_EXTENDED true
const float magn_ellipsoid_center[3] = {80.7052, -48.2576, 3.04080};
const float magn_ellipsoid_transform[3][3] = {{0.859481, 0.00639267, -0.00196188}, {0.00639267, 0.889663, 0.0290560}, {-0.00196188, 0.0290560, 0.992348}};

// Extended magn (with Sennheiser HD 485 headphones)
//#define CALIBRATION__MAGN_USE_EXTENDED true
//const float magn_ellipsoid_center[3] = {72.3360, 23.0954, 53.6261};
//const float magn_ellipsoid_transform[3][3] = {{0.879685, 0.000540833, -0.0106054}, {0.000540833, 0.891086, -0.0130338}, {-0.0106054, -0.0130338, 0.997494}};

//"gyro x,y,z (current/average) = -40.00/-42.05  98.00/96.20  -18.00/-18.36"
#define GYRO_AVERAGE_OFFSET_X ((float) -35.15)
#define GYRO_AVERAGE_OFFSET_Y ((float) -8.54)
#define GYRO_AVERAGE_OFFSET_Z ((float) 10.32)



// DEBUG OPTIONS
/*****************************************************************/
// When set to true, gyro drift correction will not be applied
#define DEBUG__NO_DRIFT_CORRECTION false
// Print elapsed time after each I/O loop
#define DEBUG__PRINT_LOOP_TIME false


/*****************************************************************/
/****************** END OF USER SETUP AREA!  *********************/
/*****************************************************************/




// Check if hardware version code is defined
#ifndef HW__VERSION_CODE
  // Generate compile error
  #error YOU HAVE TO SELECT THE HARDWARE YOU ARE USING! See "HARDWARE OPTIONS" in "USER SETUP AREA" at top of Razor_AHRS.ino!
#endif

#include <Wire.h>

// Sensor calibration scale and offset values
#define ACCEL_X_OFFSET ((ACCEL_X_MIN + ACCEL_X_MAX) / 2.0f)
#define ACCEL_Y_OFFSET ((ACCEL_Y_MIN + ACCEL_Y_MAX) / 2.0f)
#define ACCEL_Z_OFFSET ((ACCEL_Z_MIN + ACCEL_Z_MAX) / 2.0f)
#define ACCEL_X_SCALE (GRAVITY / (ACCEL_X_MAX - ACCEL_X_OFFSET))
#define ACCEL_Y_SCALE (GRAVITY / (ACCEL_Y_MAX - ACCEL_Y_OFFSET))
#define ACCEL_Z_SCALE (GRAVITY / (ACCEL_Z_MAX - ACCEL_Z_OFFSET))

#define MAGN_X_OFFSET ((MAGN_X_MIN + MAGN_X_MAX) / 2.0f)
#define MAGN_Y_OFFSET ((MAGN_Y_MIN + MAGN_Y_MAX) / 2.0f)
#define MAGN_Z_OFFSET ((MAGN_Z_MIN + MAGN_Z_MAX) / 2.0f)
#define MAGN_X_SCALE (100.0f / (MAGN_X_MAX - MAGN_X_OFFSET))
#define MAGN_Y_SCALE (100.0f / (MAGN_Y_MAX - MAGN_Y_OFFSET))
#define MAGN_Z_SCALE (100.0f / (MAGN_Z_MAX - MAGN_Z_OFFSET))


// Gain for gyroscope (ITG-3200)
#define GYRO_GAIN 0.06957 // Same gain on all axes
#define GYRO_SCALED_RAD(x) (x * TO_RAD(GYRO_GAIN)) // Calculate the scaled gyro readings in radians per second

// DCM parameters
#define Kp_ROLLPITCH 0.02f
#define Ki_ROLLPITCH 0.00002f
#define Kp_YAW 1.2f
#define Ki_YAW 0.00002f

// Stuff
#define STATUS_LED_PIN 13  // Pin number of status LED
#define GRAVITY 256.0f // "1G reference" used for DCM filter and accelerometer calibration
#define TO_RAD(x) (x * 0.01745329252)  // *pi/180
#define TO_DEG(x) (x * 57.2957795131)  // *180/pi

// Sensor variables
float accel[3];  // Actually stores the NEGATED acceleration (equals gravity, if board not moving).
float accel_min[3];
float accel_max[3];

float magnetom[3];
float magnetom_min[3];
float magnetom_max[3];
float magnetom_tmp[3];

float gyro[3];
float gyro_average[3];
int gyro_num_samples = 0;

// DCM variables
float MAG_Heading;
float Accel_Vector[3]= {0, 0, 0}; // Store the acceleration in a vector
float Gyro_Vector[3]= {0, 0, 0}; // Store the gyros turn rate in a vector
float Omega_Vector[3]= {0, 0, 0}; // Corrected Gyro_Vector data
float Omega_P[3]= {0, 0, 0}; // Omega Proportional correction
float Omega_I[3]= {0, 0, 0}; // Omega Integrator
float Omega[3]= {0, 0, 0};
float errorRollPitch[3] = {0, 0, 0};
float errorYaw[3] = {0, 0, 0};
float DCM_Matrix[3][3] = {{1, 0, 0}, {0, 1, 0}, {0, 0, 1}};
float Update_Matrix[3][3] = {{0, 1, 2}, {3, 4, 5}, {6, 7, 8}};
float Temporary_Matrix[3][3] = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}};

// Euler angles
float yaw;
float pitch;
float roll;

// DCM timing in the main loop
unsigned long timestamp;
unsigned long timestamp_old;
float G_Dt; // Integration time for DCM algorithm

// More output-state variables
boolean output_stream_on;
boolean output_single_on;
int curr_calibration_sensor = 0;
boolean reset_calibration_session_flag = true;
int num_accel_errors = 0;
int num_magn_errors = 0;
int num_gyro_errors = 0;

void read_sensors() {
  Read_Gyro(); // Read gyroscope
  Read_Accel(); // Read accelerometer
  Read_Magn(); // Read magnetometer
}

// Read every sensor and record a time stamp
// Init DCM with unfiltered orientation
// TODO re-init global vars?
void reset_sensor_fusion() {
  float temp1[3];
  float temp2[3];
  float xAxis[] = {1.0f, 0.0f, 0.0f};

  read_sensors();
  timestamp = millis();
  
  // GET PITCH
  // Using y-z-plane-component/x-component of gravity vector
  pitch = -atan2(accel[0], sqrt(accel[1] * accel[1] + accel[2] * accel[2]));
  
  // GET ROLL
  // Compensate pitch of gravity vector 
  Vector_Cross_Product(temp1, accel, xAxis);
  Vector_Cross_Product(temp2, xAxis, temp1);
  // Normally using x-z-plane-component/y-component of compensated gravity vector
  // roll = atan2(temp2[1], sqrt(temp2[0] * temp2[0] + temp2[2] * temp2[2]));
  // Since we compensated for pitch, x-z-plane-component equals z-component:
  roll = atan2(temp2[1], temp2[2]);
  
  // GET YAW
  Compass_Heading();
  yaw = MAG_Heading;
  
  // Init rotation matrix
  init_rotation_matrix(DCM_Matrix, yaw, pitch, roll);
}

// Apply calibration to raw sensor readings
void compensate_sensor_errors() {
    // Compensate accelerometer error
    accel[0] = (accel[0] - ACCEL_X_OFFSET) * ACCEL_X_SCALE;
    accel[1] = (accel[1] - ACCEL_Y_OFFSET) * ACCEL_Y_SCALE;
    accel[2] = (accel[2] - ACCEL_Z_OFFSET) * ACCEL_Z_SCALE;

    // Compensate magnetometer error
#if CALIBRATION__MAGN_USE_EXTENDED == true
    for (int i = 0; i < 3; i++)
      magnetom_tmp[i] = magnetom[i] - magn_ellipsoid_center[i];
    Matrix_Vector_Multiply(magn_ellipsoid_transform, magnetom_tmp, magnetom);
#else
    magnetom[0] = (magnetom[0] - MAGN_X_OFFSET) * MAGN_X_SCALE;
    magnetom[1] = (magnetom[1] - MAGN_Y_OFFSET) * MAGN_Y_SCALE;
    magnetom[2] = (magnetom[2] - MAGN_Z_OFFSET) * MAGN_Z_SCALE;
#endif

    // Compensate gyroscope error
    gyro[0] -= GYRO_AVERAGE_OFFSET_X;
    gyro[1] -= GYRO_AVERAGE_OFFSET_Y;
    gyro[2] -= GYRO_AVERAGE_OFFSET_Z;
}

// Reset calibration session if reset_calibration_session_flag is set
void check_reset_calibration_session()
{
  // Raw sensor values have to be read already, but no error compensation applied

  // Reset this calibration session?
  if (!reset_calibration_session_flag) return;
  
  // Reset acc and mag calibration variables
  for (int i = 0; i < 3; i++) {
    accel_min[i] = accel_max[i] = accel[i];
    magnetom_min[i] = magnetom_max[i] = magnetom[i];
  }

  // Reset gyro calibration variables
  gyro_num_samples = 0;  // Reset gyro calibration averaging
  gyro_average[0] = gyro_average[1] = gyro_average[2] = 0.0f;
  
  reset_calibration_session_flag = false;
}

void turn_output_stream_on()
{
  output_stream_on = true;
  digitalWrite(STATUS_LED_PIN, HIGH);
}

void turn_output_stream_off()
{
  output_stream_on = false;
  digitalWrite(STATUS_LED_PIN, LOW);
}

// Blocks until another byte is available on serial port
char readChar()
{
  while (Serial.available() < 1) { } // Block
  return Serial.read();
}

// # START OF DAISY CHAIN CODE ###########################################################################################################
#include "Packet.h"
#include <TimerOne.h>
#define DT 1000  //interrupt period of timer1 in us, use multiples of hundred

uint8_t imu_data[IMU_DATA_LENGTH]={0};
int n_loadcell_arduinos = 0;

// Communication variables ///////////////////////////////////////////////////////////////////////////////////////////////////
int send_data_flag=0; //make sure always new data is sent; not used in the loadcell setup
uint8_t last_byte=0x00;
uint8_t frame_type=0x00;
uint8_t frame_data_length=0x00;
uint8_t frame_location_counter=0x00;
uint8_t arduino_ID=0x00;
uint8_t cc_byte=0x00;
uint8_t cc_byte_new=0x00;
uint8_t run_command=0x00;
uint8_t enable_reading=0;
uint32_t timestamp_frame=0;


void check_and_update_IMU(){
  
  read_sensors();
  compensate_sensor_errors(); //to use calibration
  memcpy(&imu_data[0],&accel,sizeof(accel));
  memcpy(&imu_data[12],&gyro,sizeof(gyro));
  }

// update the timer
void update_sensors_timers(void) {
  timestamp_frame++;
}

void det_num_loadcell_arduinos(uint8_t frame_data_length){
  uint8_t ard_data_length = frame_data_length - IMU_DATA_LENGTH;
  n_loadcell_arduinos = (ard_data_length / SENSOR_DATA_LENGTH);
}

// # END OF DAISY CHAIN CODE ##########################################################################################################


void setup()
{
  // Init serial output
  Serial.begin(OUTPUT__BAUD_RATE);
  delay(1000); 
  //added for daisychain
  Timer1.initialize(DT);         // initialize timer1
  Timer1.attachInterrupt(update_sensors_timers);
    
  // Init status LED
  pinMode (STATUS_LED_PIN, OUTPUT);
  digitalWrite(STATUS_LED_PIN, LOW);

  // Init sensors
  delay(50);  // Give sensors enough time to start
  I2C_Init();
  Accel_Init();
  Magn_Init();
  Gyro_Init();
  
  // Read sensors, init DCM algorithm
  delay(20);  // Give sensors enough time to collect data
  reset_sensor_fusion();

  //added for daisychain
  memcpy(&imu_data[0],&accel,sizeof(accel));
  memcpy(&imu_data[12],&gyro,sizeof(gyro));
  // OUTPUT ACCELEROMETER DATA FROM THE BEGINNING
  output_mode = OUTPUT__MODE_SENSORS_BOTH;
  output_format = OUTPUT__FORMAT_TEXT;

  // Init output
#if (OUTPUT__HAS_RN_BLUETOOTH == true) || (OUTPUT__STARTUP_STREAM_ON == false)
  turn_output_stream_off();
#else
  turn_output_stream_on();
#endif
}

int iLoop = 0;
int testMode = 0;
int sendThrough = 0;


// Main loop
void loop(){
//  Serial.println("Loop");
  uint8_t inByte, outByte;

// Copied from daisychain code ---------------------------------------------------

if(Serial.available())
  {

if(sendThrough){    
    //Serial.println("Arbiter V1.1");
    inByte = Serial.read();
    outByte=inByte; //if nothing is happening send back what is received
    Serial.write(outByte);
    last_byte=inByte;
}
else{
    inByte = Serial.read();
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

      if(testMode) outByte=1;
    }
    
    if((inByte == FRAME_SYNC_1) && (last_byte == FRAME_SYNC_0))
    {
      frame_location_counter=2;
      if(testMode)outByte= 2;
    } 

    // POSITIONAL COUNTER
    else if(frame_location_counter==2)
    {
      frame_location_counter++;
      outByte=inByte+1;
      arduino_ID=outByte;
      if(testMode) outByte= 3;
    }

    // FRAME TYPE
    else if(frame_location_counter==3)
    {
      frame_location_counter++;
      frame_type=inByte;
      if(testMode) outByte= 4;
    }

    // FRAME DATA LENGTH
    else if(frame_location_counter==4)
    {
      frame_location_counter++;
      frame_data_length=inByte;
      det_num_loadcell_arduinos(frame_data_length);    
    }

    // FRAME DATA
    else if(frame_location_counter > 4 && frame_location_counter <= (4+frame_data_length))
    {
      cc_byte+=inByte;

      // INSERT READINGS FROM IMU SENSOR only if FRAME_TYPE_SENSOR_DATA or FRAME_TYPE_IMU_RECALIB
      if ((frame_type==FRAME_TYPE_SENSOR_DATA) || (frame_type==FRAME_TYPE_IMU_RECALIB))
      {

        uint8_t place_holder_arduino_no = 1 + (uint8_t) (frame_location_counter - 5) / SENSOR_DATA_LENGTH;
        uint8_t byte_no= frame_location_counter - n_loadcell_arduinos * SENSOR_DATA_LENGTH - 5;
        
        // If place_holder_arduino_no > loadcell arduinos, then it must be the IMU
        if (place_holder_arduino_no > n_loadcell_arduinos)
        {
          if (byte_no==(IMU_DATA_LENGTH-1))
            {
              imu_data[byte_no]=timestamp_frame;
              //send_data_flag = 0;
            }
            outByte = imu_data[byte_no];
        }
        //else  If place_holder_arduino_no <= loadcell arduinos, then it is not the IMU and do nothing.       
      }
      
      cc_byte_new+=outByte;
      frame_location_counter++;

      
    }

    // CHECKSUM
    else if (frame_location_counter==(5+frame_data_length))
    {
      // What does this statement accomplish?
      // It basically takes the checksum in the previous frame and the calculation of the checksum based on the data of the previous frame
      // and then it compares the two.
      if (inByte!=cc_byte){
        outByte=~cc_byte_new;
        run_command=0;
        //outByte=0x04;
      }
      else
      {
        
        outByte=cc_byte_new;
        //outByte=0x05;

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

    Serial.write(outByte);
    last_byte=inByte;

    if (enable_reading==1)
    {
      check_and_update_IMU();
    }
    
    }
  }
  
}
