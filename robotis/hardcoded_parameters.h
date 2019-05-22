#include <vector> //takes a lot of space,
//could be improved with pointers

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
