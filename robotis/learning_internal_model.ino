void find_closest_LC(){

  uint8_t lc_count[n_ard];
  boolean lc_full[n_ard];
  uint8_t closest_motor[n_ard];
  uint8_t closest_sensor[n_servos];
  boolean servo_matched[n_servos];
  memset(lc_count,0,sizeof(lc_count));
  memset(lc_full,0,sizeof(lc_full));
  memset(closest_motor,0,sizeof(closest_motor));
  memset(closest_sensor,0,sizeof(closest_sensor));
  memset(servo_matched,0,sizeof(servo_matched));
  uint8_t n_iter = 0;

  uint8_t s = sum_bool_array(servo_matched, n_servos);
  uint8_t s_agree_before = -1;
  while(s<s_agree_before){
    s_agree_before=s;
    //first we determine for each sensor the closest motor.
    for (uint8_t i=0; i<n_ard; i++){
      //closest_motor[i] = get_index_max();
    }
  }
}

uint8_t sum_bool_array(boolean servo_matched[], uint8_t array_size){
  uint8_t s = 0;
  for (uint8_t i=0; i< array_size; i++)
  {
    s += servo_matched[i];
  } 
  return s; 
}

uint8_t get_index_max(float vector[], uint8_t vector_length, boolean index_skipped[]){
  uint8_t index_max = 0;
  float max_value = vector[0];
  for (uint8_t index = 1; index <vector_length; index++){
    if (!index_skipped[index]){
      if (vector[index]>max_value){
        index_max = index;
        max_value = vector[index];
      }
    }
    
  }
  return index_max;
}

void compute_partial_sum(bool splitDir, uint8_t n_motors_left, uint8_t n_lc_left, float* partial_sums){
  if (splitDir){
    
  }
}