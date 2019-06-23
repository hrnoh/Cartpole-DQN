% main.m : A script for DQN demo
%
% INPUTS :
%          NONE
% OUTPUTS :
%          NONE
%
% EXAMPLE : 
%          NONE
%
%   created  : 2019/06/17
%   modified : 2019/06/17
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialization
clear all; clc; close all;

% Create DQNLearner
CartPoleQlearn = DQNLearner();

% Training
CartPoleQlearn.train();

% Testing
test_simSteps = 4000;
CartPoleQlearn.DQNTest(test_simSteps);