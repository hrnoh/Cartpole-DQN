% HParams.m : Hyper parameters class
%
% INPUTS :
%          NONE
% OUTPUTS :
%          NONE
%
% EXAMPLE : 
%          HParams.mu
%
%   created  : 2019/06/17
%   modified : 2019/06/17

classdef HParams < handle
    
    properties (Constant)
        maxEpoch = 10000;
        maxIttr = 1000;
        
        % Q Network parameters
        mu = 0.01;
        epochs = 10;
        mu_dec = 0.8;
        
        % Agent parameters
        gamma = 0.99;
        batch = 1;
        epsilon = 0.8;
        epsilonDecay = 0.999;
        testtotalReward = [];
        targetUpdate = 2;
       
        bufferSize = 1024;
        sampleSize = 256;
        simChoice;
    end

end

