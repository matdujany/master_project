#ifndef _Packet_h
#ifdef __cplusplus
#define _Packet_h
#include <stdint.h>

// frame header
#define FRAME_SYNC_0 							0xFF
#define FRAME_SYNC_1							0xAA
#define END_FRAME								0x55

// read and other commands
#define FRAME_TYPE_RECORDING              0x01     //default frametype, using during learning, Matlab will record these frames only
#define FRAME_TYPE_IMU_RECALIB            0x02    //frametype where only the IMU writes data, to recalibrate it
#define FRAME_TYPE_NORMAL                 0x03    //frametype where IMU and LCs write data, but frames are not used for learning
#define FRAME_TYPE_IMU_UPDATE_OFF         0x04    //frametype where IMU stops to update its sensors and write its values, it is 'off' but still checks the bytes and can be turned on again to add values again.

// data length of each Arduino
#define SENSOR_DATA_ADC_LENGTH					  4 //the loadcells return a 4-byte float
#define SENSOR_DATA_TIMESTAMP_POINTER	  	(SENSOR_DATA_ADC_LENGTH)
#define SENSOR_DATA_LENGTH				      	(3*SENSOR_DATA_ADC_LENGTH+1) //3 loadcells plus the timestamp is an additional byte

// data length of IMU
#define IMU_DATA_ADC_LENGTH          4 //the IMU return a 4-byte float
#define IMU_DATA_TIMESTAMP_POINTER   (SENSOR_DATA_ADC_LENGTH)
#define IMU_DATA_LENGTH              (6*SENSOR_DATA_ADC_LENGTH+1) // (3 linear values + 3 rotational values) * 4 bytes + 1 timestamp byte


#endif // __cplusplus
#endif /* _Packet_h */
