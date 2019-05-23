void pose_stance()
{
  uint16_t  goal_positions_stance[n_servos];
  for (int i = 0; i < n_servos; i++)
  {
    goal_positions_stance[i]= neutral_pos[i];
  } 
  syncWrite_position_n_servos(n_servos, id, goal_positions_stance); 
}

void pose_stance_512()
{
  uint16_t  goal_positions_stance[n_servos];
  for (int i = 0; i < n_servos; i++)
  {
    goal_positions_stance[i]= 512;
  } 
  syncWrite_position_n_servos(n_servos, id, goal_positions_stance); 
}

//syncWrite takes approximately 0.36 msec to write the goal positions.
/*
void progressive_pose_stance(int total_delay,int number_of_steps){
  uint16_t  goal_positions_stance[n_servos];
  int delay_steps = total_delay/number_of_steps;
  for (int count_steps = 1; count_steps < number_of_steps + 1; count_steps++){
    unsigned long timestart = millis();
    update_load_pos_values(); // takes 0.25 ms per read per motor, so 0.5 ms per motor (load and pos) so 
    for (int i_servo = 0; i_servo < n_servos; i_servo++){
      goal_positions_stance[i_servo] = 512 + (last_motor_pos[i_servo]-512) * double(number_of_steps-count_steps) / double(number_of_steps);
    }
    syncWrite_position_n_servos(n_servos, id, goal_positions_stance);
    while (millis()-timestart<delay_steps);
  }
}
*/



void harcoded_hip_flexed_inside(){
  uint16_t pos_flexed_hip1 = 432;
  set_goal_position(13,pos_flexed_hip1);
  set_goal_position(15,pos_flexed_hip1);
  uint16_t pos_flexed_hip2 = 592;
  set_goal_position(2,pos_flexed_hip2);
  set_goal_position(17,pos_flexed_hip2);
}

void harcoded_hip_flexed_outside(){
  uint16_t pos_flexed_hip1 = 592;
  set_goal_position(13,pos_flexed_hip1);
  set_goal_position(15,pos_flexed_hip1);
  uint16_t pos_flexed_hip2 = 432;
  set_goal_position(2,pos_flexed_hip2);
  set_goal_position(17,pos_flexed_hip2);
}

void hardcoded_left_hips_center(){
  uint16_t pos_flexed_hip = 532;
  set_goal_position(2,pos_flexed_hip);
  set_goal_position(17,pos_flexed_hip);  
}


void hardcoded_left_hips_outside(){
  uint16_t pos_flexed_hip = 492;
  set_goal_position(2,pos_flexed_hip);
  set_goal_position(17,pos_flexed_hip);  
}

void hardcoded_right_hips_center(){
  uint16_t pos_flexed_hip = 492;
  set_goal_position(13,pos_flexed_hip);
  set_goal_position(15,pos_flexed_hip);  
}

void hardcoded_right_hips_outside(){
  uint16_t pos_flexed_hip = 532;
  set_goal_position(13,pos_flexed_hip);
  set_goal_position(15,pos_flexed_hip);  
}

void move_hips_wrapper(){
  SerialUSB.println("Stance");
  pose_stance();
  measure_mean_values_LC(10,2000);
  SerialUSB.println("Left Hips to the center");
  hardcoded_left_hips_center();
  measure_mean_values_LC(10,2000);
  SerialUSB.println("Left Hips to the outside");
  hardcoded_left_hips_outside();
  measure_mean_values_LC(10,2000);
  pose_stance();
  delay(1000);
  SerialUSB.println("Rights Hips to the center"); 
  hardcoded_right_hips_center();
  measure_mean_values_LC(10,2000); 
  SerialUSB.println("Rights Hips to the outside"); 
  hardcoded_right_hips_outside();
  measure_mean_values_LC(10,2000); 
}
void move_hips_int_out_wrapper(){
  SerialUSB.println("hips outside"); 
  harcoded_hip_flexed_outside();
  delay(10000);
  SerialUSB.println("stance"); 
  pose_stance();
  delay(10000); 
  SerialUSB.println("hips inside"); 
  harcoded_hip_flexed_inside();
  delay(10000);
  SerialUSB.println("stance"); 
  pose_stance();
  delay(10000); 
}


void hardcoded_progressive_lift_limb_4legs(int idx_limb_lift){
  uint8_t i_servo = 0;
  int dir_sign = 0;
  if (idx_limb_lift==1){
    i_servo = 5;
    dir_sign = +1;
  }
  else if (idx_limb_lift==2){
    i_servo = 7;
    dir_sign = -1;  
  }
  else if (idx_limb_lift==3){
    i_servo = 1;
    dir_sign = -1;  
  }
  else if (idx_limb_lift==4){
    i_servo = 3;
    dir_sign = 1; 
  } 
  i_servo = i_servo -1;
  if (COMPLIANT_MODE==1){
    make_all_servos_compliant_syncWrite();
    make_servo_stiff(id[i_servo]);
  }
  int n_frames_prog_lift = DURATION_PART1/TIME_INTERVAL_TWITCH;
  for (int i=0; i<n_frames_prog_lift; i++){
    unsigned long time_start = millis();
    //twitch_part1_moving(i_servo, dir_sign, ampl_step_pos, i, n_frames_prog_lift);
    twitch_part1_moving_ramp(i_servo, dir_sign, n_frames_prog_lift);
    show_value_DC(0);
    if (millis()-time_start>TIME_INTERVAL_TWITCH)
      SerialUSB.println("Not fast enough");
    while (millis()-time_start<TIME_INTERVAL_TWITCH);
  }
  SerialUSB.println("End of movement, 5s delay to assess static stability.");
  delay(5000);
  restaure_default_parameters_all_motors_syncWrite();
  SerialUSB.println("Back to stance.");
  pose_stance();

}

