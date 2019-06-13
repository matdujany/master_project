void init_tegotae(){
  initialize_hardcoded_limbs();
  if (tegotae_advanced)
    initialize_inverse_map_advanced_tegotae();
  if (USE_FILTER_TEGOTAE)
    init_filter_tegotae();
  print_locomotion_parameters();
}

void read_Serial3_leg_changes(){
  while (Serial3.available()){
    char char_read = Serial3.read();
    if (char_read>47 && char_read<58){ //ASCII code : 0 = 48, 9 = 57
      uint8_t idx_temp = char_read - 48; 
      if (idx_temp < n_limb) {
        n_lc_amputated ++;
        idx_lc_amputated.push_back(idx_temp);
        SerialUSB.print("Removing limb "); SerialUSB.println(idx_temp);
      }
      else {
        SerialUSB.print("Invalid loadcell index, superior to n_limb, value :"); 
        SerialUSB.println(idx_temp);
      }
      //delay(5000);
    }
  }
}

void programmed_leg_amputations(unsigned long t_start_recording){
  while (millis()-t_start_recording>=time_changes_amputation[n_lc_amputated]*1000){
    idx_lc_amputated.push_back(idx_lc_amputated_programmed[n_lc_amputated]);
    SerialUSB.print("Amputation of idx lc ");
    SerialUSB.print(idx_lc_amputated_programmed[n_lc_amputated]);
    SerialUSB.print(" done at t=");
    SerialUSB.println((millis()-t_start_recording)/1000);
    n_lc_amputated++;
  }
}

void record_tegotae_leg_amputated_programmed(){
  init_tegotae();
  init_recording_locomotion();
  init_phi_tegotae();

  unsigned long recording_duration = time_changes_amputation[n_amputations_programmed]*1000;
  unsigned long t_start_recording = millis();
  programmed_leg_amputations(t_start_recording);
  while (millis()-t_start_recording<recording_duration)
  {
    unsigned long t_start_update_dc  = send_frame_and_update_sensors(1,0);
    for (uint8_t idx = 0; idx <  n_lc_amputated; idx ++){
      ser_rx_buf.last_loadcell_data_float[2+3*idx_lc_amputated[idx]] = 0;
    }
    send_phi_Serial3();
    update_phi_tegotae();
    send_command_limb_oscillators();
    programmed_leg_amputations(t_start_recording);
    //SerialUSB.print("Time elapsed for all operations of tegotae loop (in ms): ");SerialUSB.println(millis()-t_start_update_dc);
    while(millis()-t_start_update_dc<DELAY_UPDATE_DC_TEGOTAE);
  }

  SerialUSB.println("Tegotae recording over");
  SerialUSB.print("Nb end bytes sent: ");SerialUSB.println(nb_end_bytes_sent);
  SerialUSB.print("Nb frames found: ");SerialUSB.println(nb_frames_found);  
}




void record_tegotae_leg_amputated_Serial3(unsigned long recording_duration){
  init_tegotae();
  init_recording_locomotion();
  init_phi_tegotae();

  unsigned long t_start_recording = millis();

  while (millis()-t_start_recording<recording_duration)
  {
    unsigned long t_start_update_dc  = send_frame_and_update_sensors(1,0);
    for (uint8_t idx = 0; idx <  n_lc_amputated; idx ++){
      ser_rx_buf.last_loadcell_data_float[2+3*idx_lc_amputated[idx]] = 0;
    }
    send_phi_Serial3();
    update_phi_tegotae();
    send_command_limb_oscillators();
    read_Serial3_leg_changes();
    //SerialUSB.print("Time elapsed for all operations of tegotae loop (in ms): ");SerialUSB.println(millis()-t_start_update_dc);
    while(millis()-t_start_update_dc<DELAY_UPDATE_DC_TEGOTAE);
  }

  SerialUSB.println("Tegotae recording over");
  SerialUSB.print("Nb end bytes sent: ");SerialUSB.println(nb_end_bytes_sent);
  SerialUSB.print("Nb frames found: ");SerialUSB.println(nb_frames_found);  
}

