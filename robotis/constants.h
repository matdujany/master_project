/* ===================================================================================================================================== */
//
///////////////////////////////////////////////////////////////////////////
// LEARNING TO WALK: CONTROL OF ARBITRARY STRUCTURES IN MODULAR ROBOTICS //
///////////////////////////////////////////////////////////////////////////
// 
/* ------------------------------------------------------------------------------------------------------------------------------------- */


/* ===================================================================================================================================== */

/////////////////////////////////
// 1. SETTINGS                 //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

// RING BUFFER
#define BUFFER_SIZE                 256

// SERVO'S
#define MAX_NR_SERVOS               16
#define MAX_N_LIMB                   8

// DAISYCHAIN
// Sampling Settings
// It will sample at the frequency given by 1000/TIME_INTERVAL_TWITCH

#define    MAX_NR_ARDUINO           8      // Maximum number of load cell arduino's in the daisychain
#define    BAUD_RATE                500000  // Baud rate for load cell daisychain
#define    BAUD_RATE_BLUE           9600   // Baud rate for bluetooth dongle

// LEARNING
//#define STEP_AMPL                   10     // Amplitude of step function during twitching (in degrees)
#define SLOPE_LEARNING              1.4f      //1.4f 
#define LEARNING_RATE               10.0     // Learning rate for the update rule
#define DURATION_PART0              500    // Duration of part 0 in ms; part 0: begins at DURATION_PART0 ms before moving;                servo has initial position
#define DURATION_PART1              500    // Duration of part 1 in ms; part 1: begins at the action of moving;                           servo goes from initial position to step position
#define DURATION_PART2              500    // Duration of part 2 in ms; part 2: begins at the action of going back to initial position;   servo goes from step position to initial position
#define N_TWITCHES                  5

#define COMPLIANT_MODE              1   // (0) : all servos remain at default parameters 
                                        // (1) : the non moving servos are compliant, the moving one is stiff
                                        // (2) : all servos are stiff
#define RECENTERING_BETWEEN_ACTION  1   // (1) : servos are recentered at 512 after each twitching in the 2 directions.
#define RECENTERING_DELAY           1500 


//these two times are the delay between updates on the daisychian
// 20 ms for 4 lcs, 21 ms for 6 lcs, 22 ms for 8 lcs : almost 0 erros
#define TIME_INTERVAL_TWITCH        21    // Sampling time in ms (frequency = 1000 / TIME_INTERVAL_TWITCH).
#define DELAY_UPDATE_DC_TEGOTAE     21     //


#define DURATION_MANUAL_RECENTERING         15     //in s, manual recentering between twitch cycles
#define TIME_INTERVAL_MANUAL_RECENTERING    200    //in ms, delay between frames during manual recentering (the frames are just sent to update the LC values to print on console)

#define LIMIT_VAL_LC_LEARNING           50 //if a LC reports a value > LIMIT_VAL_LC_LEARNING, it is discarded and the previous value is taken
//This is to make sure that the learning is not compromised by a communication error in the daisychain.
//the max value that the loadcells can handle is 50 N anyway.
#define LIMIT_VAL_ACC_LEARNING           26
//the accelerometer values are integrated, one huge value is enough to ruin the learning
//i have determined this value just by looking at the accelerometer signals.
//in the accelerometer scaling, 256 = 1g (9.81 m/s^2) so 26 = 1.0 m/(s^2).

//FILTERS
#define USE_FILTER_LEARNING              1 
#define FILTER_ADD_SIZE_LEARNING         4  //4 //number of additional values stored, used for filtering all sensor values during the learning.

