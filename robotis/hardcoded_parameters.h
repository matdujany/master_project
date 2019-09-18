#include <vector> //takes a lot of space,
//could be improved with pointers


//105 : 4 legs, 2 more compliant foot (27 sh and 40sh)

//good maps :
//105 for quaduped
//110 for hexapod
//115 for octopod
//127 for starfish quadruped
//134 for starfish hexapod
//200 for starfish hexapod with new leg design
//210 for hexapod with new leg design
//220 for octopod with new leg design

//when adding a new map,
// add a case in initialize_hardcoded_limbs()
// add a case in initialize_inverse_map_advanced_tegotae()
// if needed, add a case in initialize_scaling_amp_class1()


#define DO_LOCOMOTION

#ifdef DO_LOCOMOTION

//dont forget to adapt TIME_INTERVAL_TWITCH and DELAY_UPDATE_DC_TEGOTAE
#define MAP_USED 110

//Octopod with new leg design : 220.
std::vector<std::vector<uint8_t>> limbs_X_oct_2{
{1, 2},
{9, 10},
{0, 4},
{13, 14},
{15, 8},
{11, 12},
{3, 5},
{7, 6},
};


std::vector<std::vector<bool>> changeDirs_X_oct_2{
{true,true},
{true,true},
{true,true},
{true,true},
{false,true},
{false,true},
{false,true},
{false,false},
};

std::vector<bool>  changeDirs_Yaw_oct_2{false,false,false,false,false,false,false,false};

float sigma_advanced_X_220 = 0.0865;// scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_220{

{-0.533, 0.571, 0.086, -0.118, -0.141, -0.050, 0.014, 0.171} ,
{0.486, -1.000, 0.470, 0.055, -0.064, 0.051, -0.004, 0.033} ,
{0.043, 0.344, -0.847, 0.439, 0.072, -0.046, 0.037, -0.046} ,
{-0.087, 0.070, 0.486, -0.459, 0.070, 0.054, -0.027, -0.093} ,
{-0.141, -0.040, 0.077, 0.092, -0.656, 0.622, 0.187, -0.144} ,
{-0.065, 0.036, -0.025, 0.043, 0.503, -0.932, 0.375, 0.050} ,
{0.003, -0.029, 0.056, -0.047, 0.079, 0.306, -0.786, 0.420} ,
{0.159, 0.028, -0.057, -0.126, -0.138, 0.115, 0.554, -0.551}

};
uint16_t neutral_pos_220[16] = {511, 511, 507, 510, 508, 509, 516, 512, 509, 510, 506, 510, 507, 510, 508, 513};


//Hexapod with new leg design : 210.
std::vector<std::vector<uint8_t>> limbs_X_hex_2{
    {1, 2},
    {8, 9},
    {0, 4},
    {10, 11},
    {3, 5},
    {7, 6},
};

std::vector<std::vector<bool>> changeDirs_X_hex_2{
{true,true},
{true,true},
{true,true},
{false,true},
{false,true},
{false,false},
};

std::vector<bool>  changeDirs_Yaw_hex_2{false,false,false,false,false,false};

float sigma_advanced_X_210 = 0.1352;// scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_210{


{-0.467, 0.561, -0.099, -0.221, 0.001, 0.237} ,
{0.408, -0.802, 0.400, 0.027, -0.023, 0.033} ,
{-0.078, 0.523, -0.436, 0.174, 0.053, -0.211} ,
{-0.201, 0.030, 0.173, -0.456, 0.557, -0.092} ,
{-0.012, -0.056, 0.069, 0.471, -1.000, 0.508} ,
{0.224, 0.001, -0.217, -0.081, 0.513, -0.471}

    /*
{-0.490, 0.100, 0.227, -0.308, 0.074, 0.287} ,
{0.428, -1.000, 0.550, -0.051, -0.002, 0.088} ,
{0.134, 0.391, -0.697, 0.280, 0.264, -0.437} ,
{-0.449, 0.061, 0.343, -0.719, 0.579, 0.089} ,
{0.036, 0.007, -0.097, 0.456, -0.786, 0.329} ,
{0.214, 0.039, -0.294, 0.156, 0.209, -0.377} 
*/

};
uint16_t neutral_pos_210[12] = { 511, 510, 507, 512, 510, 508, 516, 512, 510, 507, 512, 510 };