void record_tegotae_custom_phi_init(unsigned long recording_duration){
  init_tegotae();
  init_recording_locomotion();
  init_phi_tegotae();

  //change_dir_mode_to_XY();

  unsigned long t_start_recording = millis();
  while (millis()-t_start_recording<recording_duration)
  {
    unsigned long t_start_update_dc  = send_frame_and_update_sensors(1,0);
    send_phi_and_pos_Serial3();
    update_phi_tegotae();
    send_command_limb_oscillators();
    //SerialUSB.print("Time elapsed for all operations of tegotae loop (in ms): ");SerialUSB.println(millis()-t_start_update_dc);
    while(millis()-t_start_update_dc<DELAY_UPDATE_DC_TEGOTAE);
  }

  SerialUSB.println("Tegotae recording over");
  SerialUSB.print("Nb end bytes sent: ");SerialUSB.println(nb_end_bytes_sent);
  SerialUSB.print("Nb frames found: ");SerialUSB.println(nb_frames_found);  
}

void record_tegotae_change_dir(unsigned long recording_duration){
  init_tegotae();
  init_recording_locomotion();
  init_phi_tegotae();

  //change_dir_mode_to_XY();

  unsigned long t_start_recording = millis();
  while (millis()-t_start_recording<recording_duration)
  {
    unsigned long t_start_update_dc  = send_frame_and_update_sensors(1,0);
    send_phi_and_pos_Serial3();
    update_phi_tegotae();
    send_command_limb_oscillators();
    //SerialUSB.print("Time elapsed for all operations of tegotae loop (in ms): ");SerialUSB.println(millis()-t_start_update_dc);
    
    if (SerialUSB.available()){
      while (SerialUSB.available()){
        delay(1);
        SerialUSB.read();
      }
      weight_straight = 1 - weight_straight;
      weight_yaw = 1 - weight_yaw;
    }   
    while(millis()-t_start_update_dc<DELAY_UPDATE_DC_TEGOTAE);
  }

  SerialUSB.println("Tegotae recording over");
  SerialUSB.print("Nb end bytes sent: ");SerialUSB.println(nb_end_bytes_sent);
  SerialUSB.print("Nb frames found: ");SerialUSB.println(nb_frames_found);  
}


void record_tegotae_changes(){
  uint8_t n_changes_frequency_done = 0;

  init_tegotae();
  init_recording_locomotion();

  init_phi_tegotae();
  frequency = frequency_recording[0];
  sigma_advanced = sigma_advanced_recording[0];
  unsigned long recording_duration = 1000*time_changes[n_changes_recording] - 50;
  send_command_limb_oscillators(); 
  unsigned long t_start_recording = millis();

  while (millis()-t_start_recording<recording_duration)
  {
    unsigned long t_start_update_dc  = send_frame_and_update_sensors(1,0);
    send_phi_and_pos_Serial3();
    update_phi_tegotae();
    send_command_limb_oscillators();
    if (millis()-t_start_recording>time_changes[n_changes_frequency_done]*1000){
      frequency = frequency_recording[n_changes_frequency_done+1];
      sigma_advanced = sigma_advanced_recording[n_changes_frequency_done+1];
      SerialUSB.print("Change done at t=");
      SerialUSB.println((millis()-t_start_recording)/1000);
      n_changes_frequency_done ++;
    }
    while(millis()-t_start_update_dc<DELAY_UPDATE_DC_TEGOTAE);
  }

  SerialUSB.println("Tegotae recording over");
  SerialUSB.print("Nb end bytes sent: ");SerialUSB.println(nb_end_bytes_sent);
  SerialUSB.print("Nb frames found: ");SerialUSB.println(nb_frames_found);  
}


void tegotae(){
  init_tegotae();
  init_phi_tegotae();
  send_command_limb_oscillators(); 
  print_phi_info();
  while (true){
    unsigned long t_start_update_dc  = send_frame_and_update_sensors(1,0);
    update_phi_tegotae();
    send_command_limb_oscillators();
    print_phi_info();
    SerialUSB.print("Time elapsed for all operations of tegotae loop (in ms): ");SerialUSB.println(millis()-t_start_update_dc);
    while(millis()-t_start_update_dc<DELAY_UPDATE_DC_TEGOTAE);
  }
}

