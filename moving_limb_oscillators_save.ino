
void init_recording_locomotion(){
  switch_frame_recording_mode();
  SerialUSB.print("Waiting for any input from Serial USB console to start recording...");
  while (!SerialUSB.available());  
  SerialUSB.println("recording started !");
  SerialUSB.flush();
}

void record_harcoded_trot(int recording_duration){
  print_locomotion_parameters();
  init_recording_locomotion();
  initialize_hardcoded_limbs();

  init_phi_trot();
  send_command_limb_oscillators();

  unsigned long t_start_recording = millis();
  while (millis()-t_start_recording<recording_duration*1000){
    unsigned long t_start_update_loop = millis();
    send_phi_and_pos_Serial3();
    //this frame is not needed for trot, but I use it to capture load infos.
    send_frame_and_update_sensors(1,0);
    update_phi_trot();
    send_command_limb_oscillators();
    while(millis()-t_start_update_loop<DELAY_UPDATE_TEGOTAE);
  }
  SerialUSB.println("Trot recording over");
  SerialUSB.print("Nb end bytes sent: ");SerialUSB.println(nb_end_bytes_sent);
  SerialUSB.print("Nb frames found: ");SerialUSB.println(nb_frames_found);
}

void record_harcoded_tegotae(int recording_duration){
  print_locomotion_parameters();
  init_recording_locomotion();
  initialize_hardcoded_limbs();

  init_phi_tegotae();
  send_command_limb_oscillators();

  unsigned long t_start_recording = millis();

  while (millis()-t_start_recording<recording_duration*1000){
    unsigned long t_start_update_loop = millis();
    send_phi_and_pos_Serial3();
    send_frame_and_update_sensors(1,0);
    update_phi_tegotae();
    send_command_limb_oscillators();
    while(millis()-t_start_update_loop<DELAY_UPDATE_TEGOTAE);
  }
  SerialUSB.println("Tegotae recording over");
  SerialUSB.print("Nb end bytes sent: ");SerialUSB.println(nb_end_bytes_sent);
  SerialUSB.print("Nb frames found: ");SerialUSB.println(nb_frames_found);  
}


void send_phi_and_pos_Serial3(){
  send_phi_Serial3();
  simple_send_pos_Serial3();
}

void hardcoded_tegotae(){
  print_locomotion_parameters();
  initialize_hardcoded_limbs();
  init_phi_tegotae();
  send_command_limb_oscillators();
  while (true){
    unsigned long t_start_update_loop = millis();
    send_frame_and_update_sensors(1,0);
    update_phi_tegotae();
    send_command_limb_oscillators();
    while(millis()-t_start_update_loop<DELAY_UPDATE_TEGOTAE);
  }
}

void hardcoded_trot(){
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
  if (direction_X){
    //Limb 1
    limbs[0][0] = 5; limbs[0][1] = 4;
    changeDirs[0][0] = false; changeDirs[0][1] = false;
    //Limb 2 :
    limbs[1][0] = 7; limbs[1][1] = 6;
    changeDirs[1][0] = true; changeDirs[1][1] = true;
    //Limb 3 :
    limbs[2][0] = 1; limbs[2][1] = 0;
    changeDirs[2][0] = true; changeDirs[2][1] = true;
    //Limb 4 :
    limbs[3][0] = 3; limbs[3][1] = 2;
    changeDirs[3][0] = false; changeDirs[3][1] = false;
  }
  else{
    //Limb 1
    limbs[0][0] = 4; limbs[0][1] = 5;
    changeDirs[0][0] = true; changeDirs[0][1] = true;
    //Limb 2 :
    limbs[1][0] = 6; limbs[1][1] = 7;
    changeDirs[1][0] = true; changeDirs[1][1] = false;
    //Limb 3 :
    limbs[2][0] = 0; limbs[2][1] = 1;
    changeDirs[2][0] = true; changeDirs[2][1] = true;
    //Limb 4 :
    limbs[3][0] = 2; limbs[3][1] = 3;
    changeDirs[3][0] = true; changeDirs[3][1] = false;
  }


  init_offset_class1();
}

void init_offset_class1(){
  if (flagTurning){
    for (int i : {1, 2}){
      offset_class1[i] = -pi/2;
    }
    for (int i : {0, 3}){
      offset_class1[i] = pi/2;
    }
  }
  else {
    for (int i=0; i<n_limb; i++){
      offset_class1[i]=pi/2;
    }   
  }
}

///Oscillators

void send_command_limb_oscillators(){
  uint8_t  servo_id_list[n_servos];
  for (int i=0; i<n_limb; i++){
    //class 1 first : doing movement
    servo_id_list[2*i] = id[limbs[i][0]];
    goal_positions_tegotae[2*i] = phase2pos_hipknee_wrapper(phi[i]+offset_class1[i], 0, changeDirs[i][0]);
    //class 2 : stance swing
    servo_id_list[2*i+1] = id[limbs[i][1]];
    goal_positions_tegotae[2*i+1] = phase2pos_hipknee_wrapper(phi[i], 1, changeDirs[i][1]);
  }
  syncWrite_position_n_servos(n_servos, servo_id_list, goal_positions_tegotae);
}


