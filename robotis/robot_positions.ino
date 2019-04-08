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
  uint16_t delta_angle = uint16_t(20* 3.413);
  if (idx_limb_lift==1)
    set_goal_position(15,512+delta_angle);
  else if (idx_limb_lift==2)
    set_goal_position(17,512-delta_angle);
  else if (idx_limb_lift==3)
    set_goal_position(2,512-delta_angle);
  else if (idx_limb_lift==4)
    set_goal_position(13,512+delta_angle);
}

void serial_read_lift_limb(){
  if(SerialUSB.available()){
    char char_read = SerialUSB.read();
    SerialUSB.println(char_read);
    SerialUSB.println(char_read,DEC);    
    pose_stance();
    delay(2000);
    if (char_read>48 && char_read<53)
      hardcoded_lift_limb(char_read-48);
  }
}