void tegotae_bluetooth(){
  init_tegotae();
  init_phi_tegotae();
  setup_serial_bluetooth();

  //change_dir_mode_to_XY();
 
  weight_straight = 0;
  weight_yaw = 0;
  weight_X = 0;
  weight_Y = 0;

  print_phi_info();
  send_command_limb_oscillators();
  SerialUSB.println("waiting for bluetooth connection ...");
  while (!Serial3.available());
  SerialUSB.println("Bluetooth connection found !");
  init_t_offset_oscillators();
  while (true){
    unsigned long t_start_update_dc  = send_frame_and_update_sensors(1,0);  //the order of the 2 lines here matter a locomotion
    
    if (locomotion_2_joysticks)
      serial_read_bluetooth_2joysticks_main();
    else
      serial_read_bluetooth_main();

    update_phi_tegotae();
    send_command_limb_oscillators();
    print_phi_info();
    

    while(millis()-t_start_update_dc<DELAY_UPDATE_DC_TEGOTAE);
  }
}

/// Bluetooth commands functions

void update_locomotion_weights_2(uint8_t radiusL, uint8_t angleL, uint8_t radiusR, uint8_t angleR){
  float angleR_rad = ((float)angleR)/36 * (2*3.1415);
  float weight_X_new = ((float)radiusR/10) * cos(angleR_rad);
  float weight_Y_new = -((float)radiusR/10) * sin(angleR_rad);
  
  float angleL_rad = ((float)angleL)/36 * (2*3.1415);
  float weight_yaw_new = -sin(angleL_rad);
  if (angleL == 18)
    weight_yaw_new = 0;

  weight_X = smooth_weight(weight_X_new, weight_X);
  weight_Y = smooth_weight(weight_Y_new, weight_Y);
  weight_yaw = smooth_weight(weight_yaw_new,weight_yaw);
}

void print_locomotion_weights_2(){
  SerialUSB.print("Locomotion weights : X "); SerialUSB.print(weight_X,2);
  SerialUSB.print(", Y "); SerialUSB.print(weight_Y,2);
  SerialUSB.print(", Yaw "); SerialUSB.println(weight_yaw,2);
  SerialUSB.println();
}


//joyX and joyY are between -100 and 100
void update_locomotion_weights(int8_t joyX, int8_t joyY){
  float joyXf = float(joyX)/100.0;
  float joyYf = float(joyY)/100.0;
  float norm = sqrt(joyXf*joyXf + joyYf*joyYf);
  //the joystick in the app is a square and not a circle, we add a saturation if outside of the cercle
  if (norm > 1){
    joyXf = joyXf/norm;
    joyYf = joyYf/norm;
  }

  /*
  float weight_straight_new = joyYf;
  float weight_yaw_new = joyXf;
  //smoothing
  if (abs(weight_straight_new - weight_straight)>threshold_max_variation){
    weight_straight_new = weight_straight + threshold_max_variation*get_sign(weight_straight_new - weight_straight);
  }
  if (abs(weight_yaw_new - weight_yaw)>threshold_max_variation){
    weight_yaw_new = weight_yaw + threshold_max_variation*get_sign(weight_yaw_new - weight_yaw);
  }
  */

  weight_straight = smooth_weight(joyYf, weight_straight);
  weight_yaw = smooth_weight(joyXf,weight_yaw);

}

float smooth_weight(float weight_new, float weight_old){
  float threshold_max_variation = 0.05;
   if (abs(weight_new - weight_old)>threshold_max_variation){
    weight_new = weight_old + threshold_max_variation*get_sign(weight_new - weight_old);
  } 
  return weight_new;
}

void increase_freq_bluetooth() {
  float frequency_new = frequency + 0.1;
  if (frequency_new > 1)
    frequency_new = 1;
  float sigma_advanced_new = frequency_new*sigma_advanced/frequency;

  frequency = frequency_new;
  sigma_advanced = sigma_advanced_new;
}

void decrease_freq_bluetooth() {
  frequency = frequency - 0.1;
  if (frequency < 0.1)
    frequency = 0.1;
}

//change dir is set to true for class 2 if - hip direction produces lift off
//change dir is set to true for class 1 if - knee direction pushes backwards

//hip first, knee after, in loadcell order

/// LOADING FROM HARDCODED PARAMETERS

void fill_limbs_array( std::vector<std::vector<uint8_t>> limbs_hardcoded) {
  limbs.resize(n_limb);
  for (int i=0; i<n_limb; i++){
    limbs[i].resize(2);
    for (int j=0; j<2; j++){
      limbs[i][j] = limbs_hardcoded[i][j];
    }
  }
}

