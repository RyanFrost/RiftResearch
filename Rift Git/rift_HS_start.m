

%--------------------------------------------------
%
% NDI in front of subject, 10 markers
%
%--------------------------------------------------

clear all;
close all;
clc;

%% Load in data from .txt files

%---( Match w/ file )---------
bws = 30;
subject = 'justin';
%
tic;
%B = load('justinRiftDataEdited.txt'); % main data
toc;
tic;
fid = fopen('justinRiftDataEdited.txt');

numVars = 63;
format = repmat('%f',1,numVars);
A = textscan(fid,format,'Delimiter',' ','CollectOutput',1);
A=A{1};

fclose(fid);

toc;


% ------------------------------------------

% <------- means important and may need change

tspeed_d = A(:,5);
tspeed_max = max(tspeed_d);

max_speed_ind = find(tspeed_d == tspeed_max,1,'first'); % when treadmill reaches max speed of the experiment

ind1 = 1; % <-------- Enter the index where you want to begin looking at cycles (i.e. after justin restarts walking around 65000)
ind2 = length(tspeed_d);

xf = A(ind1:ind2,8);
perturb = A(ind1:ind2,10);
Kd = A(ind1:ind2,12);
% kinematic data from NDI
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
cycle = A(ind1:ind2,55);

time_vst_absolute = A(:,59);
start_time = A(:,61);
time = time_vst_absolute - start_time(1);


clear ind1 ind2

%% Create position vectors for markers

% 1 is perturbed (left side)
% 2 is unperturbed (right side)

% used for rotation of frames
unos = ones(size(cycle)); 
cero = zeros(size(cycle));

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
index = 6; % <---------- Choose index where subject is standing still for zero angles

torso1_x0 = mean(A(index,16));
hip1_x0   = mean(A(index,17));
knee1_x0  = mean(A(index,18));
ankle1_x0 = mean(A(index,19));
toe1_x0   = mean(A(index,20));
% y0 position in NDI (camara) frame
torso1_y0 = mean(A(index,21));
hip1_y0   = mean(A(index,22));
knee1_y0  = mean(A(index,23));
ankle1_y0 = mean(A(index,24));
toe1_y0   = mean(A(index,25));
% z0 position in NDI (camara) frame
torso1_z0 = mean(A(index,26));
hip1_z0   = mean(A(index,27));
knee1_z0  = mean(A(index,28));
ankle1_z0 = mean(A(index,29));
toe1_z0   = mean(A(index,30));

torso2_x0 = mean(A(index,31));
hip2_x0   = mean(A(index,32));
knee2_x0  = mean(A(index,33));
ankle2_x0 = mean(A(index,34));
toe2_x0   = mean(A(index,35));
% y0 position in NDI (camara) frame
torso2_y0 = mean(A(index,36));
hip2_y0   = mean(A(index,37));
knee2_y0  = mean(A(index,38));
ankle2_y0 = mean(A(index,39));
toe2_y0   = mean(A(index,40));
% z0 position in NDI (camara) frame
torso2_z0 = mean(A(index,41));
hip2_z0   = mean(A(index,42));
knee2_z0  = mean(A(index,43));
ankle2_z0 = mean(A(index,44));
toe2_z0   = mean(A(index,45));

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
% treadmill frame. 

% <------------ look at .cpp code to find and update this matrix
T_inv = [ .9460  -.0155  .3237  1580.9
         -.0086  -.9997 -.0229 -199.00
          .3240   .0189 -.9459 -2311.2
            0       0       0       1];
T_uninv = inv(T_inv);
    

