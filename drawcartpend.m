% drawcartpend.m : plot cart-pole function
%
% INPUTS :
%          state : state
%          m : cart mass
%          M : pole mass
%          L : length
% OUTPUTS :
%          NONE
%
% EXAMPLE : 
%          NONE
%
%   created  : 2019/06/17
%   modified : 2019/06/17
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawcartpend(state,m,M,L)

% kinematics
x = state(1);
th = state(3);

% dimensions
W = 1*sqrt(M/5);  % cart width
H = .5*sqrt(M/5); % cart height
wr = .2; % wheel radius
mr = .3*sqrt(m); % mass radius

% positions
state = wr/2+H/2; % cart vertical position
w1x = x-.9*W/2;
w1y = 0;
w2x = x+.9*W/2-wr;
w2y = 0;

px = x - L*sin(-th);
py = state + L*cos(-th);

plot([-10 10],[0 0],'w','LineWidth',2)
hold on
rectangle('Position',[x-W/2,state-H/2,W,H],'Curvature',.1,'FaceColor',[1 0.1 0.1],'EdgeColor',[1 1 1])
rectangle('Position',[w1x,w1y,wr,wr],'Curvature',1,'FaceColor',[1 1 1],'EdgeColor',[1 1 1])
rectangle('Position',[w2x,w2y,wr,wr],'Curvature',1,'FaceColor',[1 1 1],'EdgeColor',[1 1 1])

plot([x px],[state py],'w','LineWidth',2)

rectangle('Position',[px-mr/2,py-mr/2,mr,mr],'Curvature',1,'FaceColor',[.3 0.3 1],'EdgeColor',[1 1 1])

screen = get(0, 'ScreenSize');
xlim([-10 10]);
ylim([-5 5]);
set(gca,'Color','k','XColor','w','YColor','w')
set(gcf,'Position',[screen(3)/2-400 screen(4)/2-200 800 400])
set(gcf,'Color','k')
set(gcf,'InvertHardcopy','off')   

drawnow
hold off