void fill_changeDirs_array( std::vector<std::vector<bool>> changeDirs_hardcoded){
  changeDirs.resize(n_limb);
  for (int i=0; i<n_limb; i++){
    for (int j=0; j<2; j++){
      changeDirs[i].resize(2);
      changeDirs[i][j] = changeDirs_hardcoded[i][j];
    }
  }
}

void fill_changeDirs_Yaw_array( std::vector<bool> changeDirs_Yaw_hardcoded){
  changeDirs_Yaw.resize(n_limb);
  for (int i=0; i<n_limb; i++){
    changeDirs_Yaw[i] = changeDirs_Yaw_hardcoded[i];
  }
}

void fill_changeDirs_Y_array( std::vector<bool> changeDirs_Y_hardcoded){
  changeDirs_Y.resize(n_limb);
  for (int i=0; i<n_limb; i++){
    changeDirs_Y[i] = changeDirs_Y_hardcoded[i];
  }
}

void fill_inverse_map_array( std::vector<std::vector<float>> inverse_map_hardcoded){
  inverse_map.resize(n_limb);
  for (int i=0; i<n_limb; i++){
    inverse_map[i].resize(n_limb);
    for (int j=0; j<n_limb; j++){
      inverse_map[i][j] = inverse_map_hardcoded[i][j];
    }
  }
}

void fill_scaling_amp_class1(float scaling_amp_class1_forward_hardcoded[], float scaling_amp_class1_yaw_hardcoded[]){
  scaling_amp_class1_forward.resize(n_limb);
  scaling_amp_class1_yaw.resize(n_limb);
  for (int i=0; i<n_limb; i++){
    scaling_amp_class1_forward[i] = scaling_amp_class1_forward_hardcoded[i];
    scaling_amp_class1_yaw[i] = scaling_amp_class1_yaw_hardcoded[i];
  } 
}

void fill_scaling_amp_class1_Y(float scaling_amp_class1_Y_hardcoded[]){
  scaling_amp_class1_Y.resize(n_limb);
  for (int i=0; i<n_limb; i++){
    scaling_amp_class1_Y[i] = scaling_amp_class1_Y_hardcoded[i];
  } 
}

void initialize_scaling_amp_class1(){
  scaling_amp_class1_forward.resize(n_limb);
  scaling_amp_class1_yaw.resize(n_limb);
  for (int i=0; i<n_limb; i++){
    scaling_amp_class1_forward[i] = 1;
    scaling_amp_class1_yaw[i] = 1;
  }
  if (MAP_USED == 123){
    fill_scaling_amp_class1(scaling_amp_class1_forward_123, scaling_amp_class1_yaw_123);
  }

  if (MAP_USED == 127){
    fill_scaling_amp_class1(scaling_amp_class1_forward_127, scaling_amp_class1_yaw_127);
    fill_scaling_amp_class1_Y(scaling_amp_class1_Y_127);
  }

}

void change_dir_mode_to_XY(){
  if (MAP_USED == 123){
    fill_scaling_amp_class1(scaling_amp_class1_forward_123, scaling_amp_class1_Y_123);
    fill_changeDirs_Yaw_array(changeDirs_Y_4_weird);
  }
  if (MAP_USED == 127){
    fill_scaling_amp_class1(scaling_amp_class1_forward_127, scaling_amp_class1_Y_127);
    fill_changeDirs_Yaw_array(changeDirs_Y_4_weird);
  }

}

void fill_neutral_pos(uint16_t neutral_pos_hardcoded[]){
  
  for (int i=0; i<n_servos; i++){
    neutral_pos[i] = neutral_pos_hardcoded[i];
  }
}

