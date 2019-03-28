/* ===================================================================================================================================== */
//
///////////////////////////////////////////////////////////////////////////
// LEARNING TO WALK: CONTROL OF ARBITRARY STRUCTURES IN MODULAR ROBOTICS //
///////////////////////////////////////////////////////////////////////////
// 
// This file contains the global variables. This file is subdivided in the following parts:
// 1. SETTINGS
// 2. RING BUFFERS & FRAME HANDLING
// 3. SENSORY
// 4. BLUETOOTH
// 5. DYNAMIXEL
// 6. LEARNING
// 
// 
// TO DO:
// - Check the use of amplitude, amplitude_arr and amplitude_deg. Inconsistently used now in the functions.
// 
// 
/* ------------------------------------------------------------------------------------------------------------------------------------- */

// Include header files
#include "constants.h"
#include <DynamixelSDK.h>


/* ===================================================================================================================================== */

/////////////////////////////////
// 1. SETTINGS                 //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

// General settings:
float pi               = float(3.1415926535);
int start_at_location  = 1;       // 1: start at given positions, 0: start at 0 angle
int flagVerbose        = 0;       // Default mode: print no information
boolean bool_walk      = false;   // Boolean to turn servo's on/off

// CPG/Tegotae related:
float frequency       = 0.5;
float amplitude_arr[] =  {15*pi/180, 30*pi/180};
float amplitude_deg   = 20;
float sigma_s         = 0;       // Sigma S; see Tegotae article
float sigma_p         = 0;       // Sigma P; see Tegotae article

/* ===================================================================================================================================== */

//////////////////////////////////////
// 2. RING BUFFERS & FRAME HANDLING //
//////////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

typedef struct rbuffer
// Contains load cell and IMU data and some related variables
{
  unsigned int head;                                                                      // 16 bit
  unsigned int tail;                                                                      // 16 bit
  uint8_t buffer[BUFFER_SIZE];                                                            // 8 bit unsigned
  
  uint8_t last_loadcell_data[MAX_NR_ARDUINO * (SENSOR_DATA_LENGTH - 1)];                  // contains the last loadcells measures each coded over 4 bytes without timestamps (hence the -1)
  float last_loadcell_data_float[ (MAX_NR_ARDUINO * (SENSOR_DATA_LENGTH - 1)) / 4];       // contains the last loadcells measures converted to float (no timestamps)
  char timestamp_loadcell[MAX_NR_ARDUINO]; //contains the timestamp from the last loadcells measures

  uint8_t last_IMU_data[IMU_DATA_LENGTH -1 ]; //contains the IMU data (6 channels) coded over 4 bytes without the timestamp (hence the -1)
  float last_IMU_data_float[(IMU_DATA_LENGTH-1)/4]; //contains the last IMU data converted to float (no timestamp)
  char timestamp_IMU; //contains the timestamp from the last loadcells measures
}
rbuffer;

typedef struct rbuffer_frame
// Contains ring buffer for sending out frame bytes
{
  uint16_t head;                                // 16 bit
  uint8_t buffer[MAX_FRAME_SIZE];              // 8 bit unsigned (like our )
  uint16_t frame_size;
}
rbuffer_frame;

rbuffer ser_rx_buf;                            // Ring buffer for receiving serial data
rbuffer_frame frame_buf;                       // Ring buffer for sending out frame bytes

uint8_t initial_frame[MAX_FRAME_SIZE];         // header plus max data, preallocation needed
bool arduinos_counted = false;                 // Boolean that states if the LC Arduino's are counted
bool bool_checksum;                            // Boolean that indicates whether checksum test passed or failed
unsigned long timestamp_startframe = 0;        // Timestamp at which the first byte of a frame has been sent
bool frame_found;                              // Boolean that indicates whether a full frame has been received
bool bool_end_byte_sent     = false;           // Boolean that indicates if the last byte of a frame has been sent
int  n_frames               = 0;               // Number of collected frames
int n_ard                   = MAX_NR_ARDUINO;  // Number of counted loadcell Arduino's; initial guess = maximum number of arduino's
float duration_daisychain   = 0;               // duration in ms between the moment the first byte is sent by openCM and the last one comes back to openCM