//Starfish hexapod with new leg design,
std::vector<std::vector<uint8_t>> limbs_X_s_hex_2{
    {1, 2},
    {8, 9},
    {0, 4},
    {3, 5},
    {7, 6},
    {10, 11}
};

std::vector<std::vector<bool>> changeDirs_X_s_hex_2{
{true,true},
{true,true},
{true,true},
{false,true},
{false,false},
{false,true}
};

std::vector<bool>  changeDirs_Yaw_s_hex_2{false,false,false,false,false,false};
std::vector<bool>  changeDirs_s_Y_hex_2{false,false,false,false,false,true};

float sigma_advanced_X_204 = 0.0976;// scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_204{
{-0.868, 0.645, -0.041, -0.042, -0.177, 0.526} ,
{0.491, -0.765, 0.552, -0.230, -0.052, 0.048} ,
{-0.058, 0.630, -0.781, 0.637, -0.042, -0.411} ,
{-0.048, -0.284, 0.674, -1.000, 0.622, 0.039} ,
{-0.174, -0.038, -0.072, 0.661, -0.910, 0.508} ,
{0.516, 0.012, -0.374, -0.023, 0.546, -0.705}
};
uint16_t neutral_pos_204[12] = { 511, 510, 507, 512, 510, 508, 516, 512, 510, 507, 512, 510 };

//hardcoded values
float scaling_amp_class1_forward_204[6] = {1,1,0,1,1,0};
float scaling_amp_class1_Y_204[6] = {0,0,1.000,0,0,1};
float scaling_amp_class1_yaw_204[6] = {1,1,1,1,1,1};


/*
float scaling_amp_class1_forward_200[6] = {0.826,1.000,0.236,0.482,0.894,0.286};
float scaling_amp_class1_Y_200[6] = {0.298,0.396,1.000,0.211,0.211,0.243};
float scaling_amp_class1_yaw_200[6] = {0.139,0.723,1.000,0.681,0.101,0.380};
*/


//Starfish Hexapod SECTION

/*
std::vector<std::vector<uint8_t>> limbs_X_s_hex{
    {9, 8},
    {4, 3},
    {7, 5},
    {2, 1},
    {11, 10},
    {0, 6}
};

std::vector<std::vector<bool>> changeDirs_X_s_hex{
    {false,false},
    {false,false},
    {false,false},
    {true,true},
    {true,true},
    {true,true}
};

std::vector<bool>  changeDirs_Yaw_s_hex{true,true,true,true,true,true,};
std::vector<bool>  changeDirs_Y_s_hex{true,false,true,false,true,false};


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
*/


//Starfish quadruped SECTION
/*
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

uint16_t neutral_pos_127[8] = {512, 511, 509, 508, 511, 510, 497, 512};
float scaling_amp_class1_forward_127[4] = {0.862, 0.091, 1, 0.054};
float scaling_amp_class1_Y_127[4] = {0.148, 1, 0.015, 0.946};
float scaling_amp_class1_yaw_127[4] = {1, 0.842, 0.892, 0.666};
*/

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

//OCTOPOD SECTION

/*
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
*/

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

uint16_t neutral_pos_110[12] = //{510,   514,   512,   508,   510,   509,   513,   511,   509,   511,   514,   510};
{510, 491, 511, 511, 514, 530, 508, 511, 516, 508, 494, 530};//143

float sigma_advanced_X_110 = 0; // 0.5;// scaled for 50% of 0.5Hz