void initialize_hardcoded_limbs(){

  if (MAP_USED == 104) {
    n_limb = 4;
    fill_neutral_pos(neutral_pos_104);
    fill_limbs_array(limbs_X_4);
    fill_changeDirs_array(changeDirs_X_4);
    fill_changeDirs_Yaw_array(changeDirs_X_Yaw_4);
  }

  if (MAP_USED == 105) {
    n_limb = 4;
    fill_neutral_pos(neutral_pos_105);
    if (bool_Y_105){
      fill_limbs_array(limbs_Y_4);
      fill_changeDirs_array(changeDirs_Y_4);
      fill_changeDirs_Yaw_array(changeDirs_Y_Yaw_4);
    }
    else {
      fill_limbs_array(limbs_X_4);
      fill_changeDirs_array(changeDirs_X_4);
      fill_changeDirs_Yaw_array(changeDirs_X_Yaw_4);
    }
  }
  
  if (MAP_USED == 108) {
    n_limb = 6;
    fill_neutral_pos(neutral_pos_108);
    fill_limbs_array(limbs_X_6);
    fill_changeDirs_array(changeDirs_X_6);
    fill_changeDirs_Yaw_array(changeDirs_X_Yaw_6);
  }

  if (MAP_USED == 110) {
    n_limb = 6;
    fill_neutral_pos(neutral_pos_110);
    fill_limbs_array(limbs_X_6);
    fill_changeDirs_array(changeDirs_X_6);
    fill_changeDirs_Yaw_array(changeDirs_X_Yaw_6);
  } 

  if (MAP_USED == 115) {
    n_limb = 8;
    fill_neutral_pos(neutral_pos_115);
    fill_limbs_array(limbs_X_8);
    fill_changeDirs_array(changeDirs_X_8);
    fill_changeDirs_Yaw_array(changeDirs_X_Yaw_8);
  } 

  if (MAP_USED == 123) {
    n_limb = 4;
    fill_neutral_pos(neutral_pos_123);
    fill_limbs_array(limbs_X_4_weird);
    fill_changeDirs_array(changeDirs_X_4_weird);
    fill_changeDirs_Yaw_array(changeDirs_Yaw_4_weird);
  } 

  if (MAP_USED == 127) {
    n_limb = 4;
    fill_neutral_pos(neutral_pos_127);
    fill_limbs_array(limbs_X_4_weird);
    fill_changeDirs_array(changeDirs_X_4_weird);
    fill_changeDirs_Yaw_array(changeDirs_Yaw_4_weird);
    fill_changeDirs_Y_array(changeDirs_Y_4_weird);

  } 

  init_offset_class1();
  initialize_scaling_amp_class1();

  SerialUSB.println("Initialize hardcoded limbs success !");
}

void initialize_inverse_map_advanced_tegotae(){
  if (MAP_USED==104)
  {
    sigma_advanced = sigma_advanced_X_104;
    fill_inverse_map_array(inverse_map_X_104);
  }

  if (MAP_USED==105)
  {
    if (bool_Y_105){
    sigma_advanced = sigma_advanced_Y_105;
    fill_inverse_map_array(inverse_map_Y_105);
    }
    else{
    sigma_advanced = sigma_advanced_X_105;
    fill_inverse_map_array(inverse_map_X_105);
    }
  }

  if (MAP_USED==108)
  {
    sigma_advanced = sigma_advanced_X_108;
    fill_inverse_map_array(inverse_map_X_108);
  }

  if (MAP_USED==110)
  {
    sigma_advanced = sigma_advanced_X_110;
    fill_inverse_map_array(inverse_map_X_110);
  }

  if (MAP_USED==115)
  {
    sigma_advanced = sigma_advanced_X_115;
    fill_inverse_map_array(inverse_map_X_115);
  }

  if (MAP_USED==123)
  {
    sigma_advanced = sigma_advanced_X_123;
    fill_inverse_map_array(inverse_map_X_123);
  }

  if (MAP_USED==127)
  {
    sigma_advanced = sigma_advanced_X_127;
    fill_inverse_map_array(inverse_map_X_127);
  }
}

