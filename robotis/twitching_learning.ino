/* ===================================================================================================================================== */

/////////////////////////////////
// 6. TWITCHING AND LEARNING   //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

void twitch_record_wrapper(){
  SerialUSB.print("Step Amplitude : "); SerialUSB.println(STEP_AMPL);
  SerialUSB.print("Learning rate : "); SerialUSB.println(LEARNING_RATE);
  SerialUSB.print("Duration part 0 : "); SerialUSB.println(DURATION_PART0);
  SerialUSB.print("Duration part 1 : "); SerialUSB.println(DURATION_PART1);
  SerialUSB.print("Duration part 2 : "); SerialUSB.println(DURATION_PART2);
  SerialUSB.print("Compliant Mode : "); SerialUSB.println(COMPLIANT_MODE);
  SerialUSB.print("Recentering : "); SerialUSB.println(RECENTERING_TWITCH);

  SerialUSB.println();
  
  // Execute twitching procedure n_twitch times.
  for(int i_twitch = 0; i_twitch < N_TWITCHES; i_twitch++){

    // Preparations for the twitching process.
    restaure_default_parameters_all_motors_syncWrite();
    pose_stance();               // Set servo positions to stance pose
    sleep_while_moving();        // Sleep until the servo's reached their imposed positions
    //reset_servo_offset();        // Reset offset of servo's
    delay(3000);
    
    // EXECUTE TWITCHING PROCESS
    twitch_main();

    // Print weight matrix and sdot
    //print_sdot_oja();
    print_weights();
    print_weights_pos();
    SerialUSB.print("Max computation time p1 (in ms) : ");
    SerialUSB.println(max_time_computation_p1);SerialUSB.println();
    SerialUSB.print("Checksum mismatch counter value : ");SerialUSB.println(count_checksum_mismatches);SerialUSB.println();
  }
  

  
  Serial3.println(1500);
  SerialUSB.print("Total number of frames found : ");
  SerialUSB.println(all_frames_found);
    
  restaure_default_parameters_all_motors_syncWrite();
  pose_stance();
}

void twitch_main()
{

  ///////////////////////////////////////////////////////////////////////////
  /// Initialisation of variables and settings
  ///////////////////////////////////////////////////////////////////////////

  // Size of the step of the step function
  uint16_t ampl_step_pos = STEP_AMPL * 3.413;

  // Initialisation of variables:
  uint16_t pos_command;
  int n_frames_tmp = 0;
  int interv_arr[] = {DURATION_PART0, DURATION_PART1, DURATION_PART2};
  int n_frames_part[3];
  for (int i=0; i<3;i++)
    n_frames_part[i]=int(interv_arr[i]/TIME_INTERVAL_TWITCH);

  int dir_sign[] = {-1, 1};
  int i_action = 0;

  ///////////////////////////////////////////////////////////////////////////
  /// Learning Loop
  ///////////////////////////////////////////////////////////////////////////
  if (COMPLIANT_MODE==1){
    make_all_servos_compliant_syncWrite();
    //make_all_servos_compliant();
  }
  if (COMPLIANT_MODE==2){
    make_all_servos_stiff_syncWrite();   
    //make_all_servos_stiff(); 
  }

  for (uint8_t i_servo = 0; i_servo < n_servos; i_servo++)
  {
    if (COMPLIANT_MODE==1){
      make_servo_stiff(id[i_servo]);
    }

    // Loop over directions
    for (uint8_t i_dir = 0; i_dir < 2; i_dir++)
    {

      // Reset variables for learning
      reset_twitch_variables();

      // Loop over parts of actual twitching process:  - part 0:  servo waits in initial position
      //                                               - part 1:  servo goes to step position.
      //                                               - part 2:  servo goes from step position to initial position
      for (uint8_t i_part = 0; i_part < 3; i_part++)
      {

        // Select interval duration
        int interv_dur = interv_arr[i_part];

        // Perform part specific actions before recording (sending servo commands)
        twitch_pre_action(i_part, i_servo, dir_sign[i_dir], ampl_step_pos);

        // Keep looping until required number of frames is reached
        while (n_frames_tmp < n_frames_part[i_part])
        {

          // If it is the start of a new frame, initialize timestamp.
          if (i_loop_frame == i_loop - 1)
          {
            timestamp = millis();
          }

          // Calculate if time taken to send the current frame
          // and if this difference is smaller (or not) than the frame sample frequency
          time_diff = millis() - timestamp;
          bool_interval = time_diff <= TIME_INTERVAL_TWITCH;

          // Update the value of the boolean 'bool_send_byte'
          update_bool_send_byte();

          // Send one byte if time is right (meaning if bool_send_byte == true)
          if (bool_send_byte)
          {
            send_frame_byte(1, 0);
          }


          if (Serial2.available())
          {
            // Reads one byte from the rx port of Serial2 (load cells and IMU)
            get_loadcell_byte(0);

            // Boolean to check if frame has been found
            frame_found = check_frame(flagVerbose);
          }

          if (frame_found)
          {
            unsigned long start_time;
            if (i_part == 1)
              start_time = millis();

            // Increase number of collected frames
            n_frames_tmp++;

            if (i_part == 1)
              twitch_part1_moving(i_servo, dir_sign[i_dir], ampl_step_pos, n_frames_tmp, n_frames_part[i_part]);

            // Parse data
            wrapper_parser(flagVerbose);

            // Start of HEX to DEC conversion
            // First argument: flagVerbose, second argument: conversion mode
            // Mode 1: loadcell mode, Mode 2: IMU mode
            hex_to_float(flagVerbose, 1);
            hex_to_float(flagVerbose, 2);

            twitch_calculate_s_dot();

            // Learning during part 1
            if (i_part == 1)
              twitch_part1_learning(n_frames_tmp, i_servo, i_action, dir_sign[i_dir]);
            else
            {
              update_load_pos_values();
            }
            
            //Printing results Matlab
            printing_serial3_lpdata(i_part);

            // Reset frame_found boolean
            frame_found = false;

            if (i_part == 1){
              int time_computation = millis()-start_time;
              max_time_computation_p1 = std::max(max_time_computation_p1,time_computation);
            }
          }
          i_loop++;
        }
        n_frames_tmp = 0;
      }

      // Counting number of actions (total = number of servo's * 2 directions)
      i_action++;
    }
    
    if (COMPLIANT_MODE==1){
      if (RECENTERING_TWITCH==1){
        make_all_servos_stiff_syncWrite();
        //make_all_servos_stiff();
        pose_stance();
        delay(RECENTERING_DELAY);
        make_all_servos_compliant_syncWrite();
        //make_all_servos_compliant();
       
      }
      make_servo_compliant(id[i_servo]);
    }

  }
}

