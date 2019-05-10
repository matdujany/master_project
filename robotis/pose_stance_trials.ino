//these are functions that I built to improve the recentering
//most of them ended up creating more instability...


void pose_stance_soft(){

  restaure_default_parameters_all_motors_syncWrite();
  pose_stance();
  sleep_while_moving();
  update_load_pos_values();  

  uint16_t max_pos_gap = 0;
  uint16_t pos_gaps[n_servos];
  uint16_t count_max_idx[n_servos];
  for (int i=0; i<n_servos; i++)
    count_max_idx[i] = 0;
  uint8_t index_servo_max = 1;
  uint8_t index_servo_max_old = 1;
  compute_max_gap_stance(max_pos_gap, index_servo_max, pos_gaps, count_max_idx);

  uint8_t count_iterations = 0;
  while (max_pos_gap>3 & count_iterations<20){
    get_closer_to_stance(max_pos_gap, index_servo_max, pos_gaps, count_max_idx);
    sleep_while_moving();
    compute_max_gap_stance(max_pos_gap, index_servo_max, pos_gaps, count_max_idx);
    SerialUSB.print(index_servo_max);
    SerialUSB.print("\t");
    SerialUSB.println(max_pos_gap);
    count_iterations++;
  }
}

void get_closer_to_stance(uint16_t max_pos_gap, uint8_t index_servo_max, uint16_t *pos_gaps, uint16_t *count_max_idx){
  /*
  uint8_t new_compliance_margin[n_servos];
  uint16_t new_punch[n_servos];
  uint8_t new_compliance_slope[n_servos];
  for (int i = 0; i < n_servos; i++){
    new_compliance_margin[i] = std::max(1, max_pos_gap - pos_gaps[i]);
    new_punch[i] = std::min(1023,32 + pos_gaps[i] * count_max_idx[i]);
    new_compliance_slope[i] = std::max(1,32 + pos_gaps[i] * count_max_idx[i]);
  }
  
  syncWrite_compliance_margins(n_servos, id, new_compliance_margin);
  syncWrite_compliance_slopes(n_servos, id, new_compliance_slope);
  syncWrite_punchs(n_servos, id, new_punch);
  */
 make_all_servos_stiff_syncWrite();
 pose_stance();
 sleep_while_moving();

}

/*
void pose_stance_soft(){
  uint16_t max_pos_gap = 0;
  uint8_t index_servo_max = 1;
  compute_max_gap_stance(max_pos_gap, index_servo_max);
  uint8_t count_iterations = 0;
  while (max_pos_gap>3 & count_iterations<20){
    uint8_t new_compliance_margin = max_pos_gap-2;
    for (int i = 0; i < n_servos; i++){
      if (i==index_servo_max)
        set_compliance_margin(id[i],3);
      else
        set_compliance_margin(id[i],new_compliance_margin);
    }
    set_goal_position(id[index_servo_max],512);
    delay(1000);
    //sleep_while_moving();
    compute_max_gap_stance(max_pos_gap, index_servo_max);
    SerialUSB.print(index_servo_max);
    SerialUSB.print("\t");
    SerialUSB.println(max_pos_gap);
    count_iterations++;    
  }

  //to put things back to normal
  restaure_default_parameters_all_motors_syncWrite();
  pose_stance();
  update_load_pos_values();
}
*/

/*
void pose_stance_soft(){
  uint16_t max_pos_gap = 0;
  uint8_t index_servo_max = 1;
  compute_max_gap_stance(max_pos_gap, index_servo_max);
  uint8_t new_compliance_margin = 1;
  uint8_t count_iterations = 0;
  SerialUSB.println("Max pos gap");
  while (max_pos_gap>3 & count_iterations<20){
    new_compliance_margin = max_pos_gap - 2;
    syncWrite_compliance_margin_all_servo(new_compliance_margin);
    syncWrite_same_punch_all_servos(10);
    syncWrite_compliance_slope_all_servo(200);
    pose_stance();
    sleep_while_moving();
    compute_max_gap_stance(max_pos_gap, index_servo_max);
    SerialUSB.print(index_servo_max);
    SerialUSB.print("\t");
    SerialUSB.println(max_pos_gap);
    count_iterations++;
  }
}
*/