#define USE_FILTER_TEGOTAE               0
#define FILTER_SIZE_TEGOTAE              3  //number of additional values stored, used for filtering only the GRF from LCs during the tegotae walking.

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
#define FRAME_SYNC_0                    0xFF                                                           // Start frame byte 1
#define FRAME_SYNC_1                    0xAA                                                           // Start frame byte 2
#define END_FRAME                       0x55                                                           // End frame byte
#define FRAME_TYPE_RECORDING            0x01    //default frametype, using during learning, Matlab will record these frames only
#define FRAME_TYPE_IMU_RECALIB          0x02    //frametype where only the IMU writes data, to recalibrate it
#define FRAME_TYPE_NORMAL               0x03    //frametype where IMU and LCs write data, but frames are not used for learning
#define FRAME_TYPE_IMU_UPDATE_OFF       0x04    //frametype where IMU stops to update its sensors and write its values, it is 'off' but still checks the bytes and can be turned on again to add values again.

#define SENSOR_DATA_ADC_LENGTH   4                                                              // Sensor Data Length: float, so 4 bytes
#define SENSOR_DATA_LENGTH       (3*SENSOR_DATA_ADC_LENGTH+1)                                   // 12 bytes: 3 loadcells floats + timestamp integer
#define MAX_FRAME_SIZE           (7 + (MAX_NR_ARDUINO*SENSOR_DATA_LENGTH) + IMU_DATA_LENGTH)    // Maximum frame size

// IMU properties
#define IMU_DATA_ADC_LENGTH         4                                                          // the IMU return a 4-byte float for each channel
#define IMU_DATA_LENGTH             (6*IMU_DATA_ADC_LENGTH+1)                                  // 25 bytes: [accelerometer (3 linear values) + gyroscope (3 rotational values)] * 4 bytes + 1 timestamp byte
#define IMU_USEFUL_CHANNELS         6                                                          // 3 accelerometer channel (X Y Z), 3 gyro channels (roll pitch yaw)

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
#define BAUDRATE_DXL        1000000
#define PROTOCOL_VERSION    1.0                // AX supports only Protocol Version 1.0 --> syncWrite OK but no syncRead


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

//#define CONTROL_PERIOD (2000)  // msec

//Motor parameters
//for compliance slope, the smaller the stiffer
#define SOFT_COMPLIANCE_MARGIN          50      //uint8_t value 
#define SOFT_COMPLIANCE_SLOPE           128     //uint8_t value
#define SOFT_PUNCH                      1       //uint16_t value
#define RECENTERING_COMPLIANCE_MARGIN         1
#define RECENTERING_COMPLIANCE_SLOPE          32           
#define RECENTERING_PUNCH                     30
#define STIFF_COMPLIANCE_MARGIN         1
#define STIFF_COMPLIANCE_SLOPE          16  //16           
#define STIFF_PUNCH                     100  //150
#define MOV_LEARNING_COMPLIANCE_MARGIN         1
#define MOV_LEARNING_COMPLIANCE_SLOPE          32  //16           
#define MOV_LEARNING_PUNCH                     50  //150

#define LEARN_IN_INT16_T        0   // 0 normal learning in float, 1 learning in in16_t

///////////////////////////////
// IMU                     //
///////////////////////////////
// source : https://github.com/Razor-AHRS/razor-9dof-ahrs/blob/master/Arduino/Razor_AHRS/Razor_AHRS.ino

// Gain for gyroscope (ITG-3200)
#define GYRO_GAIN 0.06957 // Same gain on all axes, should put the gyro readings in deg/seconds
#define GYRO_GAIN_TO_RAD 0.0012142 //GYRO_GAIN * pi/180 --> should put the gyro readings in rad/seconds

#define IMU_GAIN 0.0383f // 1g (9.81 m/s2) = 256 in IMU scaling --> IMU GAIN 9.81/256 

#define DELAY_FRAMES_UPDATE_OFFSET      30   //should be more than 20 ms, because the DATA OUTPUTE RATE of the IMU is 20
#define NB_VALUES_MEAN_UPDATE_OFFSET    50 

///////////////////////////////
// BLUETOOTH                 //
///////////////////////////////

#define BLUE_FRAME_LENGTH  4   // 1 start byte, 1 command byte + 2 extra bytes as send by the Android app.