/*
void initialize_hardcoded_limbs(){
  SerialUSB.println("Entering Initialize hardcoded limbs");

  if (MAP_USED < 89) {
    n_limb = 4;
    if (direction_X){
      fill_limbs_array(limbs_X);
      fill_changeDirs_array(changeDirs_X);
    }
    if (direction_Y){
      fill_limbs_array(limbs_Y);
      fill_changeDirs_array(changeDirs_Y);   
    }
    if (direction_Yaw){
      fill_limbs_array(limbs_Yaw);
      fill_changeDirs_array(changeDirs_Yaw);    
    }
  }
  if(MAP_USED == 89){
    n_limb = 6;
    if (direction_X){
      fill_limbs_array(limbs_X_6legs);
      fill_changeDirs_array(changeDirs_X_6legs);
    }
  }
  if(MAP_USED == 94){
    n_limb = 8;
    if (direction_X){
      fill_limbs_array(limbs_X_8legs);
      fill_changeDirs_array(changeDirs_X_8legs);
    }
  }
  
  init_offset_class1();

  SerialUSB.println("Initialize hardcoded limbs success !");
}

void initialize_inverse_map_advanced_tegotae(){
  if (MAP_USED==86)
  {
    if (direction_X){
      //sigma_advanced = sigma_advanced_X_86;
      fill_inverse_map_array(inverse_map_X_86);
    }
    if (direction_Y){
      //sigma_advanced = sigma_advanced_Y_86;
      fill_inverse_map_array(inverse_map_Y_86);
    }
  }
  if (MAP_USED==87)
  {
    if (direction_X){
      //sigma_advanced = sigma_advanced_X_87;
      fill_inverse_map_array(inverse_map_X_87);
    }
    if (direction_Y){
      //sigma_advanced = sigma_advanced_Y_87;
      fill_inverse_map_array(inverse_map_Y_87);
    }
  }
  if (MAP_USED==88)
  {
    if (direction_X){
      //sigma_advanced = sigma_advanced_X_88;
      fill_inverse_map_array(inverse_map_X_88);
    }
    if (direction_Y){
      //sigma_advanced = sigma_advanced_Y_88;
      fill_inverse_map_array(inverse_map_Y_88);
    }
    if (direction_Yaw){
      //sigma_advanced = sigma_advanced_Yaw_88;
      fill_inverse_map_array(inverse_map_Yaw_88);
    }
  }
  if (MAP_USED==89)
  {
    if (direction_X){
      //sigma_advanced = sigma_advanced_X_89;
      fill_inverse_map_array(inverse_map_X_89);
    }
  }
  if (MAP_USED==94)
  {
    if (direction_X){
      sigma_advanced = sigma_advanced_X_94;
      fill_inverse_map_array(inverse_map_X_94);
    }
  }      
}
*/


///Oscillators


void init_offset_class1(){
  for (int i=0; i<n_limb; i++){
    offset_class1[i]=pi/2;
  }   
}

void send_command_limb_oscillators(){
  uint8_t  servo_id_list[n_servos];
  int16_t goal_position_yaw;

  for (int i=0; i<n_limb; i++){
    //class 1 first : doing movement
    servo_id_list[2*i] = id[limbs[i][0]];
    if (locomotion_2_joysticks){
      int16_t goal_position_X = phase2pos_Class1(phi[i]+offset_class1[i], changeDirs[i][0], scaling_amp_class1_forward[i]);
      int16_t goal_position_Y = phase2pos_Class1(phi[i]+offset_class1[i], changeDirs_Y[i], scaling_amp_class1_Y[i]);
      goal_position_yaw = phase2pos_Class1(phi[i]+offset_class1[i], changeDirs_Yaw[i], scaling_amp_class1_yaw[i]);
      goal_positions_tegotae[2*i] = neutral_pos[limbs[i][0]] + (weight_X * goal_position_X + weight_Y * goal_position_Y + weight_yaw * goal_position_yaw);

    }
    else {
      int16_t goal_position_straight = phase2pos_Class1(phi[i]+offset_class1[i], changeDirs[i][0], scaling_amp_class1_forward[i]);
      goal_position_yaw = phase2pos_Class1(phi[i]+offset_class1[i], changeDirs_Yaw[i], scaling_amp_class1_yaw[i]);
      goal_positions_tegotae[2*i] = neutral_pos[limbs[i][0]] + (weight_straight * goal_position_straight + weight_yaw * goal_position_yaw);
    }

    //class 2 : stance swing
    servo_id_list[2*i+1] = id[limbs[i][1]];
    goal_positions_tegotae[2*i+1] = neutral_pos[limbs[i][1]] + phase2pos_Class2(phi[i], changeDirs[i][1]);
  }
  //print_goal_positions_tegotae();
  syncWrite_position_n_servos(n_servos, servo_id_list, goal_positions_tegotae);
}


int16_t phase2pos_oscillator(float phase, float amp_deg, boolean changeDir){
  int16_t pos;
  if (changeDir)
    pos = (int16_t)( -1 * (float)(3.413*amp_deg*sin(phase)));
  else
    pos = (int16_t)((float)(3.413*amp_deg*sin(phase)));
  return pos;
}

