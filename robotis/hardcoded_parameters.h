#include <vector> //takes a lot of space,
//could be improved with pointers

#define MAP_USED 105

std::vector<std::vector<uint8_t>> limbs_X{
    {5,4},
    {3,2},
    {1,0},
    {7,6}
};

std::vector<std::vector<bool>>  changeDirs_X{
    {false,false},
    {false,false},
    {true,true},
    {true,true}
};

std::vector<bool>  changeDirs_X_Yaw{true,true,true,true};

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

/*
#define MAP_USED 101

std::vector<std::vector<uint8_t>> limbs_X{
    {0,4},
    {5,3},
    {2,1},
    {6,7}
};

std::vector<std::vector<bool>>  changeDirs_X{
    {false,true},
    {true,false},
    {true,true},
    {false,false}
};

std::vector<bool>  changeDirs_X_Yaw{true,true,true,true};

float sigma_advanced_X_101 = 0.1462;

std::vector<std::vector<float>> inverse_map_X_101{
{-0.799, 1.000, -0.784, 0.743} ,
{0.884, -0.669, 0.667, -0.748} ,
{-0.524, 0.512, -0.522, 0.597} ,
{0.604, -0.608, 0.808, -0.697} ,
};
*/