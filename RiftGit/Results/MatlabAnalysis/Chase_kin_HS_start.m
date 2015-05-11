%--------------------------------------------------
%
% NDI in front of subject, 10 markers
%
%--------------------------------------------------

clear all;
%close all;
clc;

%% Load in data from .txt files

%---( Match w/ file )---------
bws = 30;
subject = 'chase';
%
A = load([subject,'_data_',num2str(bws),'.txt']); % main data
B = load([subject,'_zero_angles_',num2str(bws),'.txt']); % zero angles
% ------------------------------------------

time_vst_absolute = A(:,59);
start_aq_gtod = A(:,61);
asdf = time_vst_absolute - start_aq_gtod(1);

motorv_int = A(:,1);
lc1_lbs = A(:,2);    
lc2_lbs = A(:,3);
ard_time = A(:,4);
tspeed_d = A(:,5);
tspeed_max = max(tspeed_d);

max_speed_ind = find(tspeed_d==tspeed_max,1,'first');

% Cut off data before/after operating speed
%ind1 = find(tspeed_d==max(tspeed_d),1,'first');
%ind2 = find(tspeed_d==max(tspeed_d),1,'last');
ind1 = 1;
ind2 = length(tspeed_d);

xd = A(ind1:ind2,6);
xact = A(ind1:ind2,7);
xf = A(ind1:ind2,8);
xmid  = A(ind1:ind2,9);
perturb = A(ind1:ind2,10);
theta1 = A(:,11); %encoder angle
Kd = A(ind1:ind2,12);
Kact = A(ind1:ind2,13);
force_b = A(ind1:ind2,14);
elapsed = A(ind1:ind2,15);
torso_1_x   = A(ind1:ind2,16);
hip_1_x     = A(ind1:ind2,17);
knee_1_x    = A(ind1:ind2,18);
ankle_1_x   = A(ind1:ind2,19);
toe_1_x     = A(ind1:ind2,20);
torso_1_y   = A(ind1:ind2,21);
hip_1_y     = A(ind1:ind2,22);
knee_1_y    = A(ind1:ind2,23);
ankle_1_y   = A(ind1:ind2,24);
toe_1_y     = A(ind1:ind2,25);
torso_1_z   = A(ind1:ind2,26);
hip_1_z     = A(ind1:ind2,27);
knee_1_z    = A(ind1:ind2,28);
ankle_1_z   = A(ind1:ind2,29);
toe_1_z     = A(ind1:ind2,30);
torso_2_x   = A(ind1:ind2,31);
hip_2_x     = A(ind1:ind2,32);
knee_2_x    = A(ind1:ind2,33);
ankle_2_x   = A(ind1:ind2,34);
toe_2_x     = A(ind1:ind2,35);
torso_2_y   = A(ind1:ind2,36);
hip_2_y     = A(ind1:ind2,37);
knee_2_y    = A(ind1:ind2,38);
ankle_2_y   = A(ind1:ind2,39);
toe_2_y     = A(ind1:ind2,40);
torso_2_z   = A(ind1:ind2,41);
hip_2_z     = A(ind1:ind2,42);
knee_2_z    = A(ind1:ind2,43);
ankle_2_z   = A(ind1:ind2,44);
toe_2_z     = A(ind1:ind2,45);
f1 = A(ind1:ind2,46);
f2 = A(ind1:ind2,47);
f3 = A(ind1:ind2,48);
f4 = A(ind1:ind2,49);
f5 = A(ind1:ind2,50);
f6 = A(ind1:ind2,51);
f7 = A(ind1:ind2,52);
f8 = A(ind1:ind2,53);
numEMG = A(ind1:ind2,54);
cycle = A(ind1:ind2,55);

elapsed_from_beg = A(:,15);
xf_from_beg = A(:,8);
xf_from_beg(end+1) = xf_from_beg(end);

%%
% time 0 when at max treadmill speed
time = zeros(size(elapsed));
time(1)=0;
elapsed(1)=elapsed(2); % overwrite super high value for first iteration
for i = 1:length(elapsed)-1;
    time(i+1) = time(i) + elapsed(i);
    
end

% time 
time_from_beg = zeros(size(elapsed_from_beg));
time_from_beg(1) = 0;
elapsed_from_beg(1) = elapsed_from_beg(2);
for i = 1:length(elapsed_from_beg)
    time_from_beg(i+1) = time_from_beg(i) + elapsed_from_beg(i);
end