uint16_t phase2pos_oscillator(float phase, float amp_deg, boolean changeDir){
  uint16_t pos;
  if (changeDir)
    pos = (uint16_t)(512 - (float)(3.413*amp_deg*sin(phase)));
  else
    pos = (uint16_t)(512 + (float)(3.413*amp_deg*sin(phase)));
  return pos;
}

uint16_t phase2pos_hipknee_wrapper(float phase, boolean isClass2, boolean changeDir){
  if (isClass2){
    if (sin(phase) > 0) // swing
      return phase2pos_oscillator(phase, amplitude_class2, changeDir);
    else // reduced amplitude in stance for class 2
      return phase2pos_oscillator(phase, alpha*amplitude_class2, changeDir);
  }
  else{
    return phase2pos_oscillator(phase, amplitude_class1, changeDir);
  }
}


///Tegotae

void init_phi_tegotae(){
  //
  for (int i=0; i<n_limb; i++){
    phi[i] = 0;
  }
  t_offset_oscillators = millis();
}


void update_phi_tegotae()
{
  for (int i=0; i<n_limb; i++){
    N_s[i] = ser_rx_buf.last_loadcell_data_float[2 + i * 3];   
  }
  unsigned long t_current = millis() - t_offset_oscillators;
  for (int i=0; i<n_limb; i++){

    if (tegotae_advanced){
      phi_dot[i] = advanced_tegotae_rule(i);
    }
    else
    {
      phi_dot[i] = simple_tegotae_rule(phi[i],N_s[i]);
    }
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
  float GRF_advanced_term = 0;
  float sigma_advanced;
  (direction_X) ? sigma_advanced=sigma_advanced_X : sigma_advanced=sigma_advanced_Y;
  for (int j=0; j<n_limb; j++){
    if (direction_X)
      GRF_advanced_term += inverse_map_X[i_limb][j]*N_s[j];
    else
      GRF_advanced_term += inverse_map_Y[i_limb][j]*N_s[j];
  }
  float phi_dot = 2 * pi * frequency + sigma_advanced * GRF_advanced_term * cos(phi[i_limb]);
  return phi_dot;
}

/// Trot

void init_phi_trot(){
  for (int i : {1,3}){
    phi[i] = pi;
  }
  t_offset_oscillators = millis();
}

void update_phi_trot()
{
  unsigned long t_current = millis() - t_offset_oscillators;
  for (int i=0; i<n_limb; i++){
    phi[i] = phi[i] + 2*pi*frequency * (t_current - t_last_phi_update) / 1000;
  }
  t_last_phi_update = t_current;
}

void send_phi_Serial3(){
  for (int i=0; i<n_limb; i++){
    Serial3.println(phi[i],4); //to show 4 digits after decimal point
  }  
  Serial3.println(t_last_phi_update);
}

void simple_send_pos_Serial3(){
  for (int i = 0; i < n_servos; i++)
  {
    last_motor_pos[i] = read_present_position(id[i]);
    last_motor_timestamp[i] = millis();
    Serial3.println(last_motor_pos[i]);
    Serial3.println(last_motor_timestamp[i]);
  }  
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

void print_inverse_map(){
  SerialUSB.println("Inverse map for advanced tegotae :");
  for (int i=0; i<n_limb; i++){ 
    for (int j=0; j<n_limb; j++){ 
      if (direction_X)
        SerialUSB.print(inverse_map_X[i][j],3);
      else
        SerialUSB.print(inverse_map_Y[i][j],3);
      SerialUSB.print("\t");
    }
  SerialUSB.println();
  }
  SerialUSB.println();
}

void print_locomotion_parameters(){
  SerialUSB.print("Frequency (in Hertz) : ");SerialUSB.println(frequency);
  SerialUSB.print("Amplitude class 1 (motors producing the movement) (in degrees) : ");SerialUSB.println(amplitude_class1);  
  SerialUSB.print("Amplitude class 2 (motors doing swing/stance cycle) (in degrees) : ");SerialUSB.println(amplitude_class2);  
  SerialUSB.print("Alpha factor for hip movement amplitude reduction in stance  : ");SerialUSB.println(alpha);    
  SerialUSB.print("Locomotion in direction : "); (direction_X) ? SerialUSB.println("X") : SerialUSB.println("Y");
  if (tegotae_advanced){
    SerialUSB.print("Sigma for advanced tegotae  : ");
    (direction_X) ? SerialUSB.println(sigma_advanced_X) : SerialUSB.println(sigma_advanced_Y);
    print_inverse_map();
  }
  else
  {
    SerialUSB.print("Sigma for simple tegotae  : ");SerialUSB.println(sigma_s);
  }
  if (flagTurning)
    SerialUSB.print("Turning mode activated");
}

