#include <vector> //takes a lot of space,
//could be improved with pointers


//104 : 4 legs, all rigid feet (50 sh)
//105 : 4 legs, 2 more compliant foot (27 sh and 40sh)
//108 : 6 legs, all rigid feet (50 sh)

#define MAP_USED 115


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


float sigma_advanced_X_115 = 0.0981;// scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_115{
{-0.318, 0.176, 0.010, 0.056, -0.113, -0.035, 0.106, 0.179} ,
{0.400, -0.896, 0.474, 0.040, -0.187, 0.148, -0.006, 0.218} ,
{0.029, 0.345, -0.853, 0.464, 0.129, -0.033, 0.221, -0.113} ,
{0.025, 0.038, 0.376, -0.452, 0.215, 0.162, -0.076, -0.144} ,
{-0.185, -0.134, 0.266, 0.098, -0.571, 0.566, 0.023, -0.006} ,
{-0.168, 0.170, -0.023, 0.073, 0.587, -1.000, 0.563, -0.025} ,
{0.179, -0.107, 0.158, -0.166, 0.075, 0.331, -0.649, 0.332} ,
{0.200, 0.077, -0.088, -0.124, 0.095, -0.031, 0.335, -0.346} ,
};
uint16_t neutral_pos_115[16] = {510,   506,   512,   498,   512,   519,   515,   519,   503,   512,  511,   513,   515,   508,   503,   510};


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

float sigma_advanced_X_108 = 0.1187;// scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_108{
{-0.495, 0.093, 0.245, -0.274, 0.029, 0.274} ,
{0.396, -1.000, 0.546, -0.037, -0.044, 0.110} ,
{0.105, 0.461, -0.750, 0.316, 0.221, -0.400} ,
{-0.415, 0.018, 0.369, -0.720, 0.644, 0.060} ,
{0.086, -0.052, -0.102, 0.486, -0.821, 0.340} ,
{0.175, 0.070, -0.311, 0.108, 0.260, -0.350}
};
uint16_t neutral_pos_108[12] = {512,   513,   510,   510,   513,   508,  514,   510,   509,   510,   513,   512};


float sigma_advanced_X_110 = 0.1206;// scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_110{
{-0.490, 0.100, 0.227, -0.308, 0.074, 0.287} ,
{0.428, -1.000, 0.550, -0.051, -0.002, 0.088} ,
{0.134, 0.391, -0.697, 0.280, 0.264, -0.437} ,
{-0.449, 0.061, 0.343, -0.719, 0.579, 0.089} ,
{0.036, 0.007, -0.097, 0.456, -0.786, 0.329} ,
{0.214, 0.039, -0.294, 0.156, 0.209, -0.377} ,
};
uint16_t neutral_pos_110[12] = {510,   514,   512,   508,   510,   509,   513,   511,   509,   511,   514,   510};



std::vector<std::vector<uint8_t>> limbs_X_4{
    {5,4},
    {3,2},
    {1,0},
    {7,6}
};

std::vector<std::vector<bool>>  changeDirs_X_4{
    {false,false},
    {false,false},
    {true,true},
    {true,true}
};

std::vector<bool>  changeDirs_X_Yaw_4{true,true,true,true};

float sigma_advanced_X_104 = 0.1239;// scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_104{
{-1.000, 0.733, -0.695, 0.806} ,
{0.651, -0.973, 0.892, -0.650} ,
{-0.861, 0.801, -0.886, 0.795} ,
{0.697, -0.778, 0.755, -0.764} ,
};
uint16_t neutral_pos_104[8] = {513, 509, 510, 512, 509, 510, 513, 512};


float sigma_advanced_X_105 = 0.1224; // scaled for 50% of 0.5Hz
std::vector<std::vector<float>> inverse_map_X_105{
{-0.959, 0.732, -0.652, 0.753} ,
{0.711, -1.000, 0.793, -0.680} ,
{-0.858, 0.808, -0.892, 0.809} ,
{0.565, -0.732, 0.658, -0.816} ,
};
uint16_t neutral_pos_105[8]=
{519, 512, 508, 514, 503, 506, 521, 518};