% fix perturb and Kd due to missing elseif statements in vst.cpp
% not need except for Danielle
for i = 2:length(perturb)-1
    if perturb(i) > perturb(i-1) && perturb(i-1) > 0
        perturb(i) = perturb(i-1);
    end
    if abs(Kd(i) - Kd(i-1)) > 1 && abs(Kd(i) - Kd(i+1)) > 1
        Kd(i) = Kd(i-1);
    end
end

unos = ones(size(time));
cero = zeros(size(time));



time = asdf;
clear asdf

clear ind1 ind2


%% Create position vectors for markers

% 1 is perturbed (left side)
% 2 is unperturbed (right side)

% Matrices of marker positions
toe1    = [toe_1_x      toe_1_y     toe_1_z     unos];
ankle1  = [ankle_1_x    ankle_1_y   ankle_1_z   unos];
knee1   = [knee_1_x     knee_1_y    knee_1_z    unos];
hip1    = [hip_1_x      hip_1_y     hip_1_z     unos];
torso1  = [torso_1_x    torso_1_y   torso_1_z   unos];

toe2    = [toe_2_x      toe_2_y     toe_2_z     unos];
ankle2  = [ankle_2_x    ankle_2_y   ankle_2_z   unos];
knee2   = [knee_2_x     knee_2_y    knee_2_z    unos];
hip2    = [hip_2_x      hip_2_y     hip_2_z     unos];
torso2  = [torso_2_x    torso_2_y   torso_2_z   unos];
%% Calculate zero angles

% x0 position in NDI (camara) frame
val = 3;

torso1_x0 = mean(B(val:end,16));
hip1_x0   = mean(B(val:end,17));
knee1_x0  = mean(B(val:end,18));
ankle1_x0 = mean(B(val:end,19));
toe1_x0   = mean(B(val:end,20));
% y0 position in NDI (camara) frame
torso1_y0 = mean(B(val:end,21));
hip1_y0   = mean(B(val:end,22));
knee1_y0  = mean(B(val:end,23));
ankle1_y0 = mean(B(val:end,24));
toe1_y0   = mean(B(val:end,25));
% z0 position in NDI (camara) frame
torso1_z0 = mean(B(val:end,26));
hip1_z0   = mean(B(val:end,27));
knee1_z0  = mean(B(val:end,28));
ankle1_z0 = mean(B(val:end,29));
toe1_z0   = mean(B(val:end,30));

torso2_x0 = mean(B(val:end,31));
hip2_x0   = mean(B(val:end,32));
knee2_x0  = mean(B(val:end,33));
ankle2_x0 = mean(B(val:end,34));
toe2_x0   = mean(B(val:end,35));
% y0 position in NDI (camara) frame
torso2_y0 = mean(B(val:end,36));
hip2_y0   = mean(B(val:end,37));
knee2_y0  = mean(B(val:end,38));
ankle2_y0 = mean(B(val:end,39));
toe2_y0   = mean(B(val:end,40));
% z0 position in NDI (camara) frame
torso2_z0 = mean(B(val:end,41));
hip2_z0   = mean(B(val:end,42));
knee2_z0  = mean(B(val:end,43));
ankle2_z0 = mean(B(val:end,44));
toe2_z0   = mean(B(val:end,45));

% create 0 angle vectors
toe1_0    = [toe1_x0     toe1_y0      toe1_z0       1];
ankle1_0  = [ankle1_x0   ankle1_y0    ankle1_z0     1];
knee1_0   = [knee1_x0    knee1_y0     knee1_z0      1];
hip1_0    = [hip1_x0     hip1_y0      hip1_z0       1];
torso1_0  = [torso1_x0   torso1_y0    torso1_z0     1];

toe2_0    = [toe2_x0     toe2_y0      toe2_z0       1];
ankle2_0  = [ankle2_x0   ankle2_y0    ankle2_z0     1];
knee2_0   = [knee2_x0    knee2_y0     knee2_z0      1];
hip2_0    = [hip2_x0     hip2_y0      hip2_z0       1];
torso2_0  = [torso2_x0   torso2_y0    torso2_z0     1];

%% Transform data
% Inverse transformation matrix used to convert from camara frame to
% treadmill frame.  For details see Transform.m

% vst.cpp 04/09/2014
T_inv = [ .9460  -.0155  .3237  1580.9
         -.0086  -.9997 -.0229 -199.00
          .3240   .0189 -.9459 -2311.2
            0       0       0       1];
    