std::vector<std::vector<float>> inverse_map_X_110{

    //record 110

{-0.490, 0.100, 0.227, -0.308, 0.074, 0.287} ,
{0.428, -1.000, 0.550, -0.051, -0.002, 0.088} ,
{0.134, 0.391, -0.697, 0.280, 0.264, -0.437} ,
{-0.449, 0.061, 0.343, -0.719, 0.579, 0.089} ,
{0.036, 0.007, -0.097, 0.456, -0.786, 0.329} ,
{0.214, 0.039, -0.294, 0.156, 0.209, -0.377} ,

//online
/* 
{-0.289, 0.277, 0.317, -0.621, 0.546, 0.258} ,
{0.039, -0.834, 0.136, 0.324, -0.692, 0.197} ,
{0.234, 0.488, -0.646, 0.222, 0.145, -0.517} ,
{-0.338, 0.111, 0.247, -1.000, 0.336, 0.229} ,
{0.045, -0.489, 0.305, 0.746, -0.622, 0.216} ,
{0.293, 0.417, -0.411, 0.241, 0.073, -0.362} ,
*/

//tes
/*
{0, 0.100, 0.227, -0.308, 0.074, 0.287} ,
{0.428, 0, 0.550, -0.051, -0.002, 0.088} ,
{0.134, 0.391, 0, 0.280, 0.264, -0.437} ,
{-0.449, 0.061, 0.343, 0, 0.579, 0.089} ,
{0.036, 0.007, -0.097, 0.456, 0, 0.329} ,
{0.214, 0.039, -0.294, 0.156, 0.209, 0} ,
*/

    //test contralateral positive coupling
/*
{-1, +1, 0, 0, -1, 1} ,
{0, -1, 0, 0, 1, 0} ,
{0, 1, -1, 1, -1, 0} ,
{0, -1, 1, -1, +1, 0} ,
{0, 1, 0, 0, -1, 0} ,
{1, -1, 0, 0, 1, -1} ,
*/
    //record 138
/* 
{-0.450, 0.402, 0.025, -0.334, 0.239, 0.146} ,
{0.433, -1.000, 0.561, -0.065, 0.073, 0.083} ,
{-0.029, 0.436, -0.508, 0.126, 0.365, -0.378} ,
{-0.319, -0.014, 0.344, -0.523, 0.513, 0.051} ,
{0.187, -0.225, 0.057, 0.494, -0.824, 0.413} ,
{0.362, -0.032, -0.280, 0.131, 0.293, -0.319} 
*/
    //record 143
/*
{-0.742, 0.936, -0.106, -0.425, 0.170, 0.341} ,
{0.445, -0.954, 0.546, 0.016, 0.055, 0.086} ,
{-0.224, 1.000, -0.775, 0.440, 0.019, -0.399} ,
{-0.421, 0.068, 0.408, -0.631, 0.656, 0.047} ,
{0.148, -0.087, 0.042, 0.302, -0.500, 0.292} ,
{0.288, 0.176, -0.380, -0.053, 0.723, -0.600} ,
*/

};

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
    //original
{-0.959, 0.732, -0.652, 0.753} ,
{0.711, -1.000, 0.793, -0.680} ,
{-0.858, 0.808, -0.892, 0.809} ,
{0.565, -0.732, 0.658, -0.816} ,


//test
/*
{-1, 0, 0, 0.8} ,
{0, -1, 0.8, 0} ,
{0, 0.8, -1, 0} ,
{0.8, 0, 0, -1} ,
*/

};
uint16_t neutral_pos_105[8]=
{519, 512, 508, 514, 503, 506, 521, 518};

float sigma_advanced_Y_105 = 0.1410; // scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_Y_105{
//original version

{-0.564, 0.688, -0.895, 0.869} ,
{0.665, -0.933, 0.870, -0.862} ,
{-0.965, 1.000, -0.916, 0.879} ,
{0.816, -0.829, 0.801, -0.771} ,

//corrected version
/*
{-0.873, 0.875, -0.895, 0.869} ,
{0.9, -0.933, 0.870, -0.862} ,
{-0.965, 1.000, -0.916, 0.879} ,
{0.816, -0.829, 0.801, -0.771} ,
*/

};


bool bool_Y_105 = false;



#endif