toe1_t    = (T_uninv\toe1')';
ankle1_t  = (T_uninv\ankle1')';
knee1_t   = (T_uninv\knee1')';
hip1_t   = (T_uninv\hip1')';
torso1_t  = (T_uninv\torso1')';

toe2_t    = (T_uninv\toe2')';
ankle2_t  = (T_uninv\ankle2')';
knee2_t   = (T_uninv\knee2')';
hip2_t   = (T_uninv\hip2')';
torso2_t  = (T_uninv\torso2')';


toe1_t0     = (T_uninv\toe1_0')';
ankle1_t0   = (T_uninv\ankle1_0')';
knee1_t0    = (T_uninv\knee1_0')';
hip1_t0     = (T_uninv\hip1_0')';
torso1_t0   = (T_uninv\torso1_0')';

toe2_t0     = (T_uninv\toe2_0')';
ankle2_t0   = (T_uninv\ankle2_0')';
knee2_t0    = (T_uninv\knee2_0')';
hip2_t0     = (T_uninv\hip2_0')';
torso2_t0   = (T_uninv\torso2_0')';
%% Change coord frame for data processing
% z -> x
% x -> y
% y -> z

toe1_t(:,[1,2,3,4]) = toe1_t(:,[3,1,2,4]);
ankle1_t(:,[1,2,3,4]) = ankle1_t(:,[3,1,2,4]);
knee1_t(:,[1,2,3,4]) = knee1_t(:,[3,1,2,4]);
hip1_t(:,[1,2,3,4]) = hip1_t(:,[3,1,2,4]);
torso1_t(:,[1,2,3,4]) = torso1_t(:,[3,1,2,4]);
toe2_t(:,[1,2,3,4]) = toe2_t(:,[3,1,2,4]);
ankle2_t(:,[1,2,3,4]) = ankle2_t(:,[3,1,2,4]);
knee2_t(:,[1,2,3,4]) = knee2_t(:,[3,1,2,4]);
hip2_t(:,[1,2,3,4]) = hip2_t(:,[3,1,2,4]);
torso2_t(:,[1,2,3,4]) = torso2_t(:,[3,1,2,4]);

toe1_t0(:,[1,2,3,4]) = toe1_t0(:,[3,1,2,4]);
ankle1_t0(:,[1,2,3,4]) = ankle1_t0(:,[3,1,2,4]);
knee1_t0(:,[1,2,3,4]) = knee1_t0(:,[3,1,2,4]);
hip1_t0(:,[1,2,3,4]) = hip1_t0(:,[3,1,2,4]);
torso1_t0(:,[1,2,3,4]) = torso1_t0(:,[3,1,2,4]);
toe2_t0(:,[1,2,3,4]) = toe2_t0(:,[3,1,2,4]);
ankle2_t0(:,[1,2,3,4]) = ankle2_t0(:,[3,1,2,4]);
knee2_t0(:,[1,2,3,4]) = knee2_t0(:,[3,1,2,4]);
hip2_t0(:,[1,2,3,4]) = hip2_t0(:,[3,1,2,4]);
torso2_t0(:,[1,2,3,4]) = torso2_t0(:,[3,1,2,4]);



clear toe1_0 ankle1_0 knee1_0 hip1_0 torso1_0
clear toe2_0 ankle2_0 knee2_0 hip2_0 torso2_0
clear toe1 ankle1 knee1 hip1 torso1
clear toe2 ankle2 knee2 hip2 torso2


% 3D for doing cross product
% Let z = 0 (sagital plane)
toe1     = [toe1_t(:,1)     toe1_t(:,2)    cero];
ankle1   = [ankle1_t(:,1)     ankle1_t(:,2)    cero];
knee1    = [knee1_t(:,1)     knee1_t(:,2)    cero];
hip1     = [hip1_t(:,1)     hip1_t(:,2)    cero];
torso1   = [torso1_t(:,1)     torso1_t(:,2)    cero];

toe2     = [toe2_t(:,1)     toe2_t(:,2)    cero];
ankle2   = [ankle2_t(:,1)     ankle2_t(:,2)    cero];
knee2    = [knee2_t(:,1)     knee2_t(:,2)    cero];
hip2     = [hip2_t(:,1)     hip2_t(:,2)    cero];
torso2   = [torso2_t(:,1)     torso2_t(:,2)    cero];

toe1_0   = [toe1_t0(1)   toe1_t0(2)    0];
ankle1_0 = [ankle1_t0(1)   ankle1_t0(2)    0];
knee1_0  = [knee1_t0(1)   knee1_t0(2)    0];
hip1_0   = [hip1_t0(1)   hip1_t0(2)    0];
torso1_0 = [torso1_t0(1)   torso1_t0(2)    0];

toe2_0   = [toe2_t0(1)   toe2_t0(2)    0];
ankle2_0 = [ankle2_t0(1)   ankle2_t0(2)    0];
knee2_0  = [knee2_t0(1)   knee2_t0(2)    0];
hip2_0   = [hip2_t0(1)   hip2_t0(2)    0];
torso2_0 = [torso2_t0(1)   torso2_t0(2)    0];

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
%% Only look at perturbed (left) leg for now
% 1 = left
% 2 = right

toe = toe1;
ankle = ankle1;
knee = knee1;
hip = hip1;
torso = torso1;

th_ankle0 = theta_ankle1_0;
th_knee0 = theta_knee1_0;
th_hip0 = theta_hip1_0;

%%
% Segment vectors
a = -hip + knee;   % from hip to knee
b = -knee + ankle; % from knee to ankle
c = -ankle + toe;  % from ankle to toe



c1 = cross(repmat(g0,length(hip),1),a);

c1n = norm(c1);
d1 = dot(repmat(g0,length(hip),1),a,2);
c2 = cross(a,b,2);
c2n = norm(c2);
d2 = dot(a,b,2);
c3 = cross(b,c);
c3n = norm(c3);
d3 = dot(b,c,2);

for i = 1:length(hip)

    th_hip(i) = atan2(-sign(c1(i,3))*norm(c1(i,:)),d1(i));

    th_knee(i) = atan2(-sign(c2(i,3))*norm(c2(i,:)),d2(i)); 

    th_ankle(i) = atan2(-sign(c3(i,3))*norm(c3(i,:)),d3(i)); 
end




theta_ankle = th_ankle - th_ankle0;
theta_knee = th_knee - th_knee0;
theta_hip = th_hip - th_hip0;

%% Break into gait cycles

% find minimums of xf
% close to heel strike
Data = xf;
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
% plot record data as single cycles
numCyclesBefore = 1;
numCyclesAfter = 3;
numCyclesPlot = numCyclesBefore+numCyclesAfter+1;
num_cycles_to_view_inf = numCyclesPlot;
count = 1;
range_past = heel_strike_ind(1) : heel_strike_ind(1+num_cycles_to_view_inf); 
for i = 1+numCyclesBefore:length(heel_strike_ind) - numCyclesAfter-1;
    range = heel_strike_ind(i-numCyclesBefore) : heel_strike_ind(i+1+numCyclesAfter); % take 1 gait cycle
    if isempty( find( perturb(range) > 0,1,'first') ) % no perturbation during this cycle
        if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
            inf_inds{count}(1) = heel_strike_ind(i);
            inf_inds{count}(2) = heel_strike_ind(i+1);
            count = count + 1;
        end
    end
    range_past = range;
end

num_inf_cycs = count - 1;
ankle_angle_inf = cell(num_inf_cycs,1);
knee_angle_inf = cell(num_inf_cycs,1);
hip_angle_inf = cell(num_inf_cycs,1);
xx = linspace(0-numCyclesBefore*100, (1+numCyclesAfter)*100,1000 );
xx = linspace(0, 100,1000 );
pgc = xx; % percent gait cycle
pgc = linspace(0-numCyclesBefore*100, (1+numCyclesAfter)*100,num_cycles_to_view_inf*1000 );


for i = 1+numCyclesBefore:num_inf_cycs-numCyclesAfter-1
    ind1 = inf_inds{i}(1);
    ind2 = inf_inds{i}(2);
    
    y_ankle = theta_ankle(ind1:ind2).*180./pi;
    y_knee = theta_knee(ind1:ind2).*180./pi;
    y_hip = theta_hip(ind1:ind2).*180./pi;
    
    % normalize each cycle over gait cycle
    temp = ind1:ind2;
    x = 100*(temp - min(temp)) / ( max(temp) - min(temp) );
    ankle_angle_inf{i} = spline(x,y_ankle,xx);
    knee_angle_inf{i} = spline(x,y_knee,xx);
    hip_angle_inf{i} = spline(x,y_hip,xx);
        
    clear y_ankle y_knee y_hip
end

ankle_infAvg = mean(cell2mat(ankle_angle_inf)); % <----- may or may not need to transpose data for finding mean.
knee_infAvg = mean(cell2mat(knee_angle_inf));
hip_infAvg = mean(cell2mat(hip_angle_inf));

ankle_inf = [];% ankle_inf = ankle_infAvg;
knee_inf = []; %knee_inf = knee_infAvg;
hip_inf = []; %hip_inf = hip_infAvg;
for i = 1:numCyclesBefore
    ankle_inf = [ankle_inf, ankle_infAvg];
    knee_inf = [knee_inf, knee_infAvg];
    hip_inf = [hip_inf, hip_infAvg];
end

ankle_inf = [ankle_inf, ankle_infAvg];
knee_inf = [knee_inf, knee_infAvg];
hip_inf = [hip_inf, hip_infAvg];

for i = 1:numCyclesAfter
    ankle_inf = [ankle_inf, ankle_infAvg];
    knee_inf = [knee_inf, knee_infAvg];
    hip_inf = [hip_inf, hip_infAvg];
end

%% find perturbation sections

% <----- change to 3 for your experiment
clear type_w_inds
type_w_inds = cell(3,1);

% same idea as for inf cycles but for 9 different types of perturbations
% for i = 1:length(heel_strike_ind) - num_cycles_to_view_inf;
%     range = heel_strike_ind(i) : heel_strike_ind(i+num_cycles_to_view_inf);
%     inds = range;
%     if ~isempty(find(perturb(inds) == 1, 1)) && ~isempty(find(Kd(inds) == 6e4, 1))
%         if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
%             type_w_inds{1}{end+1} = heel_strike_ind(i):heel_strike_ind(i+num_cycles_to_view_inf);
%         end
%     elseif ~isempty(find(perturb(inds) == 2, 1)) && ~isempty(find(Kd(inds) == 1e6, 1))
%         if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
%             type_w_inds{2}{end+1} = heel_strike_ind(i):heel_strike_ind(i+num_cycles_to_view_inf);
%         end
%     elseif ~isempty(find(perturb(inds) == 3, 1)) && ~isempty(find(Kd(inds) == 6e4, 1))
%         display('Type 1 & stiffness changed');
%         if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
%             type_w_inds{3}{end+1} = heel_strike_ind(i):heel_strike_ind(i+num_cycles_to_view_inf);
%             display('Added');
%         end
%     end
%     clear range_past
%     range_past = range(end);
%     clear range inds
% end

num_types_perts = 3; % 9 different perturbation types (3 locations, 3 magnitudes)


%% NEED TO FIND OUT WHY the +2 / +3 works for the number of cycles
for cycle = 1+numCyclesBefore : length(heel_strike_ind) - numCyclesAfter-1
    hsInd = heel_strike_ind(cycle);
    if perturb(hsInd) == 1 && Kd(hsInd) == 6e4
        type_w_inds{1}{end+1} = heel_strike_ind(cycle - numCyclesBefore) : heel_strike_ind(cycle + 2 + numCyclesAfter);
    elseif perturb(hsInd) == 2 && Kd(hsInd) == 1e6
        type_w_inds{2}{end+1} = heel_strike_ind(cycle - numCyclesBefore) : heel_strike_ind(cycle + 2 + numCyclesAfter);
    elseif perturb(hsInd) == 3 && Kd(hsInd) == 6e4
        type_w_inds{3}{end+1} = heel_strike_ind(cycle - numCyclesBefore) : heel_strike_ind(cycle + 3 + numCyclesAfter);
    end
end

num_norm_perts = length(type_w_inds{1});
num_type0_perts = length(type_w_inds{2});
num_type1_perts = length(type_w_inds{3});

disp(['Number of normal perturbations: ', num2str(num_norm_perts)]);
disp(['Number of type zero perturbations: ', num2str(num_type0_perts)]);
disp(['Number of type one perturbations: ', num2str(num_type1_perts)]);

%%

%clear ankle_angle knee_angle hip_angle
for i = 1:num_types_perts
    for j = 1:length(type_w_inds{i})
        
        data = type_w_inds{i}{j};
                       
        y_ankle = theta_ankle(data).*180./pi;
        y_knee = theta_knee(data).*180./pi;
        y_hip = theta_hip(data).*180./pi;
        
        x = numCyclesPlot*100*(data - min(data)) / ( max(data) - min(data) ) - 100*numCyclesBefore;
       
        ankle_angle{i}{j} = spline(x,y_ankle,pgc);
        knee_angle{i}{j} = spline(x,y_knee,pgc);
        hip_angle{i}{j} = spline(x,y_hip,pgc);
        
        clear y_ankle y_knee y_hip data 
    end
end

clear ankle knee hip
% <-------- again may or may not need transpose
for i = 1:num_types_perts
    ankle{i} = mean(cell2mat(ankle_angle{i}')); % Note: transpose important for correct calculations.
    knee{i} = mean(cell2mat(knee_angle{i}'));
    hip{i} = mean(cell2mat(hip_angle{i}'));
end

ankle{4} = ankle_inf;
knee{4} = knee_inf;
hip{4} = hip_inf;

%% plot
%figure(1); clf;
%suptitle({'Leg Kinematics:';['Ankle   ',num2str(bws),' % BWS']})

yval = -10;
yval2 = .01;
bws_amount = {'10','20','30'};
HS = 'HS';
TO = 'TO';
type = {'mean','std'};
loc = {'Heel Strike Pert','Mid Stance Pert','Toe Off Pert'};
stiff = {'10k (N/m)','50k (N/m)','100k (N/m)'};
jointStr = {'Ankle','Knee','Hip'};

yAxisLow = [-15, -50, -15];
yAxisHigh = [10, 15, 20];
yval2 = -15;
joints = {ankle,knee,hip};

for j=1:3
    
    
    figs(j) = figure(j);
    
    plot(pgc,joints{j}{4},'k--','LineWidth',2); hold all;
    for i=1:2
        plot(pgc,joints{j}{i},'LineWidth',2);
    end
    hold off;
    legend('Normal','Regular Perturbation','Type 0 Pert','Location','SouthWest');
    
    bigText{1} = title(jointStr{j});
    bigText{2} = xlabel('Progress through gait cycle (%)');
    bigText{3} = ylabel([jointStr{j} ' angle (degrees)']);
    
    axis_d = [-100*numCyclesBefore, 100*(1+numCyclesAfter), yAxisLow(j), yAxisHigh(j)];
    
    axis(axis_d);
    
    startCycle = -numCyclesBefore;
    for i = startCycle:1+numCyclesAfter
        hx = graph2d.constantline(100*i, 'LineStyle',':','color',[.7,.7,.7]);
        changedependvar(hx,'x');
    end
%     hx1=graph2d.constantline(100, 'LineStyle',':', 'Color',[.7 .7 .7]);
%     hx2=graph2d.constantline(200, 'LineStyle',':');
%     changedependvar(hx1,'x');
%     changedependvar(hx2,'x');
%     hx3=graph2d.constantline(65, 'LineStyle',':', 'Color',[.7 .7 .7]);
%     hx4=graph2d.constantline(165, 'LineStyle',':');
%     hx5=graph2d.constantline(265, 'LineStyle',':');
% 
%     changedependvar(hx3,'x');
%     changedependvar(hx4,'x');
%     changedependvar(hx5,'x');
%     
    %# horizontal line
    hy = graph2d.constantline(0, 'LineStyle',':', 'Color',[.7 .7 .7]);
    changedependvar(hy,'y');
    
    
    HSTOheight = yAxisLow(j) + 2.5;
    
%     bigText{4} = text(100,HSTOheight,HS);
%     bigText{5} = text(65,HSTOheight,TO);
    
    for iter = 1:3
        set(bigText{iter},'fontSize',12,'fontWeight','bold')
    end
    
    disp([jointStr{j} ' plotted']);
end


savefig(figs,'JustinKinFigs.fig');





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
%      text(100,yval,HS);
%      text(200,yval,HS);
%      text(65,yval,TO);
%      text(165,yval,TO);
%      text(265,yval,TO);


