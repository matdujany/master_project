#include <vector> //takes a lot of space,
//could be improved with pointers

#define MAP_USED 88

//with recordID 86
float sigma_advanced_X_86  = 0.12;
std::vector<std::vector<float>> inverse_map_X_86{
{-0.703, 0.959,-0.713, 0.738} ,
{ 1.000,-0.727, 0.858,-0.858} ,
{-0.481, 0.506,-0.566, 0.603} ,
{ 0.543,-0.552, 0.781,-0.631}
 };

float sigma_advanced_Y_86  = 0.12;
std::vector<std::vector<float>> inverse_map_Y_86{ 
{-0.446, 0.643,-0.674, 0.463} ,
{ 0.907,-0.849, 0.814,-0.895} ,
{-0.977, 1.000,-0.952, 0.943} ,
{ 0.464,-0.619, 0.657,-0.537}
 };


//with recordID 87
float sigma_advanced_X_87  = 0.12;
std::vector<std::vector<float>> inverse_map_X_87{
{-0.722, 0.790, -0.589, 0.628} ,
{0.858, -0.668, 0.801, -0.749} ,
{-0.801, 0.752, -0.734, 0.976} ,
{0.779, -0.784, 1.000, -0.771} 
 };
float sigma_advanced_Y_87  = 0.12;
std::vector<std::vector<float>> inverse_map_Y_87{ 
{-0.635, 0.825,-0.779, 0.590} ,
{ 0.941,-0.844, 0.853,-0.970} ,
{-0.856, 0.716,-0.767, 0.872} ,
{ 0.678,-1.000, 0.926,-0.763} };

//with recordID 88
float sigma_advanced_X_88  = 0.11;
std::vector<std::vector<float>> inverse_map_X_88{
{-0.836, 0.832, -0.647, 0.701} ,
{0.877, -0.797, 0.879, -0.890} ,
{-0.820, 0.823, -0.868, 0.896} ,
{0.786, -0.789, 1.000, -0.948}
 };
float sigma_advanced_Y_88  = 0.13;
std::vector<std::vector<float>> inverse_map_Y_88{ 
{-0.558, 0.806, -0.790, 0.609} ,
{0.914, -0.783, 0.736, -0.854} ,
{-1.000, 0.891, -0.889, 0.927} ,
{0.685, -0.877, 0.872, -0.755}
};
float sigma_advanced_Yaw_88  = 0.13;
std::vector<std::vector<float>> inverse_map_Yaw_88{ 
{-0.558, 0.806, -0.790, 0.609} ,
{0.914, -0.783, 0.736, -0.854} ,
{-1.000, 0.891, -0.889, 0.927} ,
{0.685, -0.877, 0.872, -0.755}
};

//with recordID 89
float sigma_advanced_X_89  = 0.13;
std::vector<std::vector<float>> inverse_map_X_89{
{-0.930, 0.606, 0.125, -0.544, 0.259, 0.541} ,
{0.633, -0.563, 0.389, 0.303, -0.494, -0.050} ,
{-0.103, 0.363, -0.586, 0.322, -0.007, 0.133} ,
{-0.491, 0.121, 0.655, -0.834, 0.543, 0.024} ,
{0.227, -0.408, 0.071, 0.492, -0.560, 0.322} ,
{0.440, 0.034, 0.191, -0.087, 0.599, -1.000}
 };


std::vector<std::vector<uint8_t>> limbs_X{
    {5,4},
    {7,6},
    {1,0},
    {3,2}
};

std::vector<std::vector<bool>>  changeDirs_X{
    {false,false},
    {true,true},
    {true,true},
    {false,false}
};

std::vector<std::vector<uint8_t>> limbs_Y{
    {4,5},
    {6,7},
    {0,1},
    {2,3}
};

std::vector<std::vector<bool>> changeDirs_Y{
    {true,true},
    {true,false},
    {true,true},
    {true,false}
};


std::vector<std::vector<uint8_t>> limbs_Yaw{
    {4,5},
    {6,7},
    {0,1},
    {2,3}
};

std::vector<std::vector<bool>> changeDirs_Yaw{
    {true,true},
    {true,false},
    {false,true},
    {false,false}
};

std::vector<std::vector<uint8_t>> limbs_X_6legs{
    {9,8},
    {11,10},
    {3,2},
    {0,1}, //that one is actually bad
    {7,6},
    {5,4}
};

std::vector<std::vector<bool>> changeDirs_X_6legs{
    {false,false},
    {true,true},
    {true,true},
    {true,true},
    {false,false},
    {false,false}
};

