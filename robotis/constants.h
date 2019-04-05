/* ===================================================================================================================================== */
//
///////////////////////////////////////////////////////////////////////////
// LEARNING TO WALK: CONTROL OF ARBITRARY STRUCTURES IN MODULAR ROBOTICS //
///////////////////////////////////////////////////////////////////////////
// 
// This file contains the constants. This file is subdivided in the following parts:
// 1. SETTINGS
// 2. PARAMETERS
// 
// TO DO:
// - 
// 
/* ------------------------------------------------------------------------------------------------------------------------------------- */




/* ===================================================================================================================================== */

/////////////////////////////////
// 1. SETTINGS                 //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

// RING BUFFER
#define BUFFER_SIZE                 512    // Should use power of 2...

// SERVO'S
#define MAX_NR_SERVOS               12

// DAISYCHAIN
// Sampling Settings
// It will sample at the frequency given by 1000/TIME_INTERVAL_TWITCH

#define    MAX_NR_ARDUINO           6      // Maximum number of load cell arduino's in the daisychain
#define    BAUD_RATE                500000  // Baud rate for load cell daisychain
#define    BAUD_RATE_BLUE           9600   // Baud rate for bluetooth dongle

// LEARNING
#define STEP_AMPL                   20     // Amplitude of step function during twitching (in degrees)
#define LEARNING_RATE               10      // Learning rate for the update rule
#define DURATION_PART0              500    // Duration of part 0 in ms; part 0: begins at DURATION_PART0 ms before moving;                servo has initial position
#define DURATION_PART1              500    // Duration of part 1 in ms; part 1: begins at the action of moving;                           servo goes from initial position to step position
#define DURATION_PART2              500    // Duration of part 2 in ms; part 2: begins at the action of going back to initial position;   servo goes from step position to initial position
#define N_TWITCHES                  5

#define COMPLIANT_MODE              1   // (0) : all servos remain at default parameters 
                                        // (1) : the non moving servos are compliant, the moving one is stiff
                                        // (2) : all servos are stiff
#define RECENTERING_TWITCH          1   // (1) : servos are recentered at 512 after each twitching in the 2 directions.
#define RECENTERING_DELAY           1500 

#define TIME_INTERVAL_TWITCH        20     // Sampling time in ms (frequency = 1000 / TIME_INTERVAL_TWITCH). For the quadruped structure, this is the lowest sampling time for which there were (close to) zero errors.

//FILTERS
#define USE_FILTER                1
#define FILTER_ADD_SIZE           3  //number of additional values stored, used for filtering during the learning.

/* ===================================================================================================================================== */

/////////////////////////////////
// 2. PARAMETERS               //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */


///////////////////////////////
// DAISYCHAIN                //
///////////////////////////////

#define MAX_DELAY_FRAME         500     //for initializing the waiting time when the loadcell is discovered


// Frame properties
#define FRAME_SYNC_0             0xFF                                                           // Start frame byte 1
#define FRAME_SYNC_1             0xAA                                                           // Start frame byte 2
#define END_FRAME                0x55                                                           // End frame byte
#define FRAME_TYPE_SENSOR_DATA   0x01     //default frametype, using during during learning
#define FRAME_TYPE_IMU_RECALIB   0x02    //frametype where only the IMU writes data, to recalibrate it
#define SENSOR_DATA_ADC_LENGTH   4                                                              // Sensor Data Length: float, so 4 bytes
#define SENSOR_DATA_LENGTH       (3*SENSOR_DATA_ADC_LENGTH+1)                                   // 12 bytes: 3 loadcells floats + timestamp integer
#define MAX_FRAME_SIZE           (7 + (MAX_NR_ARDUINO*SENSOR_DATA_LENGTH) + IMU_DATA_LENGTH)    // Maximum frame size

// IMU properties
#define IMU_DATA_ADC_LENGTH          4                                                          // the IMU return a 4-byte float for each channel
#define IMU_DATA_LENGTH              (6*IMU_DATA_ADC_LENGTH+1)                                  // 25 bytes: [accelerometer (3 linear values) + gyroscope (3 rotational values)] * 4 bytes + 1 timestamp byte
#define IMU_USEFUL_CHANNELS          6                                                          // we use only the 3 acceleration values and the yaw (not pitch and roll).
#define IMU_YAW_CHANNEL             0 //TBC, the yaw could actually be channel 0,1 or 2 (my guess is 2)

// Ring Buffer
#define BUFFER_NEXT(A) ((A+1)&(BUFFER_SIZE -1))    // Bitwise and operator for example will return 0 instead of 16.
#define BUFFER_PREV(A) ((A-1)&(BUFFER_SIZE -1))


///////////////////////////////
// DYNAMIXEL                 //
///////////////////////////////

// Serial device defines for dxl bus
#define DEVICE_NAME                     "1"                 //DEVICENAME "1" -> Serial1(OpenCM9.04 DXL TTL Ports)
                                                            //DEVICENAME "2" -> Serial2
                                                            //DEVICENAME "3" -> Serial3(OpenCM 485 EXP)
#define BAUDRATE_DXL    1000000
#define PROTOCOL_VERSION 1.0                // AX supports only Protocol Version 1.0 --> syncWrite OK but no syncRead
                                                         
// Control table adresses
#define ADDR_GOAL_POSITION              30        
//#define ADDR_GOAL_SPEED                 32           
#define ADDR_PRESENT_POSITION           36    
#define ADDR_PRESENT_LOAD               40         
#define ADDR_IS_MOVING                  46               
#define ADDR_CW_COMPLIANCE_MARGIN       26
#define ADDR_CCW_COMPLIANCE_MARGIN      27
#define ADDR_CW_COMPLIANCE_SLOPE        28
#define ADDR_CCW_COMPLIANCE_SLOPE       29
#define ADDR_PUNCH                      48

#define CONTROL_PERIOD (2000)  // msec

#define SOFT_COMPLIANCE_MARGIN          50  //uint8_t value
#define SOFT_COMPLIANCE_SLOPE           1   //uint8_t value
#define SOFT_PUNCH                      1   //uint26_t value
#define STIFF_COMPLIANCE_MARGIN         0
#define STIFF_COMPLIANCE_SLOPE          32           
#define STIFF_PUNCH                     32

///////////////////////////////
// IMU                     //
///////////////////////////////
// source : https://github.com/Razor-AHRS/razor-9dof-ahrs/blob/master/Arduino/Razor_AHRS/Razor_AHRS.ino

// Gain for gyroscope (ITG-3200)
#define GYRO_GAIN 0.06957 // Same gain on all axes, should put the gyro readings in deg/seconds
#define GYRO_GAIN_TO_RAD 0.0012142 //GYRO_GAIN * pi/180 --> should put the gyro readings in rad/seconds

#define GRAVITY_IMU 256.0f // "1G reference" used for DCM filter and accelerometer calibration

#define DELAY_FRAMES_UPDATE_OFFSET      30   //should be more than 20 ms, because the DATA OUTPUTE RATE of the IMU is 20
#define NB_VALUES_MEAN_UPDATE_OFFSET    50 

///////////////////////////////
// BLUETOOTH                 //
///////////////////////////////

#define BLUE_FRAME_LENGTH  4   // 1 start byte, 1 command byte + 2 extra bytes as send by the Android app.
