void init_tegotae(){
  initialize_hardcoded_limbs();
  if (tegotae_advanced)
    initialize_inverse_map_advanced_tegotae();
  if (USE_FILTER_TEGOTAE)
    init_filter_tegotae();
  print_locomotion_parameters();
}

void record_tegotae(unsigned long recording_duration){
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

void tegotae_bluetooth(){
  init_tegotae();
  init_phi_tegotae();
  setup_serial_bluetooth();

  //change_dir_mode_to_XY();//useful for starfish if using only one joystick and desired locomotion is XY instead of X Yaw.
 
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
    
    if (locomotion_bluetoooth_2_joysticks)
      serial_read_bluetooth_2joysticks_main();
    else
      serial_read_bluetooth_main();

    update_phi_tegotae();
    send_command_limb_oscillators();
    print_phi_info();
    print_Tegotae_parameters_bluetooth();

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
  if (frequency_new > 1.5)
    frequency_new = 1;
  //float sigma_advanced_new = frequency_new*sigma_advanced/frequency;

  frequency = frequency_new;
  //sigma_advanced = sigma_advanced_new;
}

void decrease_freq_bluetooth() {
  frequency = frequency - 0.1;
}

void increase_sigma_adv_bluetooth() {
  sigma_advanced += 0.2;
}

void decrease_sigma_adv_bluetooth() {
  sigma_advanced -= 0.2;
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
  #if (MAP_USED == 127)
    fill_scaling_amp_class1(scaling_amp_class1_forward_127, scaling_amp_class1_yaw_127);
    fill_scaling_amp_class1_Y(scaling_amp_class1_Y_127);
  #endif

  #if (MAP_USED == 134)
    fill_scaling_amp_class1(scaling_amp_class1_forward_134, scaling_amp_class1_yaw_134);
    fill_scaling_amp_class1_Y(scaling_amp_class1_Y_134);
  #endif

  #if (MAP_USED == 204)
    fill_scaling_amp_class1(scaling_amp_class1_forward_204, scaling_amp_class1_yaw_204);
    fill_scaling_amp_class1_Y(scaling_amp_class1_Y_204);
  #endif

}

void change_dir_mode_to_XY(){
  #if (MAP_USED == 127)
    fill_scaling_amp_class1(scaling_amp_class1_forward_127, scaling_amp_class1_Y_127);
    fill_changeDirs_Yaw_array(changeDirs_Y_s_quad);
  #endif

  #if (MAP_USED == 134)
    fill_scaling_amp_class1(scaling_amp_class1_forward_134, scaling_amp_class1_Y_134);
    fill_changeDirs_Yaw_array(changeDirs_Y_s_hex);
  #endif

}

void fill_neutral_pos(uint16_t neutral_pos_hardcoded[]){
  
  for (int i=0; i<n_servos; i++){
    neutral_pos[i] = neutral_pos_hardcoded[i];
  }
}

void initialize_hardcoded_limbs(){

  #if (MAP_USED == 105)
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
  #endif
  
  #if (MAP_USED == 110) 
    n_limb = 6;
    fill_neutral_pos(neutral_pos_110);
    fill_limbs_array(limbs_X_6);
    fill_changeDirs_array(changeDirs_X_6);
    fill_changeDirs_Yaw_array(changeDirs_X_Yaw_6);
  #endif 

  #if (MAP_USED == 115)
    n_limb = 8;
    fill_neutral_pos(neutral_pos_115);
    fill_limbs_array(limbs_X_8);
    fill_changeDirs_array(changeDirs_X_8);
    fill_changeDirs_Yaw_array(changeDirs_X_Yaw_8);
  #endif 

  #if (MAP_USED == 127)
    n_limb = 4;
    fill_neutral_pos(neutral_pos_127);
    fill_limbs_array(limbs_X_s_quad);
    fill_changeDirs_array(changeDirs_X_s_quad);
    fill_changeDirs_Yaw_array(changeDirs_Yaw_s_quad);
    fill_changeDirs_Y_array(changeDirs_Y_s_quad);
  #endif

  #if (MAP_USED == 134)
    n_limb = 6;
    fill_neutral_pos(neutral_pos_134);
    fill_limbs_array(limbs_X_s_hex);
    fill_changeDirs_array(changeDirs_X_s_hex);
    fill_changeDirs_Yaw_array(changeDirs_Yaw_s_hex);
    fill_changeDirs_Y_array(changeDirs_Y_s_hex);
  #endif 

  #if (MAP_USED == 204) 
    n_limb = 6;
    fill_neutral_pos(neutral_pos_204);
    fill_limbs_array(limbs_X_s_hex_2);
    fill_changeDirs_array(changeDirs_X_s_hex_2);
    fill_changeDirs_Yaw_array(changeDirs_Yaw_s_hex_2);
    fill_changeDirs_Y_array(changeDirs_s_Y_hex_2);
  #endif 

  #if (MAP_USED == 210) 
    n_limb = 6;
    fill_neutral_pos(neutral_pos_210);
    fill_limbs_array(limbs_X_hex_2);
    fill_changeDirs_array(changeDirs_X_hex_2);
    fill_changeDirs_Yaw_array(changeDirs_Yaw_hex_2);
  #endif 

  #if (MAP_USED == 220) 
    n_limb = 8;
    fill_neutral_pos(neutral_pos_220);
    fill_limbs_array(limbs_X_oct_2);
    fill_changeDirs_array(changeDirs_X_oct_2);
    fill_changeDirs_Yaw_array(changeDirs_Yaw_oct_2);
  #endif 

  init_offset_class1();
  initialize_scaling_amp_class1();

  SerialUSB.println("Initialize hardcoded limbs success !");
}

void initialize_inverse_map_advanced_tegotae(){

  #if (MAP_USED==105)
    if (bool_Y_105)
    {
      sigma_advanced = sigma_advanced_Y_105;
      fill_inverse_map_array(inverse_map_Y_105);
    }
    else
    {
      sigma_advanced = sigma_advanced_X_105;
      fill_inverse_map_array(inverse_map_X_105);
    }
  #endif

  #if (MAP_USED==110)
    sigma_advanced = sigma_advanced_X_110;
    fill_inverse_map_array(inverse_map_X_110);
  #endif

  #if (MAP_USED==115)
    sigma_advanced = sigma_advanced_X_115;
    fill_inverse_map_array(inverse_map_X_115);
  #endif


  #if (MAP_USED==127)
    sigma_advanced = sigma_advanced_X_127;
    fill_inverse_map_array(inverse_map_X_127);
  #endif

  #if (MAP_USED==134)
    sigma_advanced = sigma_advanced_X_134;
    fill_inverse_map_array(inverse_map_X_134);
  #endif


  #if (MAP_USED==204)
    sigma_advanced = sigma_advanced_X_204;
    fill_inverse_map_array(inverse_map_X_204);
  #endif 

  #if (MAP_USED==210)
    sigma_advanced = sigma_advanced_X_210;
    fill_inverse_map_array(inverse_map_X_210);
  #endif 

  #if (MAP_USED==220)
    sigma_advanced = sigma_advanced_X_220;
    fill_inverse_map_array(inverse_map_X_220);
  #endif 
}


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
    if (locomotion_bluetoooth_2_joysticks){
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

int16_t phase2pos_oscillator(float phase, float amp_deg, boolean changeDir){
  int16_t pos;
  if (changeDir)
    pos = (int16_t)( -1 * (float)(3.413*amp_deg*sin(phase)));
  else
    pos = (int16_t)((float)(3.413*amp_deg*sin(phase)));
  return pos;
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
    //we use the old values before writing the new ones to compute the drivatives
    if (USE_DERIVATIVE_TEGOTAE){
      float delta_N_s;
      delta_N_s = ser_rx_buf.last_loadcell_data_float[2 + i * 3] - N_s[i];
      float delta_time = (millis() - timestamp_lc_tegotae);
      N_s_derivative[i] = 1000.0/delta_time * delta_N_s;
      /*
      SerialUSB.print("Limb "); SerialUSB.print(i);
      SerialUSB.print(" , GRF "); SerialUSB.print(ser_rx_buf.last_loadcell_data_float[2 + i * 3]);
      SerialUSB.print(" , delta GRF "); SerialUSB.print(delta_N_s);
      SerialUSB.print(" , delta time (ms) "); SerialUSB.print(delta_time);
      SerialUSB.print(" , derivative "); SerialUSB.println(N_s_derivative[i]);
      */
    }
    N_s[i] = ser_rx_buf.last_loadcell_data_float[2 + i * 3]; //support is 3rd channel of loadcells
    N_p[i] = ser_rx_buf.last_loadcell_data_float[1 + i * 3]; //propulsion is Y channel of loadcells, (could be determined with the loadcell connection weights) 
    timestamp_lc_tegotae = millis();
  }

  if (complete_formula_Nref){
    for (int i=0; i<n_limb; i++){
      N_s_ref_corrected[i] = N_s[i] - N_ref_func(i,phi[i]);
      /*
      SerialUSB.print("Limb "); SerialUSB.print(i+1); 
      SerialUSB.print(", Phase : "); SerialUSB.print(phi[i]); 
      SerialUSB.print(", Nref : "); SerialUSB.print(N_ref_func(i,phi[i]));
      SerialUSB.print(", Nref der : "); SerialUSB.println(N_ref_der(i,phi[i]));
       */
    }
  }

  unsigned long t_current = millis() - t_offset_oscillators;

  for (int i=0; i<n_limb; i++)
  {
    phi_dot[i] = 2*pi*frequency;

    //getting phi_dot cprrections
    if (tegotae_advanced){
      if (USE_DERIVATIVE_TEGOTAE)
        phi_dot[i] += advanced_tegotae_rule_derivative(i);
      else
        phi_dot[i] += advanced_tegotae_rule(i);
    }
    if (tegotae_simple)
    {
      phi_dot[i] += simple_tegotae_rule(phi[i],N_s[i],N_p[i],i);
    }

    if (complete_formula){
      phi_dot[i] += complete_rule(i);
    }

    if (complete_formula_Nref){
      phi_dot[i] += complete_rule_Nref(i);
    }

    //a trick so that the delta phases are not modified when i lift the robot to recenter it
    if (total_GRF(N_s,n_limb) < 5)
      phi_dot[i] = 2*pi*frequency;

    //increase in phase only if the locomotion weights are non 0
    if (locomotion_bluetoooth_2_joysticks)
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


float simple_tegotae_rule(float phase, float ground_reaction_force, float propulsion_force, uint8_t i_limb){
  float simple_tegotae_term = - sigma_s * ground_reaction_force * cos(phase);
  if (tegotae_propulsion_local)
  {
    simple_tegotae_term += - sigma_p * propulsion_force * cos(phase);
  }
  return simple_tegotae_term;
}


float advanced_tegotae_rule_derivative(uint8_t i_limb){
  float advanced_tegotae_derivative_term = 0.1 * sigma_advanced * vector_sum(inverse_map[i_limb],N_s_derivative,n_limb);
  return advanced_tegotae_derivative_term;
}

float advanced_tegotae_rule(uint8_t i_limb){
  float advanced_tegotae_term;
  if (USE_FILTER_TEGOTAE){
    for (int j=0; j<n_limb; j++)
    {
    N_s_filtered[j] = 0;
    for (int k=0; k<FILTER_SIZE_TEGOTAE; k++)
    {
      N_s_filtered[j] += buffer_filter_tegotae.N_s[k][j];
    }
    N_s_filtered[j] = N_s_filtered[j]/(FILTER_SIZE_TEGOTAE+1);
    //SerialUSB.print("Limb ");SerialUSB.print(j);
    //SerialUSB.print(" grf filtered :"); SerialUSB.println(N_s_filtered[j],4);
    }
    advanced_tegotae_term = sigma_advanced * vector_sum(inverse_map[i_limb],N_s_filtered,n_limb) * cos(phi[i_limb]);
  }
  else
  {
    advanced_tegotae_term = sigma_advanced * vector_sum(inverse_map[i_limb],N_s,n_limb) * cos(phi[i_limb]);
  }
  if (tegotae_propulsion_local)
  {
    advanced_tegotae_term += - sigma_p * N_p[i_limb] * cos(phi[i_limb]);
  }
  if (tegotae_propulsion_advanced)
  {
    advanced_tegotae_term += - sigma_p_advanced * vector_sum(inverse_map_propulsion[i_limb],N_p,n_limb) * sin(phi[i_limb]);
  }
  return advanced_tegotae_term;
}

float complete_rule(uint8_t i_limb){
  float complete_rule_term = 0;
  complete_rule_term += sigma_hip * vector_sum(u_hip[i_limb],N_s,n_limb)*cos(phi[i_limb]);
  complete_rule_term += sigma_knee * vector_sum(u_knee[i_limb],N_s,n_limb)*sin(phi[i_limb]);
  complete_rule_term += - sigma_p_hip * vector_sum(v_hip[i_limb],N_p,n_limb)*cos(phi[i_limb]);
  complete_rule_term += - sigma_p_knee * vector_sum(v_knee[i_limb],N_p,n_limb)*sin(phi[i_limb]);
  return complete_rule_term;
}

float complete_rule_Nref(uint8_t i_limb){
  float complete_rule_term = 0;
  complete_rule_term += sigma_hip * (vector_sum(u_hip[i_limb],N_s_ref_corrected,n_limb)*cos(phi[i_limb]) -N_ref_der(i_limb,phi[i_limb])*N_s_ref_corrected[i_limb]);
  return complete_rule_term;
}

/*
float N_ref_func(float phase){
  float N_ref = 0; 
  if (phase>pi){
    N_ref = -N_ref_0*sin(phase);
  }
  return N_ref;
}

float N_ref_der(float phase){
  float N_ref_derivative = 0; 
  if (phase>pi){
    N_ref_derivative = -N_ref_0*cos(phase);
  }
  return N_ref_derivative;
}
 */

/*
float N_ref_func(float phase){
  float limits[6] = {0.67, 2.65, 3.4, 3.6, 5.1, 6.3}; 
  float a0[6] = {3.3954, -0.3744, -10.8128, 4.9937, -6.8528, 26.1507};
  float a1[6] = {-6.1943, 0.2176, 4.0852, -0.5303, 2.7348, -3.6236};

  for (uint8_t i=0; i<6; i++){
    if (phase<limits[i])
      return a0[i]+a1[i]*phase;
  }
  return 0;
}

float N_ref_der(float phase){
  float limits[6] = {0.67, 2.65, 3.4, 3.6, 5.1, 6.3}; 
  float a1[6] = {-6.1943, 0.2176, 4.0852, -0.5303, 2.7348, -3.6236};
  for (uint8_t i=0; i<6; i++){
    if (phase<limits[i])
      return a1[i];
  }
  return 0;
}

*/

float N_ref_func(uint8_t i_limb, float phase){
  uint8_t i=0;
  while(phase>=limits_Nref[i_limb][i])
    i++;
  return b_Nref[i_limb][i-1]+a_Nref[i_limb][i-1]*phase; 
}

float N_ref_der(uint8_t i_limb, float phase){
  uint8_t i=0;
  while(phase>=limits_Nref[i_limb][i])
    i++;
  return a_Nref[i_limb][i-1]; 
}

float vector_sum(std::vector<float> matrix_row, float N[], uint8_t size){
  float sum = 0;
  for (uint8_t i = 0; i < size; i++){
    sum += matrix_row[i]*N[i];
    //SerialUSB.println(sum,3);
  }
  return sum;
}

float total_GRF(float N[], uint8_t size){
  float sum = 0;
  for (uint8_t i = 0; i < size; i++){
    sum += N[i];
  }
  return sum;  
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
  //simple_send_pos_Serial3();
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
  delay(1000);
  if (tegotae_advanced){
    if (USE_FILTER_TEGOTAE){
      SerialUSB.print("Using filter of size ");
      SerialUSB.print(FILTER_SIZE_TEGOTAE); SerialUSB.println(" for Tegotae.");
    }
    #ifdef MAP_USED
      SerialUSB.print("Parameters learned from twitching record ID "); SerialUSB.println(MAP_USED);
    #endif
    SerialUSB.print("Sigma for advanced tegotae  : "); SerialUSB.println(sigma_advanced,5);
    print_inverse_map();
    print_limbs();
    print_changeDirs();
    if (tegotae_propulsion_advanced){
     SerialUSB.print("Using advanced propulsion term in Tegoate rule, sigma_p_advanced: "); SerialUSB.println(sigma_p_advanced);   
    }
  }
  if (tegotae_simple)
  {
    SerialUSB.print("Sigma for simple tegotae  : ");SerialUSB.println(sigma_s);
  }
  if (tegotae_propulsion_local){
    SerialUSB.print("Using propulsion term in Tegoate rule, sigma_p :"); SerialUSB.println(sigma_p);
  }
  if  (complete_formula||complete_formula_Nref){
    SerialUSB.println("Using complete_formula");
    print_map_complete_formula(u_hip,"u_hip");
    print_map_complete_formula(u_knee, "u_knee");
    print_map_complete_formula(v_hip, "v_hip");
    print_map_complete_formula(v_knee, "v_knee");
    SerialUSB.print("sigma hip: "); SerialUSB.println(sigma_hip,4);
    SerialUSB.print("sigma knee: "); SerialUSB.println(sigma_knee,4);
    SerialUSB.print("sigma p hip: "); SerialUSB.println(sigma_p_hip,4);
    SerialUSB.print("sigma p knee: "); SerialUSB.println(sigma_p_knee,4);
  }
  if (complete_formula_Nref){
    SerialUSB.println("Using complete_formula with Nref = max(-N_ref_0*sin(phi);0)");
    SerialUSB.print("N_ref_0 = ");SerialUSB.println(N_ref_0);
  }

  print_GRF_ref();
  print_phi_init_tegotae();
}


void print_Tegotae_parameters_bluetooth(){
  if (tegotae_advanced){
    if (USE_FILTER_TEGOTAE){
      SerialUSB.print("Using filter of size ");
      SerialUSB.print(FILTER_SIZE_TEGOTAE); SerialUSB.println(" for Tegotae.");
    }
    #ifdef MAP_USED
      SerialUSB.print("Map learned from twitching record ID "); SerialUSB.println(MAP_USED);
    #endif
    SerialUSB.print("Sigma for advanced tegotae  : "); SerialUSB.println(sigma_advanced,5);
  }
  else
  {
    SerialUSB.print("Sigma for simple tegotae  : ");SerialUSB.println(sigma_s);
  }
  if (tegotae_propulsion_local){
    SerialUSB.print("Using local propulsion term in Tegoate rule, sigma_p: "); SerialUSB.println(sigma_p);
  }  
  if (tegotae_propulsion_advanced){
     SerialUSB.print("Using advanced propulsion term in Tegoate rule, sigma_p_advanced: "); SerialUSB.println(sigma_p_advanced);   
  }
  SerialUSB.print("Frequency (in Hertz) : "); SerialUSB.println(frequency);
}

void print_GRF_ref(){
  SerialUSB.print("GRF ref : ");
  for (uint8_t i=0; i<n_limb; i++){
    SerialUSB.print(GRF_ref[i],3);
    SerialUSB.print(" ");
  }
  SerialUSB.println();
}

void print_phi_init_tegotae(){
 SerialUSB.print("Phi init for tegotae: ");
  for (int i=0; i<n_limb; i++){
    SerialUSB.print(phi_init[i],2);
    SerialUSB.print(", ");
  }
  SerialUSB.println();
}

void print_map_complete_formula(std::vector<std::vector<float>> map,String map_name){
  SerialUSB.print(map_name); SerialUSB.println(": ");
  for(uint8_t i=0; i<size_map_complete_rule; i++){
    for(uint8_t j=0; j<size_map_complete_rule; j++){
      SerialUSB.print(map[i][j]); SerialUSB.print(", ");
    }
    SerialUSB.println();
  }
  SerialUSB.println();
}

int sign(float number){
  if (number>0) 
    return 1;
  else
   return -1;
}
