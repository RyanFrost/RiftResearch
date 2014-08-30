function loadKinematics( fileName )
%LOADKINEMATICS Summary of this function goes here
%   Detailed explanation goes here


A = load(fileName);

tspeed_d = A(:,5);
xd = A(:,6);
perturb = A(:,8);
theta1 = A(:,9); %encoder angle
Kd = A(:,10);
Kact = A(:,11);
force_b = A(:,12);
cycle = A(:,15);
VSTtime = A(:,16);
zeroTime = A(:,17);
hipAngleLeft = -A(:,18);
kneeAngleLeft = -A(:,19);
ankleAngleLeft = -A(:,20);
hipAngleRight= A(:,21);
kneeAngleRight= A(:,22);
ankleAngleRight= A(:,23);
xf = A(:,24);

movingForward = A(:,26);
distance = A(:,27);
currentPatch = A(:,28);
patchType = A(:,29);

clear A;

matFile = strrep(fileName,'.txt','.mat');
save(matFile);
end

