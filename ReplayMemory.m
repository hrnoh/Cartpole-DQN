% ReplayMemory.m : A class that stores transitions
%
% INPUTS :
%          capacity - replay memory transition
%
% OUTPUTS :
%          NONE
%
% EXAMPLE : 
%          repmem = ReplayMemory(5)
%
%   created  : 2019/06/03
%   modified : 2019/06/03

classdef ReplayMemory < handle
    properties
        capacity;
        memory = [];
    end
    methods
        % Initialization
        function obj = ReplayMemory(capacity)
            obj.capacity = capacity;
            obj.memory = [];
        end
        
        % push memory
        function obj = push(obj, transition)
            if length(obj.memory) < obj.capacity
                obj.memory = [obj.memory; transition]; 
            else
                obj.memory(1, :) = [];
                obj.memory = [obj.memory; transition];
            end
        end
        
        % pop memory with ramdomly select
        function [samples] = sample(obj, batchSize)
            if length(obj.memory) < batchSize
                samples = obj.memory;
            else
                % ramdomly selected sample data from memory(reduced overfitting)
                indecies = randperm(length(obj.memory), batchSize);
                samples = obj.memory(indecies, :);
            end
        end
    end
end
            