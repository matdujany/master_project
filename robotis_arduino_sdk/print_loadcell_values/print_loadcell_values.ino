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
  // Flush the pipes
  Serial2.flush();


  // Initialize ring buffer and circular frame array
  init_ring_buffer();

  // Construct initial data frame and command frame
  construct_initial_frame();
  init_circular_frame_array();

  // Determine the number of Arduino's using the full frame
  count_arduinos_wrapper(flagVerbose);

  // Adjust settings to match frame size to the number of load cell Arduino's
  reset_circular_frame_array();

  //just to be sure that all motors have their default parameters;
  restaure_default_parameters_all_motors();

  pose_stance();
  
}


/* ------------------------------------------------------------------------------------------------------------------------------------- */
void loop() { 
  capture_frame(2900);

}
