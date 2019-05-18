void init_tegotae(){
  initialize_hardcoded_limbs();
  if (tegotae_advanced)
    initialize_inverse_map_advanced_tegotae();
  if (USE_FILTER_TEGOTAE)
    init_filter_tegotae();
  print_locomotion_parameters();
}

void record_harcoded_tegotae_change_phi_init(){
  init_tegotae();
  init_recording_locomotion();

  init_phi_tegotae();
  for (int i=0; i<n_limb; i++){
    phi[i] = phi_init[i];
  }
  int recording_duration = 60;
  send_command_limb_oscillators(); 
  unsigned long t_start_recording = millis();

  while (millis()-t_start_recording<recording_duration*1000)
  {
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


void record_harcoded_tegotae_changes(){
  init_tegotae();
  init_recording_locomotion();

  init_phi_tegotae();
  frequency = frequency_recording[0];
  sigma_advanced = sigma_advanced_recording[0];
  sigma_s = sigma_simple_recording[0];
  int recording_duration = time_changes[n_changes_recording];
  send_command_limb_oscillators(); 
  unsigned long t_start_recording = millis();

  while (millis()-t_start_recording<recording_duration*1000)
  {
    unsigned long t_start_update_loop = millis();
    send_phi_and_pos_Serial3();
    send_frame_and_update_sensors(1,0);
    update_phi_tegotae();
    send_command_limb_oscillators();
    for (int i=0;i<n_changes_recording;i++)
    {
      if (!changes_done[i] && millis()-t_start_recording>time_changes[i]*1000){
        frequency = frequency_recording[i+1];
        sigma_advanced = sigma_advanced_recording[i+1];
        sigma_s = sigma_simple_recording[i+1];
        changes_done[i] = true;
        SerialUSB.print("Change done at t=");
        SerialUSB.println((millis()-t_start_recording)/1000);
      }
    }
    while(millis()-t_start_update_loop<DELAY_UPDATE_TEGOTAE);
  }

  SerialUSB.println("Tegotae recording over");
  SerialUSB.print("Nb end bytes sent: ");SerialUSB.println(nb_end_bytes_sent);
  SerialUSB.print("Nb frames found: ");SerialUSB.println(nb_frames_found);  
}


void hardcoded_tegotae(){
  init_tegotae();
  init_phi_tegotae();
  send_command_limb_oscillators(); 
  print_phi_info();
  while (true){
    unsigned long t_start_update_loop = millis();
    send_frame_and_update_sensors(1,0);
    update_phi_tegotae();
    send_command_limb_oscillators();
    print_phi_info();
    while(millis()-t_start_update_loop<DELAY_UPDATE_TEGOTAE);
  }
}

//change dir is set to true for hips if - hip direction produces lift off
//change dir is set to true for knees if - knee direction pushes backwards

//hip first, knee after, in loadcell order

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

void fill_inverse_map_array( std::vector<std::vector<float>> inverse_map_hardcoded){
  inverse_map.resize(n_limb);
  for (int i=0; i<n_limb; i++){
    inverse_map[i].resize(n_limb);
    for (int j=0; j<n_limb; j++){
      inverse_map[i][j] = inverse_map_hardcoded[i][j];
    }
  }
}

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

void init_offset_class1(){
  if (flagTurning){
    for (int i : {1, 2, 3, 4}){
      offset_class1[i] = -pi/2;
    }
    for (int i : {0, 5, 6, 7}){
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
    goal_positions_tegotae[2*i] = phase2pos_wrapper(phi[i]+offset_class1[i], 0, changeDirs[i][0]);

    //class 2 : stance swing
    servo_id_list[2*i+1] = id[limbs[i][1]];
    goal_positions_tegotae[2*i+1] = phase2pos_wrapper(phi[i], 1, changeDirs[i][1]);
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

uint16_t phase2pos_wrapper(float phase, boolean isClass2, boolean changeDir){
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
    
    if (phi[i]>2*pi)
      phi[i] = phi[i] - 2*pi;
    
  }
  t_last_phi_update = t_current;
}


float simple_tegotae_rule(float phase, float ground_reaction_force){
  float phi_dot = 2 * pi * frequency - sigma_s * ground_reaction_force * cos(phase);
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

// For Recordings

void init_recording_locomotion(){
  switch_frame_recording_mode();
  SerialUSB.print("Waiting for any input from Serial USB console to start recording...");
  while (!SerialUSB.available());  
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
  SerialUSB.print("Locomotion in direction : "); 
  (direction_X) ? SerialUSB.println("X") : 0;
  (direction_Y) ? SerialUSB.println("Y") : 0;
  (direction_Yaw) ? SerialUSB.println("Yaw"): 0;
  if (tegotae_advanced){
    if (USE_FILTER_TEGOTAE){
      SerialUSB.print("Using filter of size ");
      SerialUSB.print(FILTER_SIZE_TEGOTAE); SerialUSB.println(" for Tegotae.");
    }
    SerialUSB.print("Parameters learned from twitching record ID "); SerialUSB.println(MAP_USED);
    SerialUSB.print("Sigma for advanced tegotae  : "); SerialUSB.println(sigma_advanced);
    print_inverse_map();
    print_limbs();
    print_changeDirs();
  }
  else
  {
    SerialUSB.print("Sigma for simple tegotae  : ");SerialUSB.println(sigma_s);
  }
  if (flagTurning)
    SerialUSB.println("Turning mode activated");
}

