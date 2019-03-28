void helper_function(){
  if (SerialUSB.available()){
    char inByte = SerialUSB.read();
    SerialUSB.print("received byte: "); SerialUSB.println(inByte);
    if (inByte == 't'){
      send_frame_and_update_loadcells();
    }
    SerialUSB.print("Nb end bytes sent: ");SerialUSB.println(nb_end_bytes_sent);
    SerialUSB.print("Nb frames found: ");SerialUSB.println(nb_frames_found);
  }
}

void debugging_send_frame_byte(){
  SerialUSB.print("Max frame Size: "); SerialUSB.println(MAX_FRAME_SIZE);
  while (!bool_end_byte_sent)
    send_frame_byte(1);
}