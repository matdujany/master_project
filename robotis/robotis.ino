/* ===================================================================================================================================== */
//
///////////////////////////////////////////////////////////////////////////
// LEARNING TO WALK: CONTROL OF ARBITRARY STRUCTURES IN MODULAR ROBOTICS //
///////////////////////////////////////////////////////////////////////////
// 
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

  // Setup:  Serial2: load cells and IMU; Serial3: Bluetooth or Matlab
  // Pins:   Serial2 => 4 (tx), 5 (rx); Serial3 => 24 (tx), 25 (rx)
  Serial2.begin(BAUD_RATE);

  //empyting the the USB console from a message that VScode writes
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
  duration_daisychain=7;
  
  //just to be sure that all motors have their default parameters;
  restaure_default_parameters_all_motors_syncWrite();
  //pose_stance();
  delay(1000);

  //updating IMU offsets (recalibration)
  update_IMU_offsets();


  //twitch_record_wrapper();

  //record_tegotae_changes();

  //record_tegotae_custom_phi_init(120*1000);
  
  tegotae_bluetooth();
  
  //record_tegotae_leg_amputated_programmed();
}


/* -------------------------------------------------------------------------------------------------------------------------------------- */
void loop() {
  
  //update_load_pos_values();
  //SerialUSB.print("Motor positions, ");
  //print_motor_positions();
  //show_value_DC(20);
  //serial_read_neutral_pos();
  

  //serial_read_test_twitch();

}