% Transform data into treadmill frame
 for i = 1:length(toe1)
     toe1_t(i,:)    = T_inv*toe1(i,:)';
     ankle1_t(i,:)  = T_inv*ankle1(i,:)';
     knee1_t(i,:)   = T_inv*knee1(i,:)';
     hip1_t(i,:)    = T_inv*hip1(i,:)';
     torso1_t(i,:)  = T_inv*torso1(i,:)';
     
     toe2_t(i,:)    = T_inv*toe2(i,:)';
     ankle2_t(i,:)  = T_inv*ankle2(i,:)';
     knee2_t(i,:)   = T_inv*knee2(i,:)';
     hip2_t(i,:)    = T_inv*hip2(i,:)';
     torso2_t(i,:)  = T_inv*torso2(i,:)';
 end

toe1_t0     = T_inv*toe1_0';
ankle1_t0   = T_inv*ankle1_0';
knee1_t0    = T_inv*knee1_0';
hip1_t0     = T_inv*hip1_0';
torso1_t0   = T_inv*torso1_0';

toe2_t0     = T_inv*toe2_0';
ankle2_t0   = T_inv*ankle2_0';
knee2_t0    = T_inv*knee2_0';
hip2_t0     = T_inv*hip2_0';
torso2_t0   = T_inv*torso2_0';


%% Change coord frame for data processing
% z -> x
% x -> y
% y -> z

temp1 = toe1_t;
temp2 = ankle1_t;
temp3 = knee1_t;
temp4 = hip1_t;
temp5 = torso1_t;

temp6 = toe2_t;
temp7 = ankle2_t;
temp8 = knee2_t;
temp9 = hip2_t;
temp10 = torso2_t;

temp11 = toe1_t0;
temp12 = ankle1_t0;
temp13 = knee1_t0;
temp14 = hip1_t0;
temp15 = torso1_t0;

temp16 = toe2_t0;
temp17 = ankle2_t0;
temp18 = knee2_t0;
temp19 = hip2_t0;
temp20 = torso2_t0;

toe1_t = [temp1(:,3) temp1(:,1) temp1(:,2) temp1(:,4)];
ank1_t = [temp2(:,3) temp2(:,1) temp2(:,2) temp2(:,4)];
kne1_t = [temp3(:,3) temp3(:,1) temp3(:,2) temp3(:,4)];
hip1_t = [temp4(:,3) temp4(:,1) temp4(:,2) temp4(:,4)];
tor1_t = [temp5(:,3) temp5(:,1) temp5(:,2) temp5(:,4)];
toe2_t = [temp6(:,3) temp6(:,1) temp6(:,2) temp6(:,4)];
ank2_t = [temp7(:,3) temp7(:,1) temp7(:,2) temp7(:,4)];
kne2_t = [temp8(:,3) temp8(:,1) temp8(:,2) temp8(:,4)];
hip2_t = [temp9(:,3) temp9(:,1) temp9(:,2) temp9(:,4)];
tor2_t = [temp10(:,3) temp10(:,1) temp10(:,2) temp10(:,4)];

toe1_t0 = [temp11(3) temp11(1) temp11(2) temp11(4)];
ank1_t0 = [temp12(3) temp12(1) temp12(2) temp12(4)];
kne1_t0 = [temp13(3) temp13(1) temp13(2) temp13(4)];
hip1_t0 = [temp14(3) temp14(1) temp14(2) temp14(4)];
tor1_t0 = [temp15(3) temp15(1) temp15(2) temp15(4)];
toe2_t0 = [temp16(3) temp16(1) temp16(2) temp16(4)];
ank2_t0 = [temp17(3) temp17(1) temp17(2) temp17(4)];
kne2_t0 = [temp18(3) temp18(1) temp18(2) temp18(4)];
hip2_t0 = [temp19(3) temp19(1) temp19(2) temp19(4)];
tor2_t0 = [temp20(3) temp20(1) temp20(2) temp20(4)];

clear toe1_0 ankle1_0 knee1_0 hip1_0 torso1_0
clear toe2_0 ankle2_0 knee2_0 hip2_0 torso2_0
clear toe1 ankle1 knee1 hip1 torso1
clear toe2 ankle2 knee2 hip2 torso2


% 3D for doing cross product
% Let z = 0 (sagital plane)
toe1     = [toe1_t(:,1)     toe1_t(:,2)    cero];
ankle1   = [ank1_t(:,1)     ank1_t(:,2)    cero];
knee1    = [kne1_t(:,1)     kne1_t(:,2)    cero];
hip1     = [hip1_t(:,1)     hip1_t(:,2)    cero];
torso1   = [tor1_t(:,1)     tor1_t(:,2)    cero];

toe2     = [toe2_t(:,1)     toe2_t(:,2)    cero];
ankle2   = [ank2_t(:,1)     ank2_t(:,2)    cero];
knee2    = [kne2_t(:,1)     kne2_t(:,2)    cero];
hip2     = [hip2_t(:,1)     hip2_t(:,2)    cero];
torso2   = [tor2_t(:,1)     tor2_t(:,2)    cero];

