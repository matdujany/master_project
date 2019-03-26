#ifndef _Packet_h
#ifdef __cplusplus
#define _Packet_h
#include <stdint.h>

// frame header
#define FRAME_SYNC_0 							0xFF
#define FRAME_SYNC_1							0xAA
#define END_FRAME								  0x55

// read and other commands
#define FRAME_TYPE_SENSOR_DATA					  0x01
#define FRAME_TYPE_COMMAND_DATA           0x10
#define FRAME_TYPE_COMMAND_TOP_LED				0x13

// data length of each Arduino
#define SENSOR_DATA_ADC_LENGTH	4 //the loadcells return a 4-byte float
#define SENSOR_DATA_TIMESTAMP_POINTER	  (SENSOR_DATA_ADC_LENGTH)
#define SENSOR_DATA_LENGTH				      (3*SENSOR_DATA_ADC_LENGTH+1) //3 loadcells plus the timestamp is an additional byte
// I HAVE TO CHANGE THAT TO 3 LOADCELLS AND THE TIMESTAMP

// data length of IMU
#define IMU_DATA_ADC_LENGTH          4 //the IMU return a 4-byte float --> IS THIS TRUE?!
#define IMU_DATA_TIMESTAMP_POINTER   (SENSOR_DATA_ADC_LENGTH)
#define IMU_DATA_LENGTH              (6*SENSOR_DATA_ADC_LENGTH+1) // (3 linear values + 3 rotational values) * 4 bytes + 1 timestamp byte


#endif // __cplusplus
#endif /* _Packet_h */