void hardcoded_lift_limb_4legs(int idx_limb_lift){
  uint16_t delta_angle = uint16_t(30* 3.413);
  if (idx_limb_lift==1)
    set_goal_position(15,512+delta_angle);
  else if (idx_limb_lift==2)
    set_goal_position(17,512-delta_angle);
  else if (idx_limb_lift==3)
    set_goal_position(2,512-delta_angle);
  else if (idx_limb_lift==4)
    set_goal_position(13,512+delta_angle);
}

//reads console and lifts limb if input = ID of one limb, i.e 1, 2, 3 ... n_limbs
void serial_read_brutal_lift_limb(){
  if(SerialUSB.available()){
    char char_read = SerialUSB.read();
    if (char_read=='s') //ASCII code : 's' = 115
      pose_stance();
    if (char_read>'0' && char_read<'5'){ //ASCII code : 0 = 48
      pose_stance();
      SerialUSB.println("Staying for 5 s in stance to prepare lift off");
      delay(5000);
      hardcoded_lift_limb_4legs(char_read-48);
    }
  }
}

void serial_read_change_motor_parms(){
  if (SerialUSB.available()){
    char char_read = SerialUSB.read();
    if (char_read=='s') //ASCII code : 's' = 115
      make_all_servos_stiff_syncWrite();
    if (char_read=='c') //ASCII code : 's' = 115
      make_all_servos_compliant_syncWrite();
    if (char_read=='d') //ASCII code : 's' = 115
      restaure_default_parameters_all_motors_syncWrite();
  }
}

void serial_read_progressive_lift(){
  if(SerialUSB.available()){
    char char_read = SerialUSB.read();
    if (char_read>'0' && char_read<'5'){ //ASCII code : 0 = 48
      pose_stance();
      int idx_limb_lifted = char_read-48;
      SerialUSB.print("Staying for 5 s in stance to prepare progressive lift off of limb ");
      SerialUSB.println(idx_limb_lifted);
      delay(5000);
      hardcoded_progressive_lift_limb_4legs(idx_limb_lifted);
      //an other delay to read the final values of the loadcells
      delay(5000);
    }
  }
}

//works only with less than 10 servos
void serial_read_test_twitch(){
  if(SerialUSB.available()){
    char char_read = SerialUSB.read();
    if (char_read>'0' && char_read<'9'){ //ASCII code : 0 = 48
      char char_read_dir = SerialUSB.read();
      if (char_read_dir=='+' || char_read_dir=='-')
      {
        int dir_sign = 1;
        if (char_read_dir =='-')
          dir_sign = -1;
        pose_stance();
        int idx_servo = char_read-49;
        SerialUSB.print("Staying for 5 s in stance to prepare movement of motor ");
        SerialUSB.print(idx_servo+1);
        SerialUSB.print(" direction ");
        SerialUSB.print(char_read_dir);
        delay(5000);

        if (COMPLIANT_MODE==1){
          make_all_servos_compliant_syncWrite();
        }
        
        change_motor_parameters_movement_learning(id[idx_servo]);
        int n_frames_prog_lift = DURATION_PART1/TIME_INTERVAL_TWITCH;
        for (int i=0; i<n_frames_prog_lift; i++){
          unsigned long time_start = millis();
          twitch_part1_moving_ramp(idx_servo, dir_sign, i);
          show_value_DC(0);
          if (millis()-time_start>TIME_INTERVAL_TWITCH)
            SerialUSB.println("Not fast enough");
          while (millis()-time_start<TIME_INTERVAL_TWITCH);
        }
        delay(5000);// delay to read the final values of the loadcells on the console

        SerialUSB.println("Movement part 2, recentering of only the servo that had twitched");
        int n_frames_prog_recent = DURATION_PART2/TIME_INTERVAL_TWITCH;
        for (int i=0; i<n_frames_prog_recent; i++){
          unsigned long time_start = millis();
          update_load_pos_values();
          twitch_part2_recentering(idx_servo,i, n_frames_prog_recent);
          show_value_DC(0);
          if (millis()-time_start>TIME_INTERVAL_TWITCH)
            SerialUSB.println("Not fast enough");
          while (millis()-time_start<TIME_INTERVAL_TWITCH);
        }
        recentering_between_action();
        delay(5000);
        restaure_default_parameters_all_motors_syncWrite();
      }
    }
  }
}


