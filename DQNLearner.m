% DQNLearner.m : A class that learn Deep Q Networks class
%
% INPUTS :
%          Policy network
%          Target network
%
% OUTPUTS :
%          None
%
% EXAMPLE : 
%          None
%
%   created  : 2019/06/17
%   modified : 2019/06/17

classdef DQNLearner < handle
   properties (Access = 'private')
       policyNet;
       targetNet;
       replayMemory;
       env;
       
       epsilon;
       epsilonDecay;
       gamma;
       totalReward;
       bonus;
       maxIttr;
       updateCount;
       
       Q;
       
       epochAvgReward = [];
       epochLength = [];
       testTotalReward = [];
   end
   
   methods (Access = 'public')
       function obj = DQNLearner()
           % replay memory
           obj.replayMemory = ReplayMemory(HParams.bufferSize);
           
           % Hyper params
           obj.epsilon = HParams.epsilon;
           obj.epsilonDecay = HParams.epsilonDecay;
           obj.gamma = HParams.gamma;
           obj.maxIttr = HParams.maxIttr;
           obj.updateCount = 0;
           
           % Environment (cart-pole)
           obj.env = Environment([0 0 0 0], true);
           [state, action, reward, next_state, done] = obj.env.doAction(1);
           obj.replayMemory.push([state, action, reward, next_state, done]);
           
           % build Q networks
           obj.policyNet = QNetwork(length(state), [30 30], obj.env.actionCardinality);
           obj.targetNet = QNetwork(length(state), [30 30], obj.env.actionCardinality);
           obj.targetNet.setParams(obj.policyNet.getParams());
       end
       
       function train(obj)
           for epochs = 1:HParams.maxEpoch
               % Reset the parameters
               obj.totalReward = 0;
               obj.bonus = 0;
               
               % epsilon decay
               obj.epsilon = obj.epsilon * obj.epsilonDecay;
               
               % initialize environment
               obj.env.randomInitState();
               
               for itr_no = 1:obj.maxIttr
                   % step#1 in DQN Algorithm
                   cartForce = obj.selectAction();
                   % step#2 in DQN Algorithm
                   [state, action, reward, next_state, done] = obj.env.doAction(cartForce);
                   % step#3 in DQN Algorithm
                   obj.replayMemory.push([state, action, reward, next_state, done]);
                   obj.env.state = next_state;
                   
                   % Aggregate the total reward for every epoch
                   obj.totalReward = obj.totalReward + reward;
                   
                   if obj.env.resetCode
                       break;
                   end
               end
               
               % Store the average reward and epoch length for plotting
               obj.epochAvgReward(epochs) = obj.totalReward / itr_no;
               obj.epochLength(epochs) = itr_no;
               
               if itr_no == obj.maxIttr
                   disp(['Episode', num2str(epochs), ':Successful Balance Achieved! - Average Reward:', num2str(obj.epochAvgReward(epochs))])
               elseif obj.env.resetCode == true
                   disp(['Episode', num2str(epochs), ', steps(', num2str(itr_no), '/',num2str(obj.maxIttr), ') ',  ': Reset Condition reached!! - Average Reward:', num2str(obj.epochAvgReward(epochs))]);
                   obj.env.resetCode = false;
               end
               
               % step#4 in DQN Algorithm
               obj.trainOnMemory() % Batch training using replay memory
           end
       end
       
       % DQN Test
       function DQNTest(obj, simLength)
           obj.env.simOnOff = 1;
           obj.testTotalReward = 0;
           obj.epsilon = -Inf;
           obj.env.initSim();
           obj.env.randomInitState();
           
           for testIter = 1:simLength
               cartForce = obj.selectAction();
               [~, ~, reward, next_state, done] = obj.env.doAction(cartForce);
               obj.env.state = next_state;
               obj.testTotalReward = obj.testTotalReward + reward;
               if done
                   break;
               end
           end
       end
   end
   
   methods (Access = 'private')
       % generate Policy Q values
       function Qval = genQValue(obj, state)
           Qval = obj.policyNet.predict(state');
       end
       
       % generate Target Q values
       function Qval = genTargetQValue(obj, state)
           Qval = obj.targetNet.predict(state');
       end
       
       function selectedAction = selectAction(obj)
           % epsilon greedy
           if rand <= obj.epsilon
               actionIndex = randi(obj.env.actionCardinality, 1);
           else
               obj.Q = obj.genQValue(obj.env.state);
               [~, actionIndex] = max(obj.Q);
           end
               
           selectedAction = obj.env.actions(actionIndex);
       end
       
       % replay train
       function trainOnMemory(obj)
           samples = obj.replayMemory.sample(HParams.sampleSize);
           stateBatch = samples(:, [1:4]);
           actionBatch = samples(:, 5);
           rewardBatch = samples(:, 6);
           nextstateBatch = samples(:, [7:10]);
           doneBatch = samples(:, 11);
           valueBatch = zeros(length(obj.env.actions), 1);
           
           for count = 1:size(samples, 1)
               value = zeros(2, 1);
               aIdx = find(~(obj.env.actions - actionBatch(count)));
               % calc reward
               if doneBatch(count)
                   value(aIdx) = rewardBatch(count);
               else
                   value(aIdx) = rewardBatch(count) + obj.gamma * max(obj.genTargetQValue(nextstateBatch(count, :))); 
               end
               valueBatch(:, count) = value;
           end  
           
           % main network update
           obj.policyNet.trainNetwork(stateBatch', valueBatch);           
           
           % network copy every wanted episode number
           obj.updateCount = obj.updateCount + 1;
           if mod(obj.updateCount, HParams.targetUpdate) == 0
               disp('targetNet Update!') % update target network
               obj.targetNet.setParams(obj.policyNet.getParams());
           end
       end
   end
end