toe1_0   = [toe1_t0(1)   toe1_t0(2)    0];
ankle1_0 = [ank1_t0(1)   ank1_t0(2)    0];
knee1_0  = [kne1_t0(1)   kne1_t0(2)    0];
hip1_0   = [hip1_t0(1)   hip1_t0(2)    0];
torso1_0 = [tor1_t0(1)   tor1_t0(2)    0];

toe2_0   = [toe2_t0(1)   toe2_t0(2)    0];
ankle2_0 = [ank2_t0(1)   ank2_t0(2)    0];
knee2_0  = [kne2_t0(1)   kne2_t0(2)    0];
hip2_0   = [hip2_t0(1)   hip2_t0(2)    0];
torso2_0 = [tor2_t0(1)   tor2_t0(2)    0];

xoff = [370 0 0]; % mm
yoff = [0 160 0];


for i = 1:length(toe1)
toe1(i,:)   = (toe1(i,:)   - xoff - yoff)/10; % cm
ankle1(i,:) = (ankle1(i,:) - xoff - yoff)/10;
knee1(i,:)  = (knee1(i,:)  - xoff - yoff)/10;
hip1(i,:)   = (hip1(i,:)   - xoff - yoff)/10;
torso1(i,:) = (torso1(i,:) - xoff - yoff)/10;

toe2(i,:)   = (toe2(i,:)   - xoff - yoff)/10;
ankle2(i,:) = (ankle2(i,:) - xoff - yoff)/10;
knee2(i,:)  = (knee2(i,:)  - xoff - yoff)/10;
hip2(i,:)   = (hip2(i,:)   - xoff - yoff)/10;
torso2(i,:) = (torso2(i,:) - xoff - yoff)/10;
end

toe1_0      = (toe1_0   - xoff - yoff)/10; % cm
ankle1_0    = (ankle1_0 - xoff - yoff)/10;
knee1_0     = (knee1_0  - xoff - yoff)/10;
hip1_0      = (hip1_0   - xoff - yoff)/10;
torso1_0    = (torso1_0 - xoff - yoff)/10;

toe2_0      = (toe2_0   - xoff - yoff)/10; % cm
ankle2_0    = (ankle2_0 - xoff - yoff)/10;
knee2_0     = (knee2_0  - xoff - yoff)/10;
hip2_0      = (hip2_0   - xoff - yoff)/10;
torso2_0    = (torso2_0 - xoff - yoff)/10;

clear *_t*
clear temp*


%% Find zero angles
% vectors in sagital plane
a1_0 = -hip1_0 + knee1_0;   % from hip to knee
b1_0 = -knee1_0 + ankle1_0; % from knee to ankle
c1_0 = -ankle1_0 + toe1_0;  % from ankle to toe
g0 = [ 0 -1 0];

c1 = cross(g0,a1_0);
c2 = cross(a1_0,b1_0);
c3 = cross(b1_0,c1_0);

theta_hip1_0 = atan2( -sign( c1(3) )*norm( cross(g0,a1_0) ) , dot(g0,a1_0) );
theta_knee1_0 = atan2(-sign(c2(3))*norm(cross(a1_0,b1_0)),dot(a1_0,b1_0));
theta_ankle1_0 = atan2(-sign(c3(3))*norm(cross(b1_0,c1_0)),dot(b1_0,c1_0));

% leg 2
a2_0 = -hip2_0 + knee2_0;   % from hip to knee
b2_0 = -knee2_0 + ankle2_0; % from knee to ankle
c2_0 = -ankle2_0 + toe2_0;  % from ankle to toe

c4 = cross(g0,a2_0);
c5 = cross(a2_0,b2_0);
c6 = cross(b2_0,c2_0);
theta_hip2_0 = atan2(-sign(c4(3))*norm(cross(g0,a2_0)),dot(g0,a2_0));
theta_knee2_0 = atan2(-sign(c5(3))*norm(cross(a2_0,b2_0)),dot(a2_0,b2_0));
theta_ankle2_0 = atan2(-sign(c6(3))*norm(cross(b2_0,c2_0)),dot(b2_0,c2_0));
%% Only look at unperturbed (right) leg for now

toe = toe2;
ankle = ankle2;
knee = knee2;
hip = hip2;
torso = torso2;

th_ankle0 = theta_ankle2_0;
th_knee0 = theta_knee2_0;
th_hip0 = theta_hip2_0;

%%
% Segment vectors
a = -hip + knee;   % from hip to knee
b = -knee + ankle; % from knee to ankle
c = -ankle + toe;  % from ankle to toe

