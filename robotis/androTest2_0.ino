//Code taken from : https://forum.arduino.cc/index.php?topic=173246.msg1766646#msg1766646
// Version nAndroTest V2.0 - @kas2014\ndemo for V5.x App
//I have made a few modifications to adapt it to the robot

// make sure your BT board is set @BAUD_RATE_BLUE bps


#define    STX          0x02
#define    ETX          0x03
#define    SLOW         750                            // Datafields refresh rate (ms)
#define    FAST         250                             // Datafields refresh rate (ms)

byte cmd[8] = {0, 0, 0, 0, 0, 0, 0, 0};                 // bytes received
byte buttonStatus = 0;                                  // first Byte sent to Android device
long previousMillis = 0;                                // will store last time Buttons status was updated
long sendInterval = SLOW;                               // interval between Buttons status transmission (milliseconds)
String displayStatus = "Walking";                          // message to Android device
unsigned long last_update_joystick = 0;

int8_t joyX; //
int8_t joyY;

void setup_serial_bluetooth()  {
  Serial3.begin(BAUD_RATE_BLUE);
  delay(1000);
  while(Serial3.available())  Serial3.read();         // empty RX buffer
  delay(1000);
}

void serial_read_bluetooth_main() {
  if(Serial3.available())  {                           // data received from smartphone
  //delay(2);
  delayMicroseconds(1500);
  cmd[0] =  Serial3.read();  

  /*
  SerialUSB.print("First byte received at t=");
  SerialUSB.print(millis());
  SerialUSB.print(", byte :");
  SerialUSB.println(cmd[0]);
  */

  if(cmd[0] == STX)  {
    int i=1;      
    while(Serial3.available())  {
      //delay(1);
      delayMicroseconds(1500); //the original delay of 1 ms was not enought for my phone/application
      cmd[i] = Serial3.read();
      if(cmd[i]>127 || i>7)                 break;     // Communication error
      if((cmd[i]==ETX) && (i==2 || i==7))   break;     // Button or Joystick data
      i++;
    }
    if     (i==2)          getButtonState(cmd[1]);    // 3 Bytes  ex: < STX "C" ETX >
    else if(i==7)          getJoystickState(cmd);     // 6 Bytes  ex: < STX "200" "180" ETX >
  }
  }
  sendBlueToothData();
}

void sendBlueToothData()  {
 static long previousMillis = 0;                            
 long currentMillis = millis();
 if(currentMillis - previousMillis > sendInterval) {   // send data back to smartphone
   previousMillis = currentMillis;

// Data frame transmitted back from Arduino to Android device:
// < 0X02   Buttons state   0X01   DataField#1   0x04   DataField#2   0x05   DataField#3    0x03 >  
// < 0X02      "01011"      0X01     "120.00"    0x04     "-4500"     0x05  "Motor enabled" 0x03 >    // example

   Serial3.print((char)STX);                                             // Start of Transmission
   Serial3.print(getButtonStatusString());  Serial3.print((char)0x1);   // buttons status feedback
   Serial3.print(GetdataInt1());            Serial3.print((char)0x4);   // datafield #1
   //Serial3.print(GetdataFloat2());                Serial3.print((char)0x5);   // datafield #2
   Serial3.print(frequency);                Serial3.print((char)0x5);   // datafield #2
   Serial3.print(displayStatus);                                         // datafield #3
   Serial3.print((char)ETX);                                             // End of Transmission
 }  
}

String getButtonStatusString()  {
 String bStatus = "";
 for(int i=0; i<6; i++)  {
   if(buttonStatus & (B100000 >>i))      bStatus += "1";
   else                                  bStatus += "0";
 }
 return bStatus;
}

int GetdataInt1()  {              // Data dummy values sent to Android device for demo purpose
 static int i= -30;              // Replace with your own code
 i ++;
 if(i >0)    i = -30;
 return i;  
}

float GetdataFloat2()  {           // Data dummy values sent to Android device for demo purpose
 static float i=50;               // Replace with your own code
 i-=.5;
 if(i <-50)    i = 50;
 return i;  
}

void getJoystickState(byte data[8])    {
 joyX = (data[1]-48)*100 + (data[2]-48)*10 + (data[3]-48);       // obtain the Int from the ASCII representation
 joyY = (data[4]-48)*100 + (data[5]-48)*10 + (data[6]-48);
 joyX = joyX - 200;                                                  // Offset to avoid
 joyY = joyY - 200;                                                  // transmitting negative numbers

 if(joyX<-100 || joyX>100 || joyY<-100 || joyY>100)     return;      // commmunication error
 
  update_locomotion_weights(joyX,joyY);
  last_update_joystick = millis();
  SerialUSB.print("Joystick position:  ");
  SerialUSB.print(joyX);  
  SerialUSB.print(", ");  
  SerialUSB.print(joyY);
  SerialUSB.print(", Timestamp : ");  
  SerialUSB.println(last_update_joystick);

}

void getButtonState(int bStatus)  {
 switch (bStatus) {
// -----------------  BUTTON #1  -----------------------
   case 'A':
     buttonStatus |= B000001;        // ON
     SerialUSB.println("\n** Learn Button : ON **");
     // your code...      
     displayStatus = "Learning";
     SerialUSB.println(displayStatus);
     break;
   case 'B':
     buttonStatus &= B111110;        // OFF
     SerialUSB.println("\n** Learn Button: OFF **");
     // your code...      
     displayStatus = "Idle";
     SerialUSB.println(displayStatus);
     break;

// -----------------  BUTTON #2  -----------------------
   case 'C':
     buttonStatus |= B000010;        // ON
     SerialUSB.println("\n** Walk button: ON **");
     // your code...      
     displayStatus = "Walking";
     SerialUSB.println(displayStatus);
     break;
   case 'D':
     buttonStatus &= B111101;        // OFF
     SerialUSB.println("\n** Walk button: OFF **");
     // your code...      
     displayStatus = "Idle";
     SerialUSB.println(displayStatus);
     break;

    

// -----------------  BUTTON #3  -----------------------
   case 'E':
     buttonStatus |= B000100;        // ON
     SerialUSB.println("Increasing frequency");
     increase_freq_bluetooth();     
     break;
   case 'F':
     buttonStatus &= B111011;      // OFF
     break;

    
// -----------------  BUTTON #4  -----------------------
   case 'G':
     buttonStatus |= B001000;       // ON
     SerialUSB.println("Decreasing frequency");
     decrease_freq_bluetooth();    
     break;
   case 'H':
     buttonStatus &= B110111;    // OFF
    break;

    /*

// -----------------  BUTTON #5  -----------------------
   case 'I':           // configured as momentary button
//      buttonStatus |= B010000;        // ON
     Serial.println("\n** Button_5: ++ pushed ++ **");
     // your code...      
     displayStatus = "Button5: <pushed>";
     break;
//   case 'J':
//     buttonStatus &= B101111;        // OFF
//     // your code...      
//     break;

// -----------------  BUTTON #6  -----------------------
   case 'K':
     buttonStatus |= B100000;        // ON
     Serial.println("\n** Button_6: ON **");
     // your code...      
      displayStatus = "Button6 <ON>"; // Demo text message
    break;
   case 'L':
     buttonStatus &= B011111;        // OFF
     Serial.println("\n** Button_6: OFF **");
     // your code...      
     displayStatus = "Button6 <OFF>";
     break;
    */
 }
// ---------------------------------------------------------------
}