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
  unsigned int head;                           // 16 bit
  uint8_t buffer[MAX_FRAME_SIZE];              // 8 bit unsigned (like our )
}
rbuffer_frame;

rbuffer ser_rx_buf;                            // Ring buffer for receiving serial data
rbuffer_frame frame_buf;                       // Ring buffer for sending out frame bytes

uint8_t initial_frame[MAX_FRAME_SIZE];         // header plus max data, preallocation needed
int idx_skip = 0;                              // Number of indices that are skipped in frame_buf. Value is calculated after number of Arduino's is known
bool arduinos_counted = false;                 // Boolean that states if the LC Arduino's are counted
bool bool_checksum;                            // Boolean that indicates whether checksum test passed or failed
unsigned long time_diff;                       // Time difference between sending the first byte and now
unsigned long timestamp = 0;                   // Timestamp at which the first byte of a frame has been sent
bool frame_found;                              // Boolean that indicates whether a full frame has been received
bool bool_interval;                            // Boolean that indicates whether the interval condition has been met on sending frame bytes
bool bool_send_byte         = true;            // Boolean that defines if a frame byte has to be send
bool bool_end_byte_sent     = false;           // Boolean that indicates if the last byte of a frame has been sent
int  n_frames               = 0;               // Number of collected frames
int i_loop                  = 0;               // Count number of loops of loop() in the main file
int i_loop_frame            = -1;              // Keep track of the i_loop at which the first byte of a frame has been sent
int n_ard                   = MAX_NR_ARDUINO;  // Number of counted loadcell Arduino's; initial guess = maximum number of arduino's

unsigned long count_checksum_mismatches=0;
unsigned long all_frames_found=0;


/* ===================================================================================================================================== */

/////////////////////////////////
// 5. DYNAMIXEL                //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

dynamixel::PortHandler *portHandler;     //for communication with Dynamixels (SDK)
dynamixel::PacketHandler *packetHandler; //for communication with Dynamixels (SDK)


uint8_t n_servos                    = 0;
uint8_t id[MAX_NR_SERVOS];         // 
