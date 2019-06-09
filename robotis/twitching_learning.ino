

/* ===================================================================================================================================== */

/////////////////////////////////
// 6. TWITCHING AND LEARNING   //
/////////////////////////////////

/* ------------------------------------------------------------------------------------------------------------------------------------- */

void twitch_record_wrapper(){
  print_twitching_parameters();
  Serial3.begin(2000000);   //for fast writing to Matlab of load and pos data via Serial3
  init_weight_matrix();

  // Execute twitching procedure n_twitch times.
  for(int i_twitch = 0; i_twitch < N_TWITCHES; i_twitch++){

    // Preparations for the twitching process.
    restaure_default_parameters_all_motors_syncWrite();
    pose_stance();               // Set servo positions to stance pose
    sleep_while_moving();        // Sleep until the servo's reached their imposed positions
    //reset_servo_offset();        // Reset offset of servo's
    manual_recenter_robot_delay_twitch();
    update_IMU_offsets();
    init_buf_filter();

    // EXECUTE TWITCHING PROCESS
    twitch_main();

    // Print weight matrix and sdot
    //print_sdot_oja();
    print_weights();
    print_weights_pos();
    SerialUSB.print("Max computation time p1 (in ms) : ");SerialUSB.println(max_time_computation_p1);SerialUSB.println();
    SerialUSB.print("Checksum mismatch counter value : ");SerialUSB.println(count_checksum_mismatches);SerialUSB.println();
    SerialUSB.print("Nb end bytes sent: ");SerialUSB.println(nb_end_bytes_sent);
    SerialUSB.print("Nb frames found: ");SerialUSB.println(nb_frames_found);
  }
  
  Serial3.println(1500);
  SerialUSB.println("Twitching and learning completed !");
    
  restaure_default_parameters_all_motors_syncWrite();
  pose_stance();
}

void twitch_main()
{

  ///////////////////////////////////////////////////////////////////////////
  /// Initialisation of variables and settings
  ///////////////////////////////////////////////////////////////////////////

  // Size of the step of the step function

  // Initialisation of variables:
  uint16_t pos_command;
  int n_frames_tmp = 0;
  int interv_arr[] = {DURATION_PART0, DURATION_PART1, DURATION_PART2};
  int n_frames_part[3];
  for (int i=0; i<3;i++)
    n_frames_part[i]=int(interv_arr[i]/TIME_INTERVAL_TWITCH);

  int dir_sign[] = {-1, 1};
  int i_action = 0;
  int count_missed_frames_row = 0; //counter of the number of missed frames in a row.
  //if this counter gets too high, a long delay is added and the daisychain is reinitialized
  float limit_duration = 1.5 * duration_daisychain;


  ///////////////////////////////////////////////////////////////////////////
  /// Learning Loop
  ///////////////////////////////////////////////////////////////////////////

  for (uint8_t i_servo = 0; i_servo < n_servos; i_servo++)
  {
    // Loop over directions
    for (uint8_t i_dir = 0; i_dir < 2; i_dir++)
    {

      // Reset variables for learning
      reset_s_dot_last();
      reset_integrated_speed();

      for (uint8_t i_part = 0; i_part < 3; i_part++)
      {
        mean_time_computation_part = 0;
        // Select interval duration
        int interv_dur = interv_arr[i_part];

        // Changing  servo parameters before learning part
        if (i_part == 1){
          if (COMPLIANT_MODE==1){
            make_all_servos_compliant_syncWrite();
          }
          if (COMPLIANT_MODE==2){
            make_all_servos_stiff_syncWrite();
          }
          change_motor_parameters_movement_learning(id[i_servo]);
        }

        // Keep looping until required number of frames is reached
        while (n_frames_tmp < n_frames_part[i_part])
        {
          timestamp_startframe = millis();
          reinitalize_dc_state();
          while(!bool_end_byte_sent){
            send_and_get_wrapper();
          }
          while( (!frame_found) & (millis()-timestamp_startframe<limit_duration) ){
            if (Serial2.available())
              get_dc_byte_wrapper();
          }

          //if a frame is found, we process it and wait to send the next one
          if (frame_found)
          {
            count_missed_frames_row = 0;
            // Increase number of collected frames
            n_frames_tmp++;
            //SerialUSB.print("frame found in "); SerialUSB.print(millis()-timestamp_startframe);SerialUSB.println("ms");
            
            //processing
            twitch_processing_frame_found(i_part, i_servo, dir_sign[i_dir], i_action, n_frames_tmp, n_frames_part[i_part]);

            //SerialUSB.print("Frame captured and processing done in ");SerialUSB.print(millis()-timestamp_startframe);
            //SerialUSB.println(" ms, waiting until TIME_INTERVAL_TWITCH to send an other one");
           
            //waiting to send the next one
            while( millis()-timestamp_startframe<TIME_INTERVAL_TWITCH);
          }
          //else it means that something got wrong in the daisychain
          //we print info and we try again
          else {
            SerialUSB.print("No complete frame received within ");
            SerialUSB.print(limit_duration);
            SerialUSB.print(" ms, trying again (trying to collect frame ");SerialUSB.print(n_frames_tmp+1);
            SerialUSB.print("), servo ");SerialUSB.print(i_servo);
            SerialUSB.print(", direction ");SerialUSB.print(2*i_dir-1);
            SerialUSB.print(", part ");SerialUSB.println(i_part);
            delay(15);
            count_missed_frames_row ++;
            if (count_missed_frames_row>=10){
              delay(1000);
              Serial2.flush();
              reinitalize_dc_state();
              while(Serial2.available()){
                Serial2.read();
              }
            }
          }
        }

        n_frames_tmp = 0;

        //SerialUSB.print("Mean computation time servo ");SerialUSB.print(i_servo);
        //SerialUSB.print(" part ");SerialUSB.print(i_part);
        //SerialUSB.print(" (in ms) : ");
        //SerialUSB.println(mean_time_computation_part);

      }

      if (RECENTERING_BETWEEN_ACTION==1){
        recentering_between_action();
      }


      // Counting number of actions (total = number of servo's * 2 directions)
      i_action++;
    }

  }
}

