#include <vector> //takes a lot of space,
//could be improved with pointers


//105 : 4 legs, 2 more compliant foot (27 sh and 40sh)

//good maps :
//105 for quaduped
//110 for hexapod
//115 for octopod
//127 for starfish quadruped
//134 for starfish hexapod

//dont forget to change TIME_INTERVAL_TWITCH and DELAY_UPDATE_DC_TEGOTAE

#define MAP_USED 110


//Starfish Hexapod SECTION

std::vector<std::vector<uint8_t>> limbs_X_hex_quad{
    {9, 8},
    {4, 3},
    {7, 5},
    {2, 1},
    {11, 10},
    {0, 6}
};

std::vector<std::vector<bool>> changeDirs_X_hex_quad{
    {false,false},
    {false,false},
    {false,false},
    {true,true},
    {true,true},
    {true,true}
};

std::vector<bool>  changeDirs_Yaw_hex_quad{true,true,true,true,true,true,};
std::vector<bool>  changeDirs_Y_hex_quad{true,false,true,false,true,false};


float sigma_advanced_X_134 = 0.1197;// scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_134{
{-0.560, 0.215, 0.167, -0.070, -0.194, 0.535} ,
{0.391, -0.657, 0.558, -0.200, 0.009, 0.005} ,
{-0.597, 0.840, -0.786, 0.953, -0.603, 0.359} ,
{0.003, -0.237, 0.554, -0.649, 0.525, -0.071} ,
{-0.218, -0.018, -0.014, 0.436, -0.605, 0.543} ,
{0.910, -0.488, 0.215, -0.559, 0.941, -1.000}
};
uint16_t neutral_pos_134[12] = {512, 505, 508, 516, 511, 510, 509, 509, 514, 509, 506, 510};
float scaling_amp_class1_forward_134[6] = {1.000,0.286,0.100,0.396,0.796,0.086};
float scaling_amp_class1_Y_134[6] = {0.171,0.284,0.598,0.004,0.165,1.000};
float scaling_amp_class1_yaw_134[6] = {0.833,0.070,0.712,0.110,0.847,1.000};

//S QUAD SECTION

std::vector<std::vector<uint8_t>> limbs_X_s_quad{
    {0,2},
    {5,4},
    {3,1},
    {7,6}
};

std::vector<std::vector<bool>>  changeDirs_X_s_quad{
    {false,true},
    {true,false},
    {true,false},
    {false,true},
};

std::vector<bool>  changeDirs_Yaw_s_quad{true,true,true,true};
std::vector<bool>  changeDirs_Y_s_quad{false,true,false,false};


float sigma_advanced_X_127 = 0.1878;// scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_127{
{-1.000, 0.953, -0.836, 0.939} ,
{0.543, -0.717, 0.597, -0.474} ,
{-0.564, 0.619, -0.616, 0.716} ,
{0.637, -0.679, 0.628, -0.455}
};

//matrix R used for experiments
/*
float sigma_advanced_X_R = 0.5647;// scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_R{
{0.05, -0.36, -0.35, -0.24},
{0.34, -0.25, 0.31, -0.26},
{0.43, -0.15, -0.30, -0.25},
{0.12, -0.03, -0.15, 0.33}
};
*/

uint16_t neutral_pos_127[8] = {512, 511, 509, 508, 511, 510, 497, 512};
float scaling_amp_class1_forward_127[4] = {0.862, 0.091, 1, 0.054};
float scaling_amp_class1_Y_127[4] = {0.148, 1, 0.015, 0.946};
float scaling_amp_class1_yaw_127[4] = {1, 0.842, 0.892, 0.666};


//OCTOPOD SECTION

std::vector<std::vector<uint8_t>> limbs_X_8{
    {13,12},
    {0,8},
    {6,5},
    {10,11},
    {2,1},
    {4,3},
    {9,7},
    {15,14},
};

std::vector<std::vector<bool>>  changeDirs_X_8{
    {false,false},
    {false,true},
    {false,false},
    {false,false},
    {true,true},
    {true,true},
    {true,false},
    {true,true},
};

std::vector<bool>  changeDirs_X_Yaw_8{true,true,true,true,true,true,true,true};
//these are the good values, the learned ones are wrong for 4 limbs.