% Find joint angles
for i = 1:1:length(hip)
    c1 = cross(g0,a(i,:));
    th_hip(i) = atan2(-sign(c1(3))*norm(cross(g0,a(i,:))),dot(g0,a(i,:)));
    c2 = cross(a(i,:),b(i,:));
    th_knee(i) = atan2(-sign(c2(3))*norm(cross(a(i,:),b(i,:))),dot(a(i,:),b(i,:))); 
    c3 = cross(b(i,:),c(i,:));
    th_ankle(i) = atan2(-sign(c3(3))*norm(cross(b(i,:),c(i,:))),dot(b(i,:),c(i,:))); 
end


theta_ankle = th_ankle - th_ankle0;
theta_knee = th_knee - th_knee0;
theta_hip = th_hip - th_hip0;

% Find contra lateral foot position
xf_cl = (toe(:,1)+ankle(:,1))/2;


%% Break into gait cycles
% Contra lateral leg!!

% find minimums of xf_cl
% close to heel strike
Data = xf_cl;
[Maxima,MaxIdx] = findpeaks(Data);
DataInv = 1.01*max(Data) - Data;
[~,MinIdx] = findpeaks(DataInv);
Minima = Data(MinIdx);

heel_strike_ind = MinIdx; % indices where HS occurs

% Don't include data before up to speed + a couple cycles
num2remove = find(heel_strike_ind < max_speed_ind,1,'last');
num2remove2 = num2remove + 2;
heel_strike_ind(1:num2remove2) = [];
ave_samples_per_gait_cycle = mean(diff(heel_strike_ind));

%% find infinite sections
num_cycles_to_view_inf = 1;
count = 1;
range_past = heel_strike_ind(1) : heel_strike_ind(1+num_cycles_to_view_inf);
for i = 1:length(heel_strike_ind) - num_cycles_to_view_inf;
    range = heel_strike_ind(i) : heel_strike_ind(i+num_cycles_to_view_inf);
    if isempty( find( perturb(range) > 0,1,'first') ) % no perturbation during this cycle
        if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
            inf_inds{count}(1) = range(1);
            inf_inds{count}(2) = range(end);
            count = count + 1;
        end
    end
    range_past = range;
end

num_inf_cycs = count - 1;
ankle_angle_inf = cell(num_inf_cycs,1);
xx = linspace(0, num_cycles_to_view_inf*100, num_cycles_to_view_inf*1000 + 1);
pgc = xx; % percent gait cycle
for i = 1:num_inf_cycs
    ind1 = inf_inds{i}(1);
    ind2 = inf_inds{i}(2);
    
    y_ankle = theta_ankle(ind1:ind2).*180./pi;
    y_knee = theta_knee(ind1:ind2).*180./pi;
    y_hip = theta_hip(ind1:ind2).*180./pi;
    
    fb_temp = force_b(ind1:ind2);
    xf_temp = xf(ind1:ind2);
    fff = theta1(ind1:ind2);
    d_temp = tand(fff).*xf_temp;
    
    temp = ind1:ind2;
    x = num_cycles_to_view_inf*100*(temp - min(temp)) / ( max(temp) - min(temp) );
    
    ankle_angle_inf{i} = spline(x,y_ankle,xx);
    knee_angle_inf{i} = spline(x,y_knee,xx);
    hip_angle_inf{i} = spline(x,y_hip,xx);
    
    fb_inf_temp{i} = spline(x,fb_temp,xx);
    ff_inf_temp{i} = spline(x,fb_temp.*0.33.*100./xf_temp,xx);
    d_inf_temp{i} = spline(x,d_temp,xx);
    
    
    
    clear y_ankle
    clear fb_temp xf_temp d_temp
    
end

