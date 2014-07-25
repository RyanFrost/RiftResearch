clear all;
close all;

A = load('mydatarift.txt');
%A = load('chase_30.txt');

motorv_int = A(:,1);
lc1_lbs = A(:,2);    
lc2_lbs = A(:,3);
ard_time = A(:,4);
tspeed_d = A(:,5);
xd = A(:,6);
xact = A(:,7);
xf = A(:,8);
xmid  = A(:,9);
perturb = A(:,10);
theta1 = A(:,11); %encoder angle
Kd = A(:,12);
Kact = A(:,13);
force_b = A(:,14);
elapsed = A(:,15);
torso_1_x   = A(:,16);
hip_1_x     = A(:,17);
knee_1_x    = A(:,18);
ankle_1_x   = A(:,19);
toe_1_x     = A(:,20);
torso_1_y   = A(:,21);
hip_1_y     = A(:,22);
knee_1_y    = A(:,23);
ankle_1_y   = A(:,24);
toe_1_y     = A(:,25);
torso_1_z   = A(:,26);
hip_1_z     = A(:,27);
knee_1_z    = A(:,28);
ankle_1_z   = A(:,29);
toe_1_z     = A(:,30);
torso_2_x   = A(:,31);
hip_2_x     = A(:,32);
knee_2_x    = A(:,33);
ankle_2_x   = A(:,34);
toe_2_x     = A(:,35);
torso_2_y   = A(:,36);
hip_2_y     = A(:,37);
knee_2_y    = A(:,38);
ankle_2_y   = A(:,39);
toe_2_y     = A(:,40);
torso_2_z   = A(:,41);
hip_2_z     = A(:,42);
knee_2_z    = A(:,43);
ankle_2_z   = A(:,44);
toe_2_z     = A(:,45);
% force sensors
f1 = A(:,46);
f2 = A(:,47);
f3 = A(:,48);
f4 = A(:,49);
f5 = A(:,50);
f6 = A(:,51);
f7 = A(:,52);
f8 = A(:,53);
numEMG = A(:,54);
cycle = A(:,55);
time_vst_absolute = A(:,59);
zero_time_absolute = A(:,58);

% make sure zero time is accurate
t0 = zero_time_absolute(2);

%diff(time_vst_absolute)
time = time_vst_absolute - t0;
%time = time - time(1);

clear t0;






%% butter filter




plotyy(time,xd,time(1:end-1),diff(time))

figure(2)
plotyy(time,xd,time,xf)
figure(3)
plotyy(time,xf,time,perturb)
