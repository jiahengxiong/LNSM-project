clc;
clear all;
close all;

load("tunnel_experiment_slalom.mat");

meas_tdoa_subset = meas_tdoa(1:9, :);
num_nan = sum(isnan(meas_tdoa_subset), 'all');

total_elements = numel(meas_tdoa_subset);


nan_ratio = num_nan / total_elements;

