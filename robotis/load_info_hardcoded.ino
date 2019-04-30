void show_load_info_hardcoded(){
    show_total_z_load_right_side();
  show_total_z_load_left_side();
  show_total_z_load_front();
  show_total_z_load_back();
}

void show_total_z_load_left_side(){
  float totalz_load_left_side = 0;
  for (int i : {0, 3}){
    totalz_load_left_side += ser_rx_buf.last_loadcell_data_float[3*i+2];
  }
  SerialUSB.print("Total Z load left side ");
  SerialUSB.println(totalz_load_left_side);
}

void show_total_z_load_front(){
  float totalz_load_front= 0;
  for (int i : {2, 3}){
    totalz_load_front += ser_rx_buf.last_loadcell_data_float[3*i+2];
  }
  SerialUSB.print("Total Z load front ");
  SerialUSB.println(totalz_load_front);
}

void show_total_z_load_back(){
  float totalz_load_back= 0;
  for (int i : {0, 1}){
    totalz_load_back += ser_rx_buf.last_loadcell_data_float[3*i+2];
  }
  SerialUSB.print("Total Z load back ");
  SerialUSB.println(totalz_load_back);
}