/*
int16_t phase2pos_wrapper(float phase, boolean isClass2, boolean changeDir, float scaling_amp_class1){
  if (isClass2){
    if (sin(phase) > 0) // swing
      return phase2pos_oscillator(phase, amplitude_class2, changeDir);
    else // reduced amplitude in stance for class 2
      return phase2pos_oscillator(phase, alpha*amplitude_class2, changeDir);
  }
  else{
    return phase2pos_oscillator(phase, scaling_amp_class1*amplitude_class1, changeDir);
  }
}
*/

int16_t phase2pos_Class2(float phase, boolean changeDir){
  if (sin(phase) > 0) // swing
    return phase2pos_oscillator(phase, amplitude_class2, changeDir);
  else // reduced amplitude in stance for class 2
    return phase2pos_oscillator(phase, alpha*amplitude_class2, changeDir);
}

int16_t phase2pos_Class1(float phase, boolean changeDir, float scaling_amp_class1){
    return phase2pos_oscillator(phase, scaling_amp_class1*amplitude_class1, changeDir);
}


///Tegotae

void init_phi_tegotae(){
  //
  for (int i=0; i<n_limb; i++){
    phi[i] = phi_init[i];
  }
  init_t_offset_oscillators();
}

void init_t_offset_oscillators(){
    t_offset_oscillators = millis();
}

void init_filter_tegotae(){
  buffer_filter_tegotae.head = 0;
  for (int k=0; k<FILTER_SIZE_TEGOTAE; k++){
    for (int i=0; i<n_limb; i++){
      buffer_filter_tegotae.N_s[k][i] = 0;
    }
  }
}

void update_filter_tegotae(){
  for (int i=0;i<n_limb;i++){
    buffer_filter_tegotae.N_s[buffer_filter_tegotae.head][i]=N_s[i];
  }
  buffer_filter_tegotae.head = (buffer_filter_tegotae.head+1)%(FILTER_SIZE_TEGOTAE);
}



void update_phi_tegotae()
{
  if (USE_FILTER_TEGOTAE)
    update_filter_tegotae();
  for (int i=0; i<n_limb; i++){
    N_s[i] = ser_rx_buf.last_loadcell_data_float[2 + i * 3]; //support is 3rd channel of loadcells
    N_p[i] = ser_rx_buf.last_loadcell_data_float[1 + i * 3]; //propulsion is Y channel of loadcells, (could be determined with the loadcell connection weights) 
  }
  unsigned long t_current = millis() - t_offset_oscillators;
  for (int i=0; i<n_limb; i++){

    if (tegotae_advanced){
      phi_dot[i] = advanced_tegotae_rule(i);
    }
    else
    {
      phi_dot[i] = simple_tegotae_rule(phi[i],N_s[i],N_p[i]);
    }

    //increase in phase only if the locomotion weights are non 0
    if (locomotion_2_joysticks)
    {
      if(weight_X*weight_X + weight_Y*weight_Y + weight_yaw*weight_yaw > 0)
        phi[i] = phi[i] + phi_dot[i] * (t_current - t_last_phi_update) / 1000;
    }
    else
    {
      if(weight_straight*weight_straight + weight_yaw*weight_yaw > 0)
        phi[i] = phi[i] + phi_dot[i] * (t_current - t_last_phi_update) / 1000;
    }
    
    if (phi[i]>2*pi)
      phi[i] = phi[i] - 2*pi;
    
  }
  t_last_phi_update = t_current;
}


float simple_tegotae_rule(float phase, float ground_reaction_force, float propulsion_force){
  float phi_dot = 2 * pi * frequency - sigma_s * ground_reaction_force * cos(phase);
  if (tegotae_propulsion)
  {
    phi_dot += - sigma_p * propulsion_force * cos(phase);
  }

  return phi_dot;
}

