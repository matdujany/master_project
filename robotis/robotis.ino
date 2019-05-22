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

  // Setup:  Serial2: load cells and IMU; Serial3: Bluetooth or Matlab
  // Pins:   Serial2 => 4 (tx), 5 (rx); Serial3 => 24 (tx), 25 (rx)
  Serial2.begin(BAUD_RATE);

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
  duration_daisychain=6;
  
  //just to be sure that all motors have their default parameters;
  restaure_default_parameters_all_motors_syncWrite();
  //pose_stance();
  delay(1000);

  //initialize_hardcoded_limbs();
  //updating IMU offsets (recalibration)
  //update_IMU_offsets();


  //twitch_record_wrapper();

  //record_harcoded_tegotae(30);
  //record_harcoded_tegotae_change_phi_init();

  hardcoded_tegotae_bluetooth();
  //test_dc();
  //setup_serial_bluetooth();
}


/* -------------------------------------------------------------------------------------------------------------------------------------- */
void loop() {
  //serial_read_bluetooth_main();

  //pose_stance();
  //update_load_pos_values();
  //SerialUSB.print("Motor positions, ");
  //print_motor_positions();
  //show_value_DC(20);
  //serial_read_neutral_pos();
  
  //serial_read_test_twitch();
  //serial_read_bluetooth_main();

}

void test_dc(){
  while (true){
    unsigned long t_start_update_loop = millis();
    send_frame_and_update_sensors(1,1);
    while(millis()-t_start_update_loop<DELAY_UPDATE_TEGOTAE);
  }
}