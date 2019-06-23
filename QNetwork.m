% QNetwork.m : Q Network class
%
% INPUTS :
%          input size : input layer size
%          hidden sizes : hidden layer sizes
%          output size : output layer size
%          epochs : The number of epochs
%          mu : learning rate
%          mu_dec : learning rate decay rate
%          QNetwork hidden layer list (ex. [10 20])
%
% OUTPUTS :
%          QNetwork object
%
% EXAMPLE : 
%          net = QNetwork([10 20])
%
%   created  : 2019/06/17
%   modified : 2019/06/17

classdef QNetwork < handle
   properties (Access = 'private')
       net = [];
   end
   
   methods (Access = 'public')
       function obj = QNetwork(inputSize, hiddenSizes, outputSize)
           obj.net = fitnet(hiddenSizes, 'trainlm');
           obj.net.trainParam.mu = HParams.mu;
           obj.net.trainParam.epochs = HParams.epochs;
           obj.net.trainParam.mu_dec = HParams.mu_dec;
           obj.net.trainParam.showWindow = false;
           obj.net.trainParam.max_fail = 1000;
           obj.net = train(obj.net, rand(inputSize, 25), rand(outputSize, 25));
       end
       
       % get network parameters
       function params = getParams(obj)
           params = getwb(obj.net);
       end
       
       % set network parameters
       function setParams(obj, params)
           obj.net = setwb(obj.net, params);
       end
       
       %train
       function trainNetwork(obj, inputs, targets)
           obj.net = train(obj.net, inputs, targets);
       end
       
       % prediction
       function out = predict(obj, input)
           out = obj.net(input);
       end
   end
end