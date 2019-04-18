void pose_stance()
{
  uint16_t  goal_positions_stance[n_servos];
  for (int i = 0; i < n_servos; i++)
  {
    goal_positions_stance[i]= 512;
  } 
  syncWrite_position_n_servos(n_servos, id, goal_positions_stance); 
}

//syncWrite takes approximately 0.36 msec to write the goal positions.
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

void hardcoded_lift_limb(int idx_limb_lift){
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
void serial_read_lift_limb(){
  if(SerialUSB.available()){
    char char_read = SerialUSB.read();
    SerialUSB.println(char_read);
    SerialUSB.println(char_read,DEC);    

    if (char_read=='s') //ASCII code : 's' = 115
      pose_stance();
    if (char_read>'0' && char_read<'5'){ //ASCII code : 0 = 48
      pose_stance();
      SerialUSB.println("Staying for 5 s in stance to prepare lift off");
      delay(5000);
      hardcoded_lift_limb(char_read-48);
    }
  }
}