float advanced_tegotae_rule(uint8_t i_limb){
  float GRF_advanced_term = 0;
  for (int j=0; j<n_limb; j++){

    float grf_under_limb = N_s[j];

    if (USE_FILTER_TEGOTAE){
      for (int k=0; k<FILTER_SIZE_TEGOTAE; k++)
      {
        grf_under_limb += buffer_filter_tegotae.N_s[k][j];
      }
      grf_under_limb = grf_under_limb/(FILTER_SIZE_TEGOTAE+1);
    }
    //SerialUSB.print("Limb ");SerialUSB.print(j);
    //SerialUSB.print(" grf filtered :"); SerialUSB.println(grf_under_limb,4);

    GRF_advanced_term += inverse_map[i_limb][j]*grf_under_limb;
  }

  float phi_dot = 2 * pi * frequency + sigma_advanced * GRF_advanced_term * cos(phi[i_limb]);
  if (tegotae_propulsion)
  {
    phi_dot += - sigma_p * N_p[i_limb] * cos(phi[i_limb]);
  }

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

void hardcoded_trot(){
  initialize_hardcoded_limbs();
  init_phi_trot();
  while (true){
    update_phi_trot();
    send_command_limb_oscillators();
  }
}


void record_hardcoded_trot(int recording_duration){
  print_locomotion_parameters();
  init_recording_locomotion();
  initialize_hardcoded_limbs();

  init_phi_trot();
  send_command_limb_oscillators();

  unsigned long t_start_recording = millis();
  while (millis()-t_start_recording<recording_duration*1000){
    unsigned long t_start_update_dc  = send_frame_and_update_sensors(1,0);
    send_phi_and_pos_Serial3();
    update_phi_trot();
    send_command_limb_oscillators();
    while(millis()-t_start_update_dc<DELAY_UPDATE_DC_TEGOTAE);
  }
  SerialUSB.println("Trot recording over");
  SerialUSB.print("Nb end bytes sent: ");SerialUSB.println(nb_end_bytes_sent);
  SerialUSB.print("Nb frames found: ");SerialUSB.println(nb_frames_found);
}

// For Recordings

void init_recording_locomotion(){
  Serial3.begin(2000000);   //for fast Matlab writing 
  while (Serial3.available()) Serial3.read();
  switch_frame_recording_mode();
  SerialUSB.print("Waiting for any input from Serial USB console to start recording...");
  while (!SerialUSB.available());  
  while (SerialUSB.available()) 
   SerialUSB.read();
  SerialUSB.println("recording started !");
  SerialUSB.flush();
}

void send_phi_and_pos_Serial3(){
  send_phi_Serial3();
  simple_send_pos_Serial3();
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

/// Printing on Console

void print_phi_info(){
  SerialUSB.print("Phase of the limbs :" );
  for (int i=0; i<n_limb; i++){ 
    SerialUSB.print(phi[i]);
    SerialUSB.print("\t");
  }
  SerialUSB.print(", Timestamp update "); SerialUSB.println(t_last_phi_update);
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
  SerialUSB.print("GRFs (in LC=limb order) :" );
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
      SerialUSB.print(inverse_map[i][j],3);
      SerialUSB.print("\t");
    }
  SerialUSB.println();
  }
  SerialUSB.println();
}

void print_limbs(){
  SerialUSB.println("Limbs for advanced tegotae :");
  for (int i=0; i<n_limb; i++){ 
    for (int j=0; j<2; j++){ 
      SerialUSB.print(limbs[i][j]);
      SerialUSB.print("\t");
    }
  SerialUSB.println();
  }
  SerialUSB.println();
}

void print_changeDirs(){
  SerialUSB.println("changeDirs for advanced tegotae :");
  for (int i=0; i<n_limb; i++){ 
    for (int j=0; j<2; j++){ 
      SerialUSB.print(changeDirs[i][j]);
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
  //SerialUSB.print("Locomotion in direction : "); 
  //(direction_X) ? SerialUSB.println("X") : 0;
  //(direction_Y) ? SerialUSB.println("Y") : 0;
  if (tegotae_advanced){
    if (USE_FILTER_TEGOTAE){
      SerialUSB.print("Using filter of size ");
      SerialUSB.print(FILTER_SIZE_TEGOTAE); SerialUSB.println(" for Tegotae.");
    }
    SerialUSB.print("Parameters learned from twitching record ID "); SerialUSB.println(MAP_USED);
    SerialUSB.print("Sigma for advanced tegotae  : "); SerialUSB.println(sigma_advanced,5);
    print_inverse_map();
    print_limbs();
    print_changeDirs();
  }
  else
  {
    SerialUSB.print("Sigma for simple tegotae  : ");SerialUSB.println(sigma_s);
  }
  if (tegotae_propulsion){
    SerialUSB.print("Using propulsion term in Tegoate rule, sigma_p :"); SerialUSB.println(sigma_p);
  }
}