ankle_inf = mean(cell2mat(ankle_angle_inf));
knee_inf = mean(cell2mat(knee_angle_inf'));
hip_inf = mean(cell2mat(hip_angle_inf));
fb_inf = mean(cell2mat(fb_inf_temp'));
ff_inf = mean(cell2mat(ff_inf_temp'));
d_inf = mean(cell2mat(d_inf_temp'));

fb_inf_std = std(cell2mat(fb_inf_temp'));

% clf;plot(pgc,asdf)
%
% axis([0 100 -30 20])


% ankle{10}{1} = mean(cell2mat(ankle_angle_inf'));
% ankle{10}{2} = std(cell2mat(ankle_angle_inf'));

%% find perturbation sections
clear type_w_inds
type_w_inds = cell(10,1);

for i = 1:length(heel_strike_ind) - 3;
    range = heel_strike_ind(i) : heel_strike_ind(i+1);
    inds = range;
    if ~isempty(find(perturb(inds) == 1, 1)) && ~isempty(find(Kd(inds) == 1e4, 1))
        if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{1}{end+1} = heel_strike_ind(i):heel_strike_ind(i+3);
        end
    elseif ~isempty(find(perturb(inds) == 2, 1)) && ~isempty(find(Kd(inds) == 1e4, 1))
        if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{2}{end+1} = heel_strike_ind(i):heel_strike_ind(i+3);
        end
    elseif ~isempty(find(perturb(inds) == 3, 1)) && ~isempty(find(Kd(inds) == 1e4, 1))
        if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{3}{end+1} = heel_strike_ind(i):heel_strike_ind(i+3);
        end
    elseif ~isempty(find(perturb(inds) == 1, 1)) && ~isempty(find(Kd(inds) == 5e4, 1))
        if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{4}{end+1} = heel_strike_ind(i):heel_strike_ind(i+3);
        end
    elseif ~isempty(find(perturb(inds) == 2, 1)) && ~isempty(find(Kd(inds) == 5e4, 1))
        if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{5}{end+1} = heel_strike_ind(i):heel_strike_ind(i+3);
        end
    elseif ~isempty(find(perturb(inds) == 3, 1)) && ~isempty(find(Kd(inds) == 5e4, 1))
        if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{6}{end+1} = heel_strike_ind(i):heel_strike_ind(i+3);
        end
    elseif ~isempty(find(perturb(inds) == 1, 1)) && ~isempty(find(Kd(inds) == 1e5, 1))
        if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{7}{end+1} = heel_strike_ind(i):heel_strike_ind(i+3);
        end
    elseif ~isempty(find(perturb(inds) == 2, 1)) && ~isempty(find(Kd(inds) == 1e5, 1))
        if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{8}{end+1} = heel_strike_ind(i):heel_strike_ind(i+3);
        end
    elseif ~isempty(find(perturb(inds) == 3, 1)) && ~isempty(find(Kd(inds) == 1e5, 1))
        if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{9}{end+1} = heel_strike_ind(i):heel_strike_ind(i+3);
        end
    else
    end
    clear range_past
    range_past = range;
    clear range inds
end

%%
num_types_perts = 9; % 9 different perturbation types (3 locations, 3 magnitudes)
num_perts = 0;
for i = 1:num_types_perts 
    num_perts = num_perts + length(type_w_inds{i});
end
disp(['Total number of perturbations: ', num2str(num_perts)]);

%%

xx = linspace(0,300,3001);
pgc = xx; % percent gait cycle

clear ankle_angle
for i = 1:num_types_perts
    for j = 1:length(type_w_inds{i})
        data = type_w_inds{i}{j};
        
        length_of_data(i,j) = data(end) - data(1);
        
        begin_pert = data( find( perturb(data) > 0,1,'first') );
        end_pert = data( find( perturb(data) > 0,1,'last') );
        
        if begin_pert-data(1) > 8 && end_pert-data(1) > 8
            samples2pert_start(i,j) = begin_pert-data(1);
            samples2pert_end(i,j) = end_pert-data(1);
        else
            samples2pert_start(i,j) = 0;
            samples2pert_end(i,j) = 0;
        end
        
        
        y_ankle = theta_ankle(data).*180./pi;
        y_knee = theta_knee(data).*180./pi;
        y_hip = theta_hip(data).*180./pi;
        fb_temp1 = force_b(data);
        xf_temp1 = xf(data);
        d_temp1 = tand(theta1(data)).*xf_temp1; 
        
        x = 300*(data - min(data)) / ( max(data) - min(data) );
       
        ankle_angle{i}{j} = spline(x,y_ankle,xx);
        knee_angle{i}{j} = spline(x,y_knee,xx);
        hip_angle{i}{j} = spline(x,y_hip,xx);
        
        fb_p{i}{j} = spline(x,fb_temp1,xx);
        ff_p{i}{j} = spline(x,fb_temp1.*0.33.*100./xf_temp1,xx);
        d_p{i}{j} = spline(x,d_temp1,xx);
        
        fff = d_temp1;
        
        clear y_ankle y_knee y_hip data 
        clear fb_temp1 xf_temp1 d_temp1
    end
end

begin_pert_pgc = (sum(samples2pert_start,2)./sum(samples2pert_start~=0,2))./mean(mean(length_of_data)).*300;
end_pert_pgc = (sum(samples2pert_end,2)./sum(samples2pert_end~=0,2))./mean(mean(length_of_data)).*300;
clear ankle knee hip
for i = 1:num_types_perts
    ankle{i} = mean(cell2mat(ankle_angle{i}')); % Note: transpose important for correct calculations.
    knee{i} = mean(cell2mat(knee_angle{i}'));
    hip{i} = mean(cell2mat(hip_angle{i}'));
    fb_pert{i} = mean(cell2mat(fb_p{i}'));
    ff_pert{i} = mean(cell2mat(ff_p{i}'));
    d_pert{i} = mean(cell2mat(d_p{i}'));
    fb_pert_std{i} = std(cell2mat(fb_p{i}'));
end

clear temp
temp = ankle_inf;
temp(end) = [];
ankle{10} = [temp temp ankle_inf];

clear temp
temp = knee_inf;
temp(end) = [];
knee{10} = [temp temp knee_inf];

clear temp
temp = hip_inf;
temp(end) = [];
hip{10} = [temp temp hip_inf];

clear temp
temp = fb_inf;
temp(end) = [];
fb_pert{10} = [temp temp fb_inf];

clear temp
temp = ff_inf;
temp(end) = [];
ff_pert{10} = [temp temp ff_inf];

clear temp
temp = ff_inf;
temp(end) = [];
ff_pert{10} = [temp temp ff_inf];

clear temp
temp = d_inf;
temp(end) = [];
d_pert{10} = [temp temp d_inf];


1
return
%% plot


figure(2); clf;
suptitle({'Contralateral leg Kinematics (Chase):';['Ankle   ',num2str(bws),' % BWS']})

yval = -10;
yval2 = .01;
bws_amount = {'10','20','30'};
HS = 'HS';
TO = 'TO';
type = {'mean','std'};
loc = {'Heel Strike Pert','Mid Stance Pert','Toe Off Pert'};
stiff = {'10k (N/m)','50k (N/m)','100k (N/m)'};
joint = {'ankle','knee','hip'};
   
yval2 = -15;

for j = 1:9
    subplot(3,3,j); hold on;
    set(findall(gcf,'type','text'),'fontSize',14,'fontWeight','bold')
    plot(pgc,ankle{j},'r','LineWidth',2);
    plot(pgc,ankle{10},'b','LineWidth',2);
    ind1 = round(begin_pert_pgc(j));
    ind2 = round(end_pert_pgc(j));
    range = linspace(ind1,ind2,400);
    plot(range,yval2*ones(size(range)),'k-','LineWidth',3)
    axis_d = [0 max(pgc) -20 20];
    
    if j == 1
        ylabel(stiff{1});
    elseif j == 4
        ylabel(stiff{2});
    elseif j == 7
        ylabel(stiff{3});
        xlabel(loc{1});
    elseif j == 8
        xlabel(loc{2})
    elseif j == 9
        xlabel(loc{3})
    end
    
     hx1=graph2d.constantline(100, 'LineStyle',':');
     hx2=graph2d.constantline(200, 'LineStyle',':');
     changedependvar(hx1,'x');
     changedependvar(hx2,'x');
     hx3=graph2d.constantline(65, 'LineStyle',':');
     hx4=graph2d.constantline(165, 'LineStyle',':');
     hx5=graph2d.constantline(265, 'LineStyle',':');
     
     changedependvar(hx3,'x');
     changedependvar(hx4,'x');
     changedependvar(hx5,'x');
     %plot(xpert5,ypert5,'k-','LineWidth',3);
     text(100,yval,HS);
     text(200,yval,HS);
     text(65,yval,TO);
     text(165,yval,TO);
     text(265,yval,TO);
    
%     hy = graph2d.constantline(0, 'LineStyle','-', 'Color',[.7 .7 .7]);
%     changedependvar(hy,'y');
%     changedependvar(hx1,'x');
%     changedependvar(hx2,'x');
    legend('Perturbed','Normal');
    axis(axis_d)
    clear range
end

figureHandle = gcf;
set(findall(figureHandle,'type','text'),'fontSize',12,'fontWeight','bold')

disp('Ankle in Time plotted')

%% Polar plot

% split into 100s for each circle
limit_cycle = ankle_inf;
tp = linspace(0,2*pi,length(limit_cycle));
dt = 2*pi/length(limit_cycle);
t = 0:dt:2*pi-dt;
ankle2 = ankle

for i = 1:9
    first_cycle{i} = spline(t,ankle2{i}(1:1001),tp);
    second_cycle{i} = spline(t,ankle2{i}(1001:2001),tp);
    third_cycle{i} = spline(t,ankle2{i}(2001:3001),tp);
end
    
asdf = spline(t,limit_cycle,tp); % Normalize over gait cycle

figure(4); clf;
polar(tp,asdf,'r'); hold on;
title('Angle vs. % Cycle');

figure(2); clf;
suptitle({'Contralateral leg Kinematics (Chase):';['Ankle   ',num2str(bws),' % BWS']});

for j = 1:9
    subplot(3,3,j); hold on;
    set(findall(gcf,'type','text'),'fontSize',14,'fontWeight','bold')
    polar(tp,first_cycle{j},'r');
    polar(tp,second_cycle{j},'g');
    polar(tp,third_cycle{j},'c');
    polar(tp,limit_cycle,'b');
    ind1 = round(begin_pert_pgc(j));
    ind2 = round(end_pert_pgc(j));
    range = linspace(ind1,ind2,400);
    %plot(range,yval2*ones(size(range)),'k-','LineWidth',3)
    axis_d = [0 max(pgc) -20 20];
    
    if j == 1
        ylabel(stiff{1});
    elseif j == 4
        ylabel(stiff{2});
    elseif j == 7
        ylabel(stiff{3});
        xlabel(loc{1});
    elseif j == 8
        xlabel(loc{2})
    elseif j == 9
        xlabel(loc{3})
    end
    
%      hx1=graph2d.constantline(100, 'LineStyle',':');
%      hx2=graph2d.constantline(200, 'LineStyle',':');
%      changedependvar(hx1,'x');
%      changedependvar(hx2,'x');
%      hx3=graph2d.constantline(65, 'LineStyle',':');
%      hx4=graph2d.constantline(165, 'LineStyle',':');
%      hx5=graph2d.constantline(265, 'LineStyle',':');
%      
%      changedependvar(hx3,'x');
%      changedependvar(hx4,'x');
%      changedependvar(hx5,'x');
%      %plot(xpert5,ypert5,'k-','LineWidth',3);
%      text(100,yval,HS);
%      text(200,yval,HS);
%      text(65,yval,TO);
%      text(165,yval,TO);
%      text(265,yval,TO);
    
%     hy = graph2d.constantline(0, 'LineStyle','-', 'Color',[.7 .7 .7]);
%     changedependvar(hy,'y');
%     changedependvar(hx1,'x');
%     changedependvar(hx2,'x');
    legend('Perturbed','Normal');
    %axis(axis_d)
    clear range
end

% tp = 0:1/100:2*pi;
% dt = 2*pi/length(first_cycle{1});
% t = 0:dt:2*pi-dt;
% asdf = spline(t,first_cycle{1},tp); % Normalize over gait cycle
% 
% figure(4); clf;
% polar(tp,asdf,'r'); hold on;
% title('Angle vs. % Cycle');




return

%%
clear first_cycle
clear second_cycle
clear third_cycle

limit_cycle = ankle_inf;
tp = linspace(0,2*pi,length(limit_cycle));
dt = 2*pi/length(limit_cycle);
t = 0:dt:2*pi-dt;
figure(2); clf;
suptitle({'Contralateral leg Kinematics (Chase):';['Ankle   ',num2str(bws),' % BWS']});


for j = 1:9
    ind1 = round(begin_pert_pgc(j))*10+1;
    ind2 = round(end_pert_pgc(j))*10+1;
    pert_dur(j) = ind2-ind1;
    ankle2 = ankle;
    ankle2{j}(1:ind1) = [];
       
    first_cycle{j} = spline(t,ankle2{j}(1:1001),tp);
    second_cycle{j} = spline(t,ankle{j}(1001:2001),tp);
    %third_cycle{j} = spline(t,ankle{i}(2001:3001),tp);
    
    subplot(3,3,j);  hold on;
    set(findall(gcf,'type','text'),'fontSize',14,'fontWeight','bold')
    polar(tp,first_cycle{j},'r');
    polar(tp,second_cycle{j},'g');
       
    %polar(tp,third_cycle{j},'c');
    polar(tp,limit_cycle,'b');
    
    polar(tp(1:pert_dur(j)),10*ones(size(tp(1:pert_dur(j)))),'k-')
    
    ind1 = round(begin_pert_pgc(j));
    ind2 = round(end_pert_pgc(j));
    range = linspace(ind1,ind2,400);
    %plot(range,yval2*ones(size(range)),'k-','LineWidth',3)
    axis_d = [0 max(pgc) -20 20];
    
    if j == 1
        ylabel(stiff{1});
    elseif j == 4
        ylabel(stiff{2});
    elseif j == 7
        ylabel(stiff{3});
        xlabel(loc{1});
    elseif j == 8
        xlabel(loc{2})
    elseif j == 9
        xlabel(loc{3})
    end
    legend('1st cycle','2nd Cycle','Limit Cycle')
    axis equal
end
    
asdf = spline(t,limit_cycle,tp); % Normalize over gait cycle
