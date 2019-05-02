void show_load_info_hardcoded(){
  show_total_z_load_sides();
  show_total_z_load_fronts();
}

void show_total_z_load_sides(){
  float totalz_load_right_side = 0;
  for (int i : {1, 2}){
    totalz_load_right_side += ser_rx_buf.last_loadcell_data_float[3*i+2];
  }
  float totalz_load_left_side = 0;
  for (int i : {0, 3}){
    totalz_load_left_side += ser_rx_buf.last_loadcell_data_float[3*i+2];
  }
  SerialUSB.print("Total Z load left side ");
  SerialUSB.println(totalz_load_left_side);
  SerialUSB.print("Total Z load right side ");
  SerialUSB.println(totalz_load_right_side);
  if (totalz_load_left_side - totalz_load_right_side > 0.2){
    SerialUSB.println("You should push the support towards the computer tower.");
  }
  if (totalz_load_right_side - totalz_load_left_side > 0.2){
    SerialUSB.println("You should push the support towards the power supply.");
  }
}

void show_total_z_load_fronts(){
  float totalz_load_front= 0;
  for (int i : {2, 3}){
    totalz_load_front += ser_rx_buf.last_loadcell_data_float[3*i+2];
  }
  SerialUSB.print("Total Z load front ");
  SerialUSB.println(totalz_load_front);
  float totalz_load_back= 0;
  for (int i : {0, 1}){
    totalz_load_back += ser_rx_buf.last_loadcell_data_float[3*i+2];
  }
  SerialUSB.print("Total Z load back ");
  SerialUSB.println(totalz_load_back);

  if (totalz_load_front - totalz_load_back > 0.2){
    SerialUSB.println("You should push the support backwards.");
  }
  if (totalz_load_back - totalz_load_front > 0.2){
    SerialUSB.println("You should push the support forwards.");
  }
}