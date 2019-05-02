void harcoded_tegotae(){
  initialize_hardcoded_limbs();
  init_phi_tegotae();
  while (true){
    update_phi_tegotae();
    send_command_limb_oscillators();
  }
}

void harcoded_trot(){
  initialize_hardcoded_limbs();
  init_phi_trot();
  while (true){
    update_phi_trot();
    send_command_limb_oscillators();
  }
}

//change dir is set to true for hips if - hip direction produces lift off
//change dir is set to true for knees if - knee direction pushes backwards

//hip first, knee after, in loadcell order
void initialize_hardcoded_limbs(){

  //Limb 1, Loadcell 1, Hip 15, Knee 16
  limbs[0][0] = 15; limbs[0][1] = 16;
  changeDirs[0][0] = false; changeDirs[0][1] = false;
  //Limb 2 :
  limbs[1][0] = 17; limbs[1][1] = 18;
  changeDirs[1][0] = true; changeDirs[1][1] = true;

  //Limb 3 :
  limbs[2][0] = 2; limbs[2][1] = 3;
  changeDirs[2][0] = true; changeDirs[2][1] = true;
 
  //Limb 4 :
  limbs[3][0] = 13; limbs[3][1] = 14;
  changeDirs[3][0] = false; changeDirs[3][1] = false;

  for (int i=0; i<n_limb; i++){
    offset_knee_to_hip[i]=pi/2;
  }
}

///Oscillators

void send_command_limb_oscillators(){
  uint8_t  servo_id_list[n_servos];
  for (int i=0; i<n_limb; i++){
    //Hip first
    servo_id_list[2*i] = limbs[i][0];
    goal_positions_tegotae[2*i] = phase2pos_hipknee_wrapper(phi[i], 1, changeDirs[i][0]);
    servo_id_list[2*i+1] = limbs[i][1];
    goal_positions_tegotae[2*i+1] = phase2pos_hipknee_wrapper(phi[i]+offset_knee_to_hip[i], 0, changeDirs[i][1]);
  }
  syncWrite_position_n_servos(n_servos, servo_id_list, goal_positions_tegotae);
}


uint16_t phase2pos_oscillator(float phase, float amp_deg, boolean changeDir){
  uint16_t pos;
  if (changeDir)
    pos = (uint16_t)(512 - (float)(3.413*amp_deg*cos(phase)));
  else
    pos = (uint16_t)(512 + (float)(3.413*amp_deg*cos(phase)));
  return pos;
}

uint16_t phase2pos_hipknee_wrapper(float phase, boolean isHip, boolean changeDir){
  if (isHip){
    if (cos(phase) > 0) // hip swing
      return phase2pos_oscillator(phase, amplitude_hip_deg, changeDir);
    else // hip stance
      return phase2pos_oscillator(phase, alpha*amplitude_hip_deg, changeDir);
  }
  else{
    return phase2pos_oscillator(phase, amplitude_knee_deg, changeDir);
  }
}


///Tegotae

void init_phi_tegotae(){
  update_load_pos_values();
  for (int i=0; i<n_limb; i++){
    phi[i] = pi/2;
  }
  t_offset_oscillators = millis();
}


void update_phi_tegotae()
{
  unsigned long t_current = millis() - t_offset_oscillators;
  send_frame_and_update_sensors(0); //to update last_loadcell_data_float
  for (int i=0; i<n_limb; i++){
    N_s[i] = ser_rx_buf.last_loadcell_data_float[2 + i * 3];   
  }
  for (int i=0; i<n_limb; i++){
    phi_dot[i] = advanced_tegotae_rule(i);
    //actual update
    phi[i] = phi[i] + phi_dot[i] * (t_current - t_last_phi_update) / 1000;
  }
  t_last_phi_update = t_current;
}



float simple_tegotae_rule(float phase, float ground_reaction_force){
  float phi_dot = 2 * pi * frequency - sigma_s * ground_reaction_force * cos(phase);
  return phi_dot;
}

float advanced_tegotae_rule(uint8_t i_limb){
  float GRF_term = 0;
  for (int j=0; j<n_limb; j++){
    GRF_term += inverse_map[i_limb][j]*N_s[j];
  }
  float phi_dot = 2 * pi * frequency + sigma_advanced * GRF_term * cos(phi[i_limb]);
  return phi_dot;
}

/// Trot

void init_phi_trot(){
  for (int i : {1,3}){
    //phi[i] = pi;
    phi[i] = pi*((double) rand() / (RAND_MAX));
  }
}

void update_phi_trot()
{
  float trot_frequency = 2;
  unsigned long t_current = millis() - t_offset_oscillators;
  for (int i=0; i<n_limb; i++){
    phi[i] = phi[i] + 2*pi*trot_frequency * (t_current - t_last_phi_update) / 1000;
  }
  t_last_phi_update = t_current;
}


/// Printing

void print_phi_info(){
  SerialUSB.print("Phase of the limbs :" );
  for (int i=0; i<n_limb; i++){ 
    SerialUSB.print(phi[i]);
    SerialUSB.print("\t");
  }
  SerialUSB.println();
  SerialUSB.print("Time update "); SerialUSB.println(t_last_phi_update);
}

void print_goal_positions_tegotae(){
  SerialUSB.println("Goal Position tegotae : ");
  for (int i=0; i<n_limb; i++){ 
    SerialUSB.print(goal_positions_tegotae[2*i]);
    SerialUSB.print("\t");
    SerialUSB.println(goal_positions_tegotae[2*i+1]);
  }
  SerialUSB.println();
}

void print_GRF(){
  SerialUSB.print("GRFs (in limb order) :" );
  for (int i=0; i<n_limb; i++){ 
    SerialUSB.print(N_s[i]);
    SerialUSB.print("\t");
  }
  SerialUSB.println();
}