void recentering_between_action(){
  //restaure_default_parameters_all_motors_syncWrite();
  change_parameters_all_motors_recentering_syncWrite();
  pose_stance();
  unsigned long time_start = millis();
  switch_frame_normal_mode(); // just so that the frames to come are discarded by Matlab
  /*
  while (millis()-time_start < RECENTERING_DELAY/2){
    show_value_DC(TIME_INTERVAL_MANUAL_RECENTERING);
  }
  update_load_pos_values();
  int pos_gap = 0;
  for (int i = 0; i < n_servos; i++){
    pos_gap = last_motor_pos[i]-neutral_pos[i];
    if (abs(pos_gap)>1){
      set_goal_position(id[i],neutral_pos[i]-get_sign(pos_gap));
    }
  }
  */
  while (millis()-time_start < RECENTERING_DELAY){
    show_value_DC(TIME_INTERVAL_MANUAL_RECENTERING);
  }

  switch_frame_recording_mode();

  update_load_pos_values();
  SerialUSB.print("Recentering results, ");
  print_motor_positions();
  restaure_default_parameters_all_motors_syncWrite();
}

void compute_max_gap_stance(uint16_t &max_pos_gap, uint8_t &index_servo_max, uint16_t *pos_gaps, uint16_t *count_max_idx){
  update_load_pos_values();
  max_pos_gap = 0;
  index_servo_max = 1;
  for (int i = 0; i < n_servos; i++)
  {
    pos_gaps[i] = abs(last_motor_pos[i]-neutral_pos[i]);
    if (pos_gaps[i]>max_pos_gap){
      max_pos_gap=pos_gaps[i];
      index_servo_max = i;
    }
  }
  count_max_idx[index_servo_max]++;
}


