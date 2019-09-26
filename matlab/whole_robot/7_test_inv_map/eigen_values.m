%gait plot

clear; close all; clc;
addpath('../4_locomotion');

inv_map = load_inverse_map("X","115");

eig(inv_map)