float sigma_advanced_X_115 = 0.0981;// scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_115{
{-0.318, 0.176, 0.010, 0.056, -0.113, -0.035, 0.106, 0.179} , //learnt version the (1,2) term could be bad.
//{-0.318, 0.400, 0.010, 0.056, -0.113, -0.035, 0.106, 0.179} ,   //with correction
{0.400, -0.896, 0.474, 0.040, -0.187, 0.148, -0.006, 0.218} ,
{0.029, 0.345, -0.853, 0.464, 0.129, -0.033, 0.221, -0.113} ,
{0.025, 0.038, 0.376, -0.452, 0.215, 0.162, -0.076, -0.144} ,
{-0.185, -0.134, 0.266, 0.098, -0.571, 0.566, 0.023, -0.006} ,
{-0.168, 0.170, -0.023, 0.073, 0.587, -1.000, 0.563, -0.025} ,
{0.179, -0.107, 0.158, -0.166, 0.075, 0.331, -0.649, 0.332} ,
{0.200, 0.077, -0.088, -0.124, 0.095, -0.031, 0.335, -0.346} ,
};
uint16_t neutral_pos_115[16] = {510,   506,   512,   498,   512,   519,   515,   519,   503,   512,  511,   513,   515,   508,   503,   510};


//Hexapod section

std::vector<std::vector<uint8_t>> limbs_X_6{
    {9,8},
    {0,6},
    {4,3},
    {2,1},
    {7,5},
    {11,10},
};

std::vector<std::vector<bool>>  changeDirs_X_6{
    {false,false},
    {false,true},
    {false,false},
    {true,true},
    {true,false},
    {true,true},
};

std::vector<bool>  changeDirs_X_Yaw_6{true,true,true,true,true,true};

float sigma_advanced_X_110 = 0.1206;// scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_110{
    /*
{-0.490, 0.100, 0.227, -0.308, 0.074, 0.287} ,
{0.428, -1.000, 0.550, -0.051, -0.002, 0.088} ,
{0.134, 0.391, -0.697, 0.280, 0.264, -0.437} ,
{-0.449, 0.061, 0.343, -0.719, 0.579, 0.089} ,
{0.036, 0.007, -0.097, 0.456, -0.786, 0.329} ,
{0.214, 0.039, -0.294, 0.156, 0.209, -0.377} ,
};
*/

{-0.450, 0.402, 0.025, -0.334, 0.239, 0.146} ,
{0.433, -1.000, 0.561, -0.065, 0.073, 0.083} ,
{-0.029, 0.436, -0.508, 0.126, 0.365, -0.378} ,
{-0.319, -0.014, 0.344, -0.523, 0.513, 0.051} ,
{0.187, -0.225, 0.057, 0.494, -0.824, 0.413} ,
{0.362, -0.032, -0.280, 0.131, 0.293, -0.319} 
};

uint16_t neutral_pos_110[12] = {510,   514,   512,   508,   510,   509,   513,   511,   509,   511,   514,   510};

//Quadruped section

std::vector<std::vector<uint8_t>> limbs_X_4{
    {5,4},
    {3,2},
    {1,0},
    {7,6}
};

std::vector<std::vector<uint8_t>> limbs_Y_4{
    {4,5},
    {2,3},
    {0,1},
    {6,7}
};

std::vector<std::vector<bool>>  changeDirs_X_4{
    {false,false},
    {false,false},
    {true,true},
    {true,true}
};

std::vector<std::vector<bool>>  changeDirs_Y_4{
    {true,true},
    {true,false},
    {true,true},
    {true,false}
};


std::vector<bool>  changeDirs_X_Yaw_4{true,true,true,true};
std::vector<bool>  changeDirs_Y_Yaw_4{false,true,true,false};



float sigma_advanced_X_105 = 0.1224; // scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_105{
{-0.959, 0.732, -0.652, 0.753} ,
{0.711, -1.000, 0.793, -0.680} ,
{-0.858, 0.808, -0.892, 0.809} ,
{0.565, -0.732, 0.658, -0.816} ,
};
uint16_t neutral_pos_105[8]=
{519, 512, 508, 514, 503, 506, 521, 518};

float sigma_advanced_Y_105 = 0.1410; // scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_Y_105{
//original version
/*
{-0.564, 0.688, -0.895, 0.869} ,
{0.665, -0.933, 0.870, -0.862} ,
{-0.965, 1.000, -0.916, 0.879} ,
{0.816, -0.829, 0.801, -0.771} ,
*/
//corrected version
{-0.873, 0.875, -0.895, 0.869} ,
{0.9, -0.933, 0.870, -0.862} ,
{-0.965, 1.000, -0.916, 0.879} ,
{0.816, -0.829, 0.801, -0.771} ,
};

bool bool_Y_105 = false;