//for Matlab recordings
void printing_serial3_lpdata(uint8_t i_part){
  for (int i = 0; i < n_servos; i++)
  {
    Serial3.println(last_motor_pos[i]);
    Serial3.println(last_motor_load[i]);
    Serial3.println(last_motor_timestamp[i]);
  }
  Serial3.println(i_part);  
}

void twitch_part1_moving(uint8_t i_servo, int dir_sign, uint16_t ampl_step_pos, int n_frames_tmp, int n_frames_tot)
{
    uint16_t command_pos = 512 + dir_sign * ampl_step_pos * double(n_frames_tmp) / double(n_frames_tot);
    set_goal_position(id[i_servo], command_pos);
}

void twitch_part1_learning(int n_frames, int i_servo, int i_action, int dir_sign)
{
  uint16_t new_motor_pos;
  int16_t new_motor_load;
  unsigned long new_motor_timestamp;
  for (int i = 0; i < n_servos; i++)
  {
      new_motor_pos = read_present_position(id[i]);
      new_motor_load = read_present_load(id[i]);
      new_motor_timestamp = millis();
      m_dot_pos[i] = float(new_motor_pos - last_motor_pos[i]) / float(new_motor_timestamp - last_motor_timestamp[i]);
      last_motor_pos[i] = new_motor_pos;
      last_motor_load[i] = new_motor_load; 
      last_motor_timestamp[i] = new_motor_timestamp;
  }

  float m_learning = dir_sign*m_dot_pos[i_servo];
  twitch_learning_prog(i_action, m_learning);

}

void update_load_pos_values(){
  for (int i = 0; i < n_servos; i++)
  {
    last_motor_pos[i] = read_present_position(id[i]);
    last_motor_load[i] = read_present_load(id[i]);
    last_motor_timestamp[i] = millis();
  }
}

void twitch_learning_prog(int i_action, float m_learning)
{

  // Initialisation of local variables
  float alpha = LEARNING_RATE; // Learning rate is set by constant LEARNING_RATE
  float weight_delta;
  float s_dot_select;
  float weight;
  int i_dir;

  // Samples used for learning are subjected to conditions as defined by check_learning_conditions()
  for (int j_sensor = 0; j_sensor < n_ard * 3 + IMU_USEFUL_CHANNELS; j_sensor++)
  {

    // Select data from array
    s_dot_select = s_dot_last[j_sensor];

    // Select weight from array
    weight = learning.weights[j_sensor][i_action];

    // Apply Oja's differential learning rule
    weight_delta = oja_diff_learning_rule(m_learning, s_dot_select, weight);

    // Print information at will
    if (j_sensor == 1 && 0)
    {
      SerialUSB.print(s_dot_select);
      SerialUSB.print("\t");
      SerialUSB.print(weight);
      SerialUSB.print("\t");
      SerialUSB.println(weight_delta);
    }

    // Apply weight update rule
    learning.weights[j_sensor][i_action] = weight + alpha * weight_delta;
  }

  for (int j_motor_sensor = 0; j_motor_sensor < n_servos; j_motor_sensor++){
    s_dot_select = m_dot_pos[j_motor_sensor];
    weight = learning.weights_pos[j_motor_sensor][i_action];
    weight_delta = oja_diff_learning_rule(m_learning, s_dot_select, weight);
    learning.weights_pos[j_motor_sensor][i_action] = weight + alpha * weight_delta;

  }


}

void reset_twitch_variables()
{
  // Reset variables used in the twitching process

  for (int j_tmp = 0; j_tmp < n_ard * 3 + IMU_USEFUL_CHANNELS; j_tmp++)
  {
    s_dot_last[j_tmp] = 0;
    /*
    s_dot_peak[j_tmp][0] = 0;
    s_dot_peak[j_tmp][1] = 0;
    s_dot_sq_err[j_tmp] = 0;
    s_dot_mean_pseudo[j_tmp] = 0;
    s_dot_mean[j_tmp] = 0;
    s_dot_std[j_tmp] = 0;
    learning.peak_sign[j_tmp] = 0;
    learning.ss_sign[j_tmp] = 0;


    if (j_tmp < n_ard * 3)
    {
      val_old[j_tmp] = 0;
      s_ss_part0[j_tmp] = 0;
      s_ss_part1[j_tmp] = 0;
    }
    */
  }
}


/* ------------------------------------------------------------------------------------------------------------------------------------- */
float oja_diff_learning_rule(float m, float s_dot, float weight)
{
  // Oja's differential learning rule
  return -1 * (m * s_dot + m * m * weight);
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
void twitch_pre_action(int i_part, int i_servo, int sign, uint16_t ampl_step_pos)
{
  if (i_part == 0)
  {
    set_goal_position(id[i_servo], 512);
  }
  else if (i_part == 2)
  {
    set_goal_position(id[i_servo], 512);
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */

void twitch_calculate_s_dot()
{

  // Initialization of local variables to compute derivatives of laodcell measurements
  float val_new;
  float timestamp_new;
  float t_delta;

  // Loop over all channels /////////////////////////////////////////////////
  for (int i_tmp = 0; i_tmp < n_ard * 3 + IMU_USEFUL_CHANNELS; i_tmp++)
  {

    // Loadcell channels /////////////////
    if (i_tmp < n_ard * 3)
    {

      // Get LC data
      val_new = ser_rx_buf.last_loadcell_data_float[i_tmp];

      // Define new timestamp
      timestamp_new = (int)ser_rx_buf.timestamp_loadcell[i_tmp / 3];

      // Convert ring buffer to continuous time line (i.e. value 256 will be 256 instead of 256 % 255 = 1)
      if (timestamp_new - timestamp_old[i_tmp] < 0)
      {
        t_delta = float((timestamp_new + 256) - timestamp_old[i_tmp]) / 1000;
      }
      else
      {
        t_delta = float(timestamp_new - timestamp_old[i_tmp]) / 1000;
      }

      // Calculate s_dot value
      s_dot_last[i_tmp] = (val_new - val_old_lc[i_tmp]) / t_delta;

      // Print information at will
      if (i_tmp == 1 && 0)
      {
        SerialUSB.print(t_delta, 5);
        SerialUSB.print(" \t");
        SerialUSB.print(int(timestamp_new));
        SerialUSB.print(" \t");
        SerialUSB.print(int(timestamp_old[1]));
        SerialUSB.print(" \n");
      }

      // Define old timestamp (should be after t_delta has been calculated for this step)
      timestamp_old[i_tmp] = timestamp_new;

      // Saving values for next iteration
      val_old_lc[i_tmp] = val_new;
    }

    // IMU channels /////////////////
    else
    {
      // IMU data : no differenciation needed.
      s_dot_last[i_tmp] = ser_rx_buf.last_IMU_data_float[i_tmp - n_ard * 3];
    }
  }
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
int get_sign(float val)
{
  return (val < 0) ? -1 : (val > 0) ? 1 : 0;
}