//debugging
unsigned long nb_end_bytes_sent = 0;
unsigned long nb_frames_found = 0;
unsigned long count_checksum_mismatches=0;

/* ===================================================================================================================================== */

/////////////////////////////////
// 3. BLUETOOTH                //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

int        head              = 0;
bool       blue_command_new  = false;
uint8_t    bluetooth_command[BLUE_FRAME_LENGTH];
uint8_t    initial_frame_blue[9];

/* ===================================================================================================================================== */

/////////////////////////////////
// 5. DYNAMIXEL                //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

dynamixel::PortHandler *portHandler;     //for communication with Dynamixels (SDK)
dynamixel::PacketHandler *packetHandler; //for communication with Dynamixels (SDK)

unsigned long t_offset       = 0;
unsigned long t_current      = 0;
unsigned long t_old          = 0;
int currentPosition          = 0;
int model                    = 0;

uint8_t n_servos                    = 0;
uint8_t id[MAX_NR_SERVOS];         // 
float phi[MAX_NR_SERVOS]           = {0};
float phi_dot[MAX_NR_SERVOS]       = {0};
uint16_t amplitude                 = uint16_t(amplitude_deg*3.413);
uint16_t pos[MAX_NR_SERVOS]        = {512};
float servo_offset[MAX_NR_SERVOS]  = {0};
float phase_shift[MAX_NR_SERVOS]   = {0};

/* ===================================================================================================================================== */

/////////////////////////////////
// 6. LEARNING                 //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

int n_samples_mov_average = 0;
//uint16_t last_motor_pos = 512 ;
//unsigned long last_motor_timestamp;

// Number of samples for different parts of the twitching process
const int n_samples_part0 = DURATION_PART0 / TIME_INTERVAL_TWITCH;
const int n_samples_part1 = DURATION_PART1 / TIME_INTERVAL_TWITCH;
const int n_samples_part2 = DURATION_PART2 / TIME_INTERVAL_TWITCH;

// s
float val_old_lc[MAX_NR_ARDUINO * 3];        // Old values of loadcell data, needed for calculating s_dot

// Time
int timestamp_old[MAX_NR_ARDUINO * 3] = {0};           // old values of timestamps, used to compute s_dots

// S_dot
float s_dot_last[MAX_NR_ARDUINO * 3 + IMU_USEFUL_CHANNELS];               // Most recent values of s_dot


uint16_t last_motor_pos[MAX_NR_SERVOS];  // Most recent values of motor positions
int16_t last_motor_load[MAX_NR_SERVOS];               // Most recent values of motor loads
unsigned long last_motor_timestamp[MAX_NR_SERVOS];
float m_dot_pos[MAX_NR_SERVOS];           // Most recent values of s_dot

// Learning struct
typedef struct learning_struct
{
  //double s_dot_oja[MAX_NR_ARDUINO * 3 + IMU_USEFUL_CHANNELS][MAX_NR_SERVOS * 2];     //last s_dot sent to Oja, useful for comparing with Matlab
  float weights[MAX_NR_ARDUINO * 3 + IMU_USEFUL_CHANNELS][MAX_NR_SERVOS * 2];       // Contains the most recent values of the weights. (All historic information is in these values)
  float weights_pos[MAX_NR_SERVOS][MAX_NR_SERVOS * 2]; 
  int peak_sign[MAX_NR_ARDUINO * 3 + IMU_USEFUL_CHANNELS];                           // Indicates the sign of the peak sample on which should be learned (+1 is positive, -1 is negative peak)
  int ss_sign[MAX_NR_ARDUINO * 3 + IMU_USEFUL_CHANNELS];                             // Indicates the sign of the steady state response (+1 is positive, -1 is negative peak)
}
learning_struct;

learning_struct learning;


//Timing :
int max_time_computation_p1=0; //in ms