void twitch_processing_frame_found(uint8_t i_part, uint8_t i_servo, int dir_sign, int i_action, int n_frames_tmp, int n_frames_this_part){
  unsigned long start_time_computation;
  start_time_computation = millis();

  //the filter is updated : the values (last_motor_pos and l)
  update_buf_filter();
  //print_buf_filter();

  update_load_pos_values();
  update_lc_IMU_values();

  //sending command to move
  if (i_part == 1){
    //twitch_part1_moving(i_servo, dir_sign, n_frames_tmp, n_frames_this_part);
    twitch_part1_moving_ramp(i_servo, dir_sign, n_frames_tmp);
  }

  if (i_part==2){
    //twitch_part2_moving(i_servo, n_frames_tmp, n_frames_this_part);
    twitch_part2_allrecentering(n_frames_tmp, n_frames_this_part);
  }

  if (USE_FILTER_LEARNING){
    calculate_m_dot_filtered();
    calculate_s_dot_filtered();
  }
  else{
    calculate_m_dot();
    calculate_s_dot();
  }


  // Learning during part 1
  if (i_part == 1){
    //float m_learning = dir_sign*m_dot_pos[i_servo]; // sign is flipped for M-
    float m_learning = m_dot_pos[i_servo]; // no sign flip
    twitch_learning_prog(i_action, m_learning);
  }

  //sending measures to Matlab
  printing_serial3_lpdata(i_part);
  
  int time_computation = millis()-start_time_computation;
  mean_time_computation_part += (time_computation)/(float)n_frames_this_part;
  if (i_part == 1){
    max_time_computation_p1 = std::max(max_time_computation_p1,time_computation);
  }
}

/*
void twitch_part1_moving(uint8_t i_servo, int dir_sign, int n_frames_tmp, int n_frames_tot)
{
  uint16_t ampl_step_pos = STEP_AMPL * 3.413;
  uint16_t command_pos = neutral_pos[i_servo] + dir_sign * ampl_step_pos * double(n_frames_tmp) / double(n_frames_tot);
  set_goal_position(id[i_servo], command_pos);
}
*/

void twitch_part1_moving_ramp(uint8_t i_servo, int dir_sign, int n_frames_tmp)
{
  uint16_t command_pos = neutral_pos[i_servo] + dir_sign * n_frames_tmp * SLOPE_LEARNING;
  set_goal_position(id[i_servo], command_pos);
}

void twitch_part2_recentering(uint8_t i_servo, int n_frames_tmp, int n_frames_tot)
{
  uint16_t command_pos = neutral_pos[i_servo] + (last_motor_pos[i_servo]-neutral_pos[i_servo]) * double(n_frames_tot-n_frames_tmp) / double(n_frames_tot);
  set_goal_position(id[i_servo], command_pos);
}

void twitch_part2_allrecentering(int n_frames_tmp, int n_frames_tot)
{
  uint16_t  goal_positions_stance[n_servos];
  for (int i_servo = 0; i_servo < n_servos; i_servo++){
    goal_positions_stance[i_servo] = neutral_pos[i_servo] + (last_motor_pos[i_servo]-neutral_pos[i_servo]) * double(n_frames_tot-n_frames_tmp) / double(n_frames_tot);
  }
  syncWrite_position_n_servos(n_servos, id, goal_positions_stance);
  
}


void update_lc_IMU_values(){
  //we store the old values before writing the new ones.
  for (int i=0; i<3 ; i++){
    val_old_IMU_acc_corrected[i] = ser_rx_buf.last_IMU_acc_corrected[i];
    val_old_IMU_gyro_corrected[i] = ser_rx_buf.last_IMU_gyro_corrected[i];
  }
  for (int i_tmp = 0; i_tmp < n_ard * 3; i_tmp++) {
    val_old_lc[i_tmp] = ser_rx_buf.last_loadcell_data_float[i_tmp];
  }
  for (int i_ard= 0; i_ard < n_ard; i_ard++) {
    timestamp_lc_old[i_ard] = (int)ser_rx_buf.timestamp_loadcell[i_ard];
  }

  // Parse data
  wrapper_parser(flagVerbose);
  // Start of HEX to DEC conversion
  // First argument: flagVerbose, second argument: conversion mode
  // Mode 1: loadcell mode, Mode 2: IMU mode
  hex_to_float(flagVerbose, 1);
  saturation_lc_values_learning();
  hex_to_float(flagVerbose, 2);
  correct_IMU_data();
  saturation_acc_values_learning();
}

