#include <vector> //takes a lot of space,
//could be improved with pointers

#define MAP_USED 94

//with recordID 86
float sigma_advanced_X_86  = 0.150;  //16N, 0.5 Hz, scale 0.5 (GRF_term)
std::vector<std::vector<float>> inverse_map_X_86{
{-0.703, 0.959,-0.713, 0.738} ,
{ 1.000,-0.727, 0.858,-0.858} ,
{-0.481, 0.506,-0.566, 0.603} ,
{ 0.543,-0.552, 0.781,-0.631}
 };

float sigma_advanced_Y_86  = 0.141; //16N, 0.5 Hz, scale 0.5 (GRF_term)
std::vector<std::vector<float>> inverse_map_Y_86{ 
{-0.446, 0.643,-0.674, 0.463} ,
{ 0.907,-0.849, 0.814,-0.895} ,
{-0.977, 1.000,-0.952, 0.943} ,
{ 0.464,-0.619, 0.657,-0.537}
 };


//with recordID 87
float sigma_advanced_X_87  = 0.136; //16N, 0.5 Hz, scale 0.5 (GRF_term)
std::vector<std::vector<float>> inverse_map_X_87{
{-0.722, 0.790, -0.589, 0.628} ,
{0.858, -0.668, 0.801, -0.749} ,
{-0.801, 0.752, -0.734, 0.976} ,
{0.779, -0.784, 1.000, -0.771} 
 };
float sigma_advanced_Y_87  = 0.131; //16N, 0.5 Hz, scale 0.5 (GRF_term)
std::vector<std::vector<float>> inverse_map_Y_87{ 
{-0.635, 0.825,-0.779, 0.590} ,
{ 0.941,-0.844, 0.853,-0.970} ,
{-0.856, 0.716,-0.767, 0.872} ,
{ 0.678,-1.000, 0.926,-0.763} };

//with recordID 88
float sigma_advanced_X_88  = 0.114; //16N, 0.5 Hz, scale 0.5 (GRF_term)
std::vector<std::vector<float>> inverse_map_X_88{
{-0.836, 0.832, -0.647, 0.701} ,
{0.877, -0.797, 0.879, -0.890} ,
{-0.820, 0.823, -0.868, 0.896} ,
{0.786, -0.789, 1.000, -0.948}
 };
float sigma_advanced_Y_88  = 0.132; //16N, 0.5 Hz, scale 0.5 (GRF_term)
std::vector<std::vector<float>> inverse_map_Y_88{ 
{-0.558, 0.806, -0.790, 0.609} ,
{0.914, -0.783, 0.736, -0.854} ,
{-1.000, 0.891, -0.889, 0.927} ,
{0.685, -0.877, 0.872, -0.755}
};
float sigma_advanced_Yaw_88  = 0.132; //16N, 0.5 Hz, scale 0.5 (GRF_term)
std::vector<std::vector<float>> inverse_map_Yaw_88{ 
{-0.558, 0.806, -0.790, 0.609} ,
{0.914, -0.783, 0.736, -0.854} ,
{-1.000, 0.891, -0.889, 0.927} ,
{0.685, -0.877, 0.872, -0.755}
};

//with recordID 89
float sigma_advanced_X_89  = 0.187;  //22.5N, 0.5 Hz, scale 1 (GRF_term)
std::vector<std::vector<float>> inverse_map_X_89{
{-0.930, 0.606, 0.125, -0.544, 0.259, 0.541} ,
{0.633, -0.563, 0.389, 0.303, -0.494, -0.050} ,
{-0.103, 0.363, -0.586, 0.322, -0.007, 0.133} ,
{-0.465, 0.271, 0.603, -0.978, 0.705, 0.028} ,
{0.227, -0.408, 0.071, 0.492, -0.560, 0.322} ,
{0.440, 0.034, 0.191, -0.087, 0.599, -1.000}
 };

 //with recordID 94
float sigma_advanced_X_94  = 0.192; //29N, 0.5 Hz, scale 1 (GRF_term)
std::vector<std::vector<float>> inverse_map_X_94{
{-0.498, 0.107, 0.143, 0.018, -0.240, 0.041, 0.069, 0.462} ,
{0.172, -0.539, 0.425, -0.013, 0.086, -0.235, -0.036, 0.199} ,
{0.040, 0.561, -0.800, 0.215, 0.116, -0.129, 0.204, -0.082} ,
{-0.107, 0.067, 0.209, -0.352, 0.172, 0.058, 0.103, 0.031} ,
{-0.193, 0.089, 0.077, 0.100, -0.349, 0.165, 0.224, -0.061} ,
{0.155, -0.137, -0.164, 0.195, 0.179, -0.316, 0.219, -0.026} ,
{0.109, -0.129, 0.070, 0.050, 0.041, 0.341, -0.672, 0.232} ,
{0.539, 0.054, -0.068, 0.198, -0.133, 0.076, 0.336, -1.000}
 };
 

 /*
 //float sigma_advanced_X_94  = 0.10;
float sigma_advanced_X_94  = 0.054;
std::vector<std::vector<float>> inverse_map_X_94{
{-1.000, -0.000, -0.000, -0.000, -0.000, -0.000, -0.000, -0.000} ,
{-0.000, -1.000, -0.000, -0.000, -0.000, -0.000, -0.000, -0.000} ,
{-0.000, -0.000, -1.000, -0.000, -0.000, -0.000, -0.000, -0.000} ,
{-0.000, -0.000, -0.000, -1.000, -0.000, -0.000, -0.000, -0.000} ,
{-0.000, -0.000, -0.000, -0.000, -1.000, -0.000, -0.000, -0.000} ,
{-0.000, -0.000, -0.000, -0.000, -0.000, -1.000, -0.000, -0.000} ,
{-0.000, -0.000, -0.000, -0.000, -0.000, -0.000, -1.000, -0.000} ,
{-0.000, -0.000, -0.000, -0.000, -0.000, -0.000, -0.000, -1.000} 
 };
 */

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
    {1,0}, //that one is actually bad, it should be {1,0}
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

std::vector<std::vector<uint8_t>> limbs_X_8legs{
    {0,8},
    {9,7},
    {4,3},
    {2,1},
    {13,12}, 
    {15,14},
    {11,10},
    {6,5},
};

std::vector<std::vector<bool>> changeDirs_X_8legs{
    {false,true},
    {true,false},
    {true,true},
    {true,true},
    {true,false},
    {false,true},
    {false,false},
    {false,false}
};

