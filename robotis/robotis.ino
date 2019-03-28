/* ===================================================================================================================================== */
//
///////////////////////////////////////////////////////////////////////////
// LEARNING TO WALK: CONTROL OF ARBITRARY STRUCTURES IN MODULAR ROBOTICS //
///////////////////////////////////////////////////////////////////////////
// 
// The code consist of mainly 3 parts:
// 1. INITIALISATION  : initialise the system
// 2. LEARNING PART   : Construct weight matrix and create mapping from load cells to servo's (/ legs)
// 3. MOVING PART     : Move the structure using Tegotae for interlimb coordination
// 
/* ------------------------------------------------------------------------------------------------------------------------------------- */

// Include libraries
#include "string.h"
#include "stdlib.h"
#include "stdint.h"
#include "stdio.h"

#include "globals.h"


/* ------------------------------------------------------------------------------------------------------------------------------------- */
void setup() {  
  
  // 1. INITIALISATION __________________________________________________________________________________//
  
  /////////////////////////////////
  // DYNAMIXEL                   //
  /////////////////////////////////
  while(!SerialUSB);
  init_dynamixel();
  
  /////////////////////////////////
  // LOADCELLS + BLUETOOTH       //
  /////////////////////////////////

  // Setup:  Serial2: load cells and IMU; Serial3: Bluetooth
  // Pins:   Serial2 => 4 (tx), 5 (rx); Serial3 => 24 (tx), 25 (rx)
  Serial2.begin(BAUD_RATE);       // Tested up to 57600
  //Serial3.begin(BAUD_RATE_BLUE);  // 9600 default for the HC-06
  Serial3.begin(2000000);   //for fast Matlab writing 

  // Flush the pipes
  Serial2.flush();
  Serial3.flush();
  //empyting the the usb console from a message that VScode writes
  while (SerialUSB.available()){
    SerialUSB.read();
  }

  // Delay to have everyone ready for serial com
  delay(5000);

  // Initialize ring buffer and circular frame array
  init_ring_buffer();

  // Construct initial data frame and command frame
  construct_initial_frame();
  construct_initial_frame_blue(0xFF);
  init_circular_frame_array();

  // Determine the number of Arduino's using the full frame
  count_arduinos_wrapper(flagVerbose);

  // Adjust settings to match frame size to the number of load cell Arduino's
  reset_circular_frame_array();

  //timing duration of daisychain;
  //compute_duration_daisychain_ms();
  duration_daisychain=5;
  
  //just to be sure that all motors have their default parameters;
  restaure_default_parameters_all_motors_syncWrite();
  pose_stance();

  //debugging_send_frame_byte();

  twitch_record_wrapper();
}



/* ------------------------------------------------------------------------------------------------------------------------------------- */
void loop() { 
  //time_daisychain_run_init();
  //show_value_LC(0);
  //SerialUSB.print("Nb end bytes sent: ");SerialUSB.println(nb_end_bytes_sent);
  //SerialUSB.print("Nb frames found: ");SerialUSB.println(nb_frames_found);
  //show_value_LC(5000);
  /*
  SerialUSB.println("servos set to stiff");
  make_all_servos_stiff_syncWrite();
  pose_stance();
  delay(10000);
  SerialUSB.println("servos set to compliant");
  make_all_servos_compliant_syncWrite();
  delay(10000);
  */

}