//takes takes 0.25 ms per read per motor, so 0.5 ms per motor (load and pos) so 4 ms if 8 motors.
void update_load_pos_values(){
  for (int i = 0; i < n_servos; i++)
  {
      old_motor_pos[i] = last_motor_pos[i];
      last_motor_pos[i] = read_present_position(id[i]);
      if(last_motor_pos[i]>612 || last_motor_pos[i]<412){
        delay(1);
        SerialUSB.println("Weird position value");
        uint8_t counter_read= 0;
        while (last_motor_pos[i]>612 || last_motor_pos[i]<412){
          last_motor_pos[i] = read_present_position(id[i]);
          counter_read++;
        }
        SerialUSB.print("Found reasonable value after ");SerialUSB.print(counter_read);
        SerialUSB.println(" trials");
      }

      last_motor_load[i] = read_present_load(id[i]);

      old_motor_timestamp[i] = last_motor_timestamp[i];
      last_motor_timestamp[i] = millis();
      //m_dot_pos[i] = float(new_motor_pos - last_motor_pos[i]) / float(new_motor_timestamp - last_motor_timestamp[i]);
  }
}

void twitch_learning_prog(int i_action, float m_learning)
{

  // Initialisation of local variables
  float weight_delta;
  int16_t weight_temp;
  float s_dot_select;
  float weight_float;
  float weight_float_updated;
  int i_dir;

  // Learning for Loadcells and IMU
  for (int j_sensor = 0; j_sensor < n_ard * 3 + IMU_USEFUL_CHANNELS; j_sensor++)
  {

    // Select data from array
    s_dot_select = s_dot_last[j_sensor];
    //for the speed, we integrate it.
    if (j_sensor>=3*n_ard && j_sensor<3*n_ard + 3){

      //the integrated speed value here is in mm/s because TIME_INTERVAL_TWITCH is in ms.
      integrated_speed[j_sensor-3*n_ard] += s_dot_select * IMU_GAIN * TIME_INTERVAL_TWITCH; 
      s_dot_select = integrated_speed[j_sensor-3*n_ard];
    }

    // Select weight from array
    if (LEARN_IN_INT16_T){
      weight_temp = learning.weights[j_sensor][i_action];
      weight_float = (float)(weight_temp)/100.0;
    }
    else {
      weight_float = learning.weights[j_sensor][i_action];
    }


    // Apply Oja's differential learning rule
    weight_delta = oja_diff_learning_rule(m_learning, s_dot_select, weight_float);

    // Apply weight update rule
    weight_float_updated = weight_float + LEARNING_RATE * weight_delta;
    
    
    if (LEARN_IN_INT16_T){
      if (100*abs(weight_float_updated)>32766){
        SerialUSB.print("Warning, int16 overflow !!!! for sensor (row) ");SerialUSB.print(j_sensor);
        SerialUSB.print(" and action (column) ");SerialUSB.println(i_action);
        learning.weights[j_sensor][i_action] = get_sign(weight_float_updated)*32766;
      }
      else{
        learning.weights[j_sensor][i_action] = (int16_t)(100*weight_float_updated);
      }
    }
    else {
      learning.weights[j_sensor][i_action] = weight_float_updated;
    }

    //SerialUSB.println(learning.weights[j_sensor][i_action]);

  }


  //Learning for Motor Positions
  /*
  for (int j_motor_sensor = 0; j_motor_sensor < n_servos; j_motor_sensor++){
      s_dot_select = m_dot_pos[j_motor_sensor];
      weight = learning.weights_pos[j_motor_sensor][i_action];
      weight_delta = oja_diff_learning_rule(m_learning, s_dot_select, weight);
      learning.weights_pos[j_motor_sensor][i_action] = weight + LEARNING_RATE * weight_delta;

  }
  */



}

