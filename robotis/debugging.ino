void demo_problem_recalib_mode(){
       
    SerialUSB.println("Switching to calib mode");
    switch_frame_IMU_recalib_mode();
    for(int i=0; i<10; i++){
        try_capture_1_frame(1);
        delay(20);
    }
    SerialUSB.println("Switching to normal mode");
    switch_frame_all_data_mode();
    for(int i=0; i<10; i++){
        try_capture_1_frame(1);
        delay(20);
    }
}