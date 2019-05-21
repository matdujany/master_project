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
#include "hardcoded_parameters.h"
#include <DynamixelSDK.h>

/* ===================================================================================================================================== */

/////////////////////////////////
// 1. SETTINGS                 //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

// General settings:
float pi               = float(3.1415926535);
int flagVerbose        = 0;       // Default mode: print no information


// CPG/Tegotae Locomotion related:
float frequency       = 0.5; //this is only for tegotae and not hardcoded trot
float amplitude_class1 = 20; //class 1 are motors producing the movement in the direction asked
float amplitude_class2 = 20; //class 2 are motors doing the loading/unloading (stance/swing) cycle
float alpha           = 0.2;  //reduction of amplitude during stance for class 2 motors
float sigma_s         = 0.11;       // Sigma S; see Fukuhara 2018 article

bool tegotae_advanced = true;
bool direction_X      = true;   //to go in X
bool direction_Y      = false;   //to go in Y 
bool direction_Yaw    = false;   //to go in Yaw
bool flagTurning      = false;   //to turn on spot instead of forward

//recordings
float frequency_recording[4] = {0.25, 0.5, 1, 1.5 };
float sigma_advanced_recording[4] = {0.10, 0.19, 0.38, 0.57};
float sigma_simple_recording[4] = {0.054,-0.11,-0.22, 0.32};

int n_changes_recording = 3;
int time_changes[4] = {60, 90, 120,150}; //the last value is the end of the recoding
bool changes_done [3] = {false,false,false};

float phi_init[8] = {6.03, 2.14, 3.68, 1.41, 4.72, 1.60, 3.18, 4.39} ;

//for limb oscillators
unsigned long t_last_phi_update      = 0;
unsigned long t_offset_oscillators   = 0;
float phi[MAX_N_LIMB]             = {0};
float phi_dot[MAX_N_LIMB]         = {0};
float N_s[MAX_NR_ARDUINO] = {0};
uint16_t goal_positions_tegotae[MAX_NR_SERVOS];
float offset_class1[MAX_N_LIMB] = {0};

//To be learned
int n_limb;
float sigma_advanced;
std::vector<std::vector<uint8_t>>  limbs;
std::vector<std::vector<bool>>  changeDirs; 
std::vector<std::vector<float>> inverse_map; 


//filtering
typedef struct buffer_Ns_filter
{
  uint8_t head;  //the head is the index of the oldest values in the filter
  float N_s[FILTER_SIZE_TEGOTAE][MAX_N_LIMB];        // Old values of loadcell data used for filtering
}
buffer_Ns_filter;
buffer_Ns_filter buffer_filter_tegotae;

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
  float last_IMU_acc_corrected[3]; //contains last acceleration corrected with the offset stored in offset_acc
  float last_IMU_gyro_corrected[3]; //contains last gyro corrected with the offset stored in offset_gyro
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
float duration_daisychain   = MAX_DELAY_FRAME;  // duration in ms between the moment the first byte is sent by openCM and the last one comes back to openCM


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


uint8_t n_servos  = 0;
uint8_t id[MAX_NR_SERVOS];         // 

uint16_t neutral_pos[MAX_NR_SERVOS]; 

/* ===================================================================================================================================== */

/////////////////////////////////
// 6. LEARNING                 //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

// s
float val_old_lc[MAX_NR_ARDUINO * 3];          // old values of loadcell data, needed for calculating s_dot
int timestamp_lc_old[MAX_NR_ARDUINO] = {0};    // old values of timestamps, used to compute s_dots

// S_dot
float s_dot_last[MAX_NR_ARDUINO * 3 + IMU_USEFUL_CHANNELS];   // Most recent values of s_dot

float val_old_IMU_acc_corrected[3];
float val_old_IMU_gyro_corrected[3];

//motor
uint16_t last_motor_pos[MAX_NR_SERVOS];  // Most recent values of motor positions
int16_t last_motor_load[MAX_NR_SERVOS];  // Most recent values of motor loads
unsigned long last_motor_timestamp[MAX_NR_SERVOS];

uint16_t old_motor_pos[MAX_NR_SERVOS];    //older values of motor positions
unsigned long old_motor_timestamp[MAX_NR_SERVOS]; //older values of motor timestamps, needed for derivations

//motor dot
float m_dot_pos[MAX_NR_SERVOS];           // Most recent values of m_dot


//filtering
typedef struct buffer_filter
{
  uint8_t head;  //the head is the index of the oldest values in the filter
  float val_lc[FILTER_ADD_SIZE_LEARNING][MAX_NR_ARDUINO * 3];        // Old values of loadcell data used for filtering
  float val_IMU[FILTER_ADD_SIZE_LEARNING][IMU_USEFUL_CHANNELS];        // Old values of loadcell data used for filtering
  uint16_t motor_pos[FILTER_ADD_SIZE_LEARNING][MAX_NR_SERVOS];        // Old values of loadcell data used for filtering
}
buffer_filter;
buffer_filter buf_filter;

// Learning struct
typedef struct learning_struct
{
  //double s_dot_oja[MAX_NR_ARDUINO * 3 + IMU_USEFUL_CHANNELS][MAX_NR_SERVOS * 2];     //last s_dot sent to Oja, useful for comparing with Matlab
  //loat weights[MAX_NR_ARDUINO * 3 + IMU_USEFUL_CHANNELS][MAX_NR_SERVOS * 2];       // Contains the most recent values of the weights. (All historic information is in these values)
  float weights[MAX_NR_ARDUINO * 3 + IMU_USEFUL_CHANNELS][MAX_NR_SERVOS * 2];       // Contains the most recent values of the weights. (All historic information is in these values)

  //int weights_pos[MAX_NR_SERVOS][MAX_NR_SERVOS * 2];
}
learning_struct;

learning_struct learning;


//Timing :
int max_time_computation_p1=0; //in ms
float mean_time_computation_part=0; //in ms

/////////////////////////////////
// 7. IMU                      //
/////////////////////////////////

float offset_acc[3] = {0.0};
float offset_gyro[3] = {0.0};
bool slow_dc_mode = false; // to put a time delay when sending bytes in the daisychain during IMU calibration.
int count_sent_byte = 0; //counter bytes sent for IMU delay
