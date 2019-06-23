% Environment.m : Cart-pole environment class
%
% INPUTS :
%         start points : state param [ x, x', theta, theta']
%         simChoice : cart-pole simultes on
%
% OUTPUTS :
%          QNetwork object
%
% EXAMPLE : 
%          repmem = QNetwork([10 20])
%
%   created  : 2019/06/17
%   modified : 2019/06/17

classdef Environment < handle
    
    properties (Access = 'public')
        
        state = [];
        timeStep = [];
        massCart = [];
        massPole = [];
        poleLength = [];
        gravity = [];
        substeps = [];
        actionCardinality = [];
        actions = [];
        pendLimitAngle = [];
        cartLimitRange = [];
        reward = [];
        bonus = [];
        goal = [];
        resetCode = [];
        simOnOff;
        panel;
        cart;
        pole
        dot;
        arrow;
        totalMass;
        polemassLeng;
    end
    
    methods (Access = 'public')
        
        function obj = Environment(startPoint,simChoice)
            
            if nargin == 0                
                obj.state = [0 0 0 0];
                obj.simOnOff = 0;                
            else                
                obj.state = startPoint;
                obj.simOnOff = simChoice;                
            end
            obj.timeStep = 0.02;
            obj.massCart = 5;
            obj.massPole = 0.5;
            obj.totalMass = obj.massCart + obj.massPole;
            obj.gravity = 9.81;
            obj.poleLength = 1;
            obj.polemassLeng = obj.massPole * obj.poleLength;
            obj.substeps = 1;
            obj.reward = 0;
            obj.bonus = 0;
            obj.actions = [-1 1];
            obj.actionCardinality = length(obj.actions);
            obj.pendLimitAngle = deg2rad(45);
            obj.cartLimitRange = 10;
            
            if obj.simOnOff == 1
                obj.initSim()
            end
            
        end
        
        function [state,Action,reward,next_state,done] = doAction(obj,Action)
            
            state = obj.state;
            next_state = obj.getNextState(Action);
            
            % debug print
            if Action == 1
                direction = 'right';
            else
                direction = 'left';
            end
            disp(['direction : ', direction, ' x : ', num2str(state(1)), ' theta : ', num2str(state(3))]);
            
            % return value update : reward, done/ simulate cart-pole
            obj.checkIfGoalReached();            
            reward = obj.reward;            
            done = obj.resetCode;
            
            if obj.simOnOff == 1
                obj.simCartpole(next_state);
            end
            
        end
        
        % initialization state variables
        function randomInitState(obj)
            obj.state = [0 0 0 0.1*rand];
        end
        
        % update reward & terminal value
        function checkIfGoalReached(obj)
            
            obj.generateReward();
               
            if abs(obj.state(3)) < deg2rad(5)
               obj.bonus = 10;
               obj.goal = true;
               obj.resetCode = false;
            else
               obj.bonus = 1;
               obj.resetCode = false;
            end
            
            if abs(obj.state(3)) >  obj.pendLimitAngle                
               obj.bonus = 0;     %punishement for falling down
               obj.resetCode = true;
            end
               
            if abs(obj.state(1)) > obj.cartLimitRange                
               obj.bonus = 0;     %punishement for moving too far
               obj.resetCode = true;
            end
            
            obj.reward = obj.reward + obj.bonus;
            obj.goal = false;
            obj.bonus = 0;
        end
        
        function initSim(obj)            
            drawcartpend(obj.state, obj.massPole, obj.massCart, obj.poleLength);
        end
    end
    
    methods(Access = 'private')
        
        % update state values using kinematics equation
        function next_state = getNextState(obj, action)
            force = action(1) * 50;
            x = obj.state(1);
            x_dot = obj.state(2);
            theta = obj.state(3);
            theta_dot = obj.state(4);

            costheta = cos(theta);
            sintheta = sin(theta);

            % calculate angular velocity, velocity
            temp = (force + obj.polemassLeng * theta_dot * theta_dot * sintheta) / obj.totalMass;
            thetaacc = (obj.gravity * sintheta - costheta * temp) / (obj.poleLength * (4.0/3.0 - obj.massPole * costheta * costheta / obj.totalMass));
            xacc = temp - obj.polemassLeng * thetaacc * costheta / obj.totalMass;

            % update state param
            x = x + obj.timeStep * x_dot;
            x_dot = x_dot + obj.timeStep * xacc;
            theta = theta + obj.timeStep * theta_dot;
            theta_dot = theta_dot + obj.timeStep * thetaacc;
            
            next_state = [x, x_dot, theta, theta_dot];
        end
        
        % get pre-reward(always 0)
        function generateReward(obj)            
            obj.reward = 0;
        end
        
        % simulate cart-pole
        function simCartpole(obj, state)            
            drawcartpend(state, obj.massPole, obj.massCart, obj.poleLength);
        end        
    end    
end