void reset_s_dot_last()
{
  for (int j_tmp = 0; j_tmp < n_ard * 3 + IMU_USEFUL_CHANNELS; j_tmp++)
  {
    s_dot_last[j_tmp] = 0;
  }
}

void reset_integrated_speed(){
  for (int i=0; i<3 ; i++)
    integrated_speed[i] = 0;
}


/* ------------------------------------------------------------------------------------------------------------------------------------- */

void calculate_m_dot(){
  for (int i = 0; i < n_servos; i++)
  {
    m_dot_pos[i] = float(last_motor_pos[i] - old_motor_pos[i]) / float(last_motor_timestamp[i] - old_motor_timestamp[i]);
  }
}

void calculate_m_dot_filtered(){
  //uint8_t oldestvalue_index_filter = (buf_filter.head + FILTER_ADD_SIZE-1) % (FILTER_ADD_SIZE);
  for (int i = 0; i < n_servos; i++)
  {
    //the actual size of the filter is FILTER_ADD_SIZE+1 because we store last_mpos, old_mpos, and the values contained in the filter.
    float num_filtered = float(last_motor_pos[i] - buf_filter.motor_pos[buf_filter.head][i])/float(FILTER_ADD_SIZE_LEARNING+1); 
    m_dot_pos[i] = num_filtered / float(last_motor_timestamp[i] - old_motor_timestamp[i]);
  }

}

void calculate_s_dot()
{

  // Initialization of local variables to compute derivatives of laodcell measurements
  float val_new;
  float timestamp_new;
  float t_delta;

  // differentiation needed for the loadcells
  for (int i_tmp = 0; i_tmp < n_ard * 3; i_tmp++)
  {
    // Get LC data
    val_new = ser_rx_buf.last_loadcell_data_float[i_tmp];

    // Define new timestamp
    timestamp_new = (int)ser_rx_buf.timestamp_loadcell[i_tmp / 3];

    // Convert ring buffer to continuous time line (i.e. value 256 will be 256 instead of 256 % 255 = 1)
    if (timestamp_new - timestamp_lc_old[i_tmp / 3] < 0)
    {
      t_delta = float((timestamp_new + 256) - timestamp_lc_old[i_tmp / 3]) / 1000;
    }
    else
    {
      t_delta = float(timestamp_new - timestamp_lc_old[i_tmp / 3]) / 1000;
    }

    // Calculate s_dot value
    s_dot_last[i_tmp] = (val_new - val_old_lc[i_tmp]) / t_delta;
  }

  // IMU channels : no differentiation needed.
  //accelerometer first
  for (int i=0; i<3; i++)
  {
    s_dot_last[n_ard * 3+i] = ser_rx_buf.last_IMU_acc_corrected[i];
  }

  //yaw after ; TODO : check that yaw is actually that value;
  for (int i=0; i<3; i++)
  {
    s_dot_last[n_ard * 3+3+i] = ser_rx_buf.last_IMU_gyro_corrected[i];
  }
  
}

void calculate_s_dot_filtered()
{

  // Initialization of local variables to compute derivatives of laodcell measurements
  float val_new;
  float timestamp_new;
  float t_delta;

  // differentiation needed for the loadcells
  for (int i_tmp = 0; i_tmp < n_ard * 3; i_tmp++)
  {
    float num_filtered = (ser_rx_buf.last_loadcell_data_float[i_tmp]-buf_filter.val_lc[buf_filter.head][i_tmp])/float(FILTER_ADD_SIZE_LEARNING+1);

    // Define new timestamp
    timestamp_new = (int)ser_rx_buf.timestamp_loadcell[i_tmp / 3];

    // Convert ring buffer to continuous time line (i.e. value 256 will be 256 instead of 256 % 255 = 1)
    if (timestamp_new - timestamp_lc_old[i_tmp / 3] < 0)
    {
      t_delta = float((timestamp_new + 256) - timestamp_lc_old[i_tmp / 3]) / 1000;
    }
    else
    {
      t_delta = float(timestamp_new - timestamp_lc_old[i_tmp / 3]) / 1000;
    }
    
    //Debugging
    //SerialUSB.println("num filtered "); SerialUSB.println(num_filtered,3);
    //SerialUSB.print("t delta "); SerialUSB.println(t_delta);

    // Calculate s_dot value
    s_dot_last[i_tmp] = num_filtered / t_delta;
  }

  // IMU channels : no differentiation needed.
  //accelerometer first
  for (int i=0; i<3; i++)
  {
    s_dot_last[n_ard * 3+i] = ser_rx_buf.last_IMU_acc_corrected[i] + val_old_IMU_acc_corrected[i];
    for (int k=0; k<FILTER_ADD_SIZE_LEARNING; k++){
      s_dot_last[n_ard * 3+i] += buf_filter.val_IMU[k][i];
    }
    s_dot_last[n_ard * 3+i] = s_dot_last[n_ard * 3+i]/float(2+FILTER_ADD_SIZE_LEARNING);
  }

  //gyroscope after (roll, pitch, yaw)
  for (int i=0; i<3; i++)
  {
    s_dot_last[n_ard*3+ 3+i] = ser_rx_buf.last_IMU_gyro_corrected[i] + val_old_IMU_gyro_corrected[i];
    for (int k=0; k<FILTER_ADD_SIZE_LEARNING; k++){
      s_dot_last[n_ard*3+ 3+i] += buf_filter.val_IMU[k][3+i];
    }
    s_dot_last[n_ard*3+ 3+i] = s_dot_last[n_ard*3+ 3+i]/float(2+FILTER_ADD_SIZE_LEARNING);
  }
  
}

void manual_recenter_robot_delay_twitch(){
  //SerialUSB.print(DURATION_MANUAL_RECENTERING);
  SerialUSB.println("15s delay starting, recenter robot on rugs if needed, interrupt with any serial input.");
  switch_frame_normal_mode();
  unsigned long time_start = millis();
  while(!SerialUSB.available() && millis()-time_start<DURATION_MANUAL_RECENTERING*1000)
  {
    unsigned long time_start_iter = millis();
    show_value_DC(0);
    update_load_pos_values();
    SerialUSB.print("Motor positions, ");
    print_motor_positions();
    SerialUSB.println("Interrupt this recentering delay with any serial input.");
    while(millis()-time_start_iter<TIME_INTERVAL_MANUAL_RECENTERING);
  }

  while(SerialUSB.available())
    SerialUSB.read();
  
  switch_frame_recording_mode();
  SerialUSB.println("Delay over");
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
int get_sign(float val)
{
  return (val < 0) ? -1 : (val > 0) ? 1 : 0;
}

/* ------------------------------------------------------------------------------------------------------------------------------------- */
float oja_diff_learning_rule(float m, float s_dot, float weight)
{
  // Oja's differential learning rule
  return m * s_dot - m * m * weight;
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

void saturation_lc_values_learning(){
  for (int i_channel = 0; i_channel < n_ard * 3; i_channel++) {
    if (abs(ser_rx_buf.last_loadcell_data_float[i_channel])>LIMIT_VAL_LC_LEARNING){
      SerialUSB.print("Warning, loadcell channel "); SerialUSB.print(i_channel);
      SerialUSB.print(" has returned ");SerialUSB.println(ser_rx_buf.last_loadcell_data_float[i_channel]);
      SerialUSB.println("This value is put at the previous value ");SerialUSB.println(val_old_lc[i_channel]);
      ser_rx_buf.last_loadcell_data_float[i_channel] = val_old_lc[i_channel];
    }
  }
}
void saturation_acc_values_learning(){
  for (int i_channel = 0; i_channel < 3; i_channel++) {
    if (abs(ser_rx_buf.last_IMU_acc_corrected[i_channel])>LIMIT_VAL_ACC_LEARNING){
      SerialUSB.print("Warning, Accelerometer channel "); SerialUSB.print(i_channel);
      SerialUSB.print(" has returned (after correction)"); SerialUSB.println(ser_rx_buf.last_IMU_acc_corrected[i_channel]);
      SerialUSB.println("This value is put at the previous value ");SerialUSB.println(val_old_IMU_acc_corrected[i_channel]);
      ser_rx_buf.last_IMU_acc_corrected[i_channel] = val_old_IMU_acc_corrected[i_channel];
    }
  }
}

/// Filter used during learning

void print_buf_filter(){
  SerialUSB.print("Head value ");SerialUSB.println(buf_filter.head);
  for (int i_ard=0;i_ard<n_ard;i_ard++){
    SerialUSB.print("Loadcell "); SerialUSB.print(i_ard+1);SerialUSB.print(" values \t");
    for (int k=0; k<FILTER_ADD_SIZE_LEARNING; k++){
      for (int i_channel=0; i_channel<3;i_channel++){
        SerialUSB.print(buf_filter.val_lc[k][i_ard*3+i_channel],3);
        SerialUSB.print("\t");
      }
      SerialUSB.print("\t");
    }
    SerialUSB.println();
  }

  SerialUSB.print("Accelerometer values ");
  for (int k=0; k<FILTER_ADD_SIZE_LEARNING; k++){
    for (int i_acc_imu=0;i_acc_imu<3;i_acc_imu++){
      SerialUSB.print(buf_filter.val_IMU[k][i_acc_imu],3);
      SerialUSB.print("\t");
    }
    SerialUSB.print("\t");
  }
  SerialUSB.println();

  SerialUSB.print("Gyro values ");
  for (int k=0; k<FILTER_ADD_SIZE_LEARNING; k++){
    for (int i_gyro_imu=0;i_gyro_imu<3;i_gyro_imu++){
      SerialUSB.print(buf_filter.val_IMU[k][3+i_gyro_imu],3);
      SerialUSB.print("\t");
    }
    SerialUSB.print("\t");
    }
  SerialUSB.println();

  for (int k=0; k<FILTER_ADD_SIZE_LEARNING; k++){
  SerialUSB.print("Motor position values ");
    for (int i_motor=0;i_motor<n_servos;i_motor++){
      SerialUSB.print(buf_filter.motor_pos[k][i_motor]);
      SerialUSB.print("\t");
    }
  SerialUSB.println();
  }
  SerialUSB.println();

}

void update_buf_filter(){
  for (int i_lc=0;i_lc<n_ard*3;i_lc++){
    buf_filter.val_lc[buf_filter.head][i_lc]=val_old_lc[i_lc];
  }
  for (int i_acc_imu=0;i_acc_imu<3;i_acc_imu++){
    buf_filter.val_IMU[buf_filter.head][i_acc_imu]=val_old_IMU_acc_corrected[i_acc_imu];
  }
  for (int i_gyro_imu=0;i_gyro_imu<3;i_gyro_imu++){
    buf_filter.val_IMU[buf_filter.head][3+i_gyro_imu]=val_old_IMU_gyro_corrected[i_gyro_imu];
  }

  for (int i_motor=0;i_motor<n_servos;i_motor++){
    buf_filter.motor_pos[buf_filter.head][i_motor]=old_motor_pos[i_motor];
  }
  buf_filter.head = (buf_filter.head+1)%(FILTER_ADD_SIZE_LEARNING);
}

void init_buf_filter(){
  buf_filter.head = 0;
  for (int k=0;k<FILTER_ADD_SIZE_LEARNING; k++){
    for (int i_ard=0;i_ard<MAX_NR_ARDUINO*3;i_ard++){
      buf_filter.val_lc[k][i_ard]=0;
    }
    for (int i_imu=0;i_imu<IMU_USEFUL_CHANNELS;i_imu++){
      buf_filter.val_IMU[k][i_imu]=0;
    }
    for (int i_motor=0;i_motor<MAX_NR_SERVOS;i_motor++){
      buf_filter.motor_pos[k][i_motor]=0;
    }
  }
}

void init_weight_matrix(){
  for (int j_tmp = 0; j_tmp < n_ard * 3 + IMU_USEFUL_CHANNELS; j_tmp++)
  {
    for (int i_action = 0; i_action < n_servos * 2; i_action++)
    {
      learning.weights[j_tmp][i_action] = 0;
    }
  }
}


void print_twitching_parameters(){
  SerialUSB.print("Slope of the ramp used for learning : "); SerialUSB.println(SLOPE_LEARNING);
  //SerialUSB.print("Step Amplitude : "); SerialUSB.println(STEP_AMPL);
  SerialUSB.print("Learning rate : "); SerialUSB.println(LEARNING_RATE);
  SerialUSB.print("Duration part 0 : "); SerialUSB.println(DURATION_PART0);
  SerialUSB.print("Duration part 1 : "); SerialUSB.println(DURATION_PART1);
  SerialUSB.print("Duration part 2 : "); SerialUSB.println(DURATION_PART2);
  SerialUSB.print("Time interval twitch : "); SerialUSB.println(TIME_INTERVAL_TWITCH);
  
  SerialUSB.print("Use filter (1:Yes/0:No) : "); SerialUSB.println(1);
  if (USE_FILTER_LEARNING)
    SerialUSB.print("Filter Size : "); SerialUSB.println(FILTER_ADD_SIZE_LEARNING);
  SerialUSB.print("Compliant Mode : "); SerialUSB.println(COMPLIANT_MODE);
  SerialUSB.print("Soft compliance margin : "); SerialUSB.println(SOFT_COMPLIANCE_MARGIN); 
  SerialUSB.print("Soft compliance slope : "); SerialUSB.println(SOFT_COMPLIANCE_SLOPE); 
  SerialUSB.print("Soft punch : "); SerialUSB.println(SOFT_PUNCH);  
  SerialUSB.print("Stiff compliance margin : "); SerialUSB.println(STIFF_COMPLIANCE_MARGIN); 
  SerialUSB.print("Stiff compliance slope : "); SerialUSB.println(STIFF_COMPLIANCE_SLOPE); 
  SerialUSB.print("Stiff punch : "); SerialUSB.println(STIFF_PUNCH);  
  SerialUSB.print("Movement Learning compliance margin : "); SerialUSB.println(MOV_LEARNING_COMPLIANCE_MARGIN); 
  SerialUSB.print("Movement Learning compliance slope : "); SerialUSB.println(MOV_LEARNING_COMPLIANCE_SLOPE); 
  SerialUSB.print("Movement Learning punch : "); SerialUSB.println(MOV_LEARNING_PUNCH);  
    
  SerialUSB.print("Recentering between 2 actions : "); SerialUSB.println(RECENTERING_BETWEEN_ACTION);
  if (RECENTERING_BETWEEN_ACTION){
    SerialUSB.print("Recentering between 2 actions delay : "); SerialUSB.println(RECENTERING_DELAY);
    SerialUSB.print("Recentering compliance margin : "); SerialUSB.println(RECENTERING_COMPLIANCE_MARGIN); 
    SerialUSB.print("Recentering compliance slope : "); SerialUSB.println(RECENTERING_COMPLIANCE_SLOPE); 
    SerialUSB.print("Recentering punch : "); SerialUSB.println(RECENTERING_PUNCH);   
  }
  print_neutral_positions();
}

void print_motor_positions(){
  SerialUSB.print("Motor positions: ");
  for (int i = 0; i < n_servos; i++)
  {
    SerialUSB.print(last_motor_pos[i]);SerialUSB.print("\t");
  }
  SerialUSB.println();
}

void print_neutral_positions(){
  SerialUSB.print("Motor neutral positions: ");
  for (int i = 0; i < n_servos; i++)
  {
    SerialUSB.print(neutral_pos[i]);SerialUSB.print("\t");
  }
  SerialUSB.println();
}