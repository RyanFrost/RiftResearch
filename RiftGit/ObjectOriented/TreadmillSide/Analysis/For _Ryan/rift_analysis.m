%%
% Code to create transfer function of change in Emg over stiffness input
%-------------------------------------------------------------------------
clear all;
%close all;
clc;

%% Load in data from .txt files

%---( Match w/ file )---------
bws = 30;
subject = 'jeremy';

%% Variables to change
% overall
delayStart = 20; % where trim data [% gait cycle]
delayEnd = 45; % where trim data [% gait cycle]
nk = 0; % samples to delay output in modeling



A = load('erinData_8-1-14.txt'); % main data
%B = load('erinEmg_8-1-14.emg'); % EMG data

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
hipAngleLeft = A(:,18);
kneeAngleLeft = A(:,19);
ankleAngleLeft = A(:,20);
hipAngleRight = A(:,21);
kneeAngleRight = A(:,22);
ankleAngleRight = A(:,23);
xf = A(:,24);

distance = A(:,27);
currentPatch = A(:,28);
patchType = A(:,29);


lineNum = 1:length(xf);

time = VSTtime - zeroTime; % Zero time when EMG begins

tspeedMax = max( tspeed_d );
maxSpeedIndUp = find( tspeed_d == tspeedMax, 1, 'first'); % First sample at max treadmill speed
maxSpeedIndDown = find( tspeed_d == tspeedMax, 1, 'last'); % Last sample at max treadmill speed


%% Break into gait cycles
% Unilateral leg!!

% find minimums of xf
% close to heel strike
Data = xf;
Data(Data>110 | Data < -10) = NaN;
Data(tspeed_d < tspeedMax ) = NaN;
[Maxima,MaxIdx] = findpeaks(Data,'MINPEAKDISTANCE',30,'MINPEAKHEIGHT',mean(Data)+10);
DataInv = 1.01*max(Data) - Data;
[~,MinIdx] = findpeaks(DataInv,'MINPEAKDISTANCE',30,'MINPEAKHEIGHT',mean(DataInv)+10);
Minima = Data(MinIdx);

heelStrikeInd = MinIdx; % indices where HS occurs

% Don't include data before up to speed + a couple cycles
num2remove = find(heelStrikeInd < maxSpeedIndUp,1,'last') + 2;
heelStrikeInd( 1 : num2remove ) = [ ];
% Don't include data after coming down from speed
startSlowDown = find( heelStrikeInd > maxSpeedIndDown, 1, 'first' );
heelStrikeInd(startSlowDown:end) = [ ];

aveSamplesPerGaitCycle = mean(diff(heelStrikeInd));

%% Check heel Strike indices
% figure(1);clf;
% plot(xf); hold on;
% plot(heelStrikeInd,xf(heelStrikeInd),'g*');
% plot(50*perturb,'r');

%% find infinite sections
cycles2view = 1; % how many consectuive cycles of data do you want saved?
count = 1;
rangePast = heelStrikeInd(1) : heelStrikeInd(1 + cycles2view);
for i = 1:length(heelStrikeInd) - cycles2view;
    range = heelStrikeInd(i) : heelStrikeInd(i + cycles2view);
    if isempty( find( perturb(range) > 0,1,'first') ) % no perturbation during this cycle
        if isempty( find( perturb(rangePast) > 0 , 1, 'first') ) % no perturbation right before
            %if count < 50
            inf_inds{count}(1) = range(1);
            inf_inds{count}(2) = range(end);
            count = count + 1;
            %end
        end
    end
    rangePast = range;
end



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



%% find perturbation sections

clear type_w_inds
type_w_inds = cell(10,1);

for i = 1:length(heelStrikeInd) - cycles2view;
    range = heelStrikeInd(i) : heelStrikeInd(i+cycles2view);
    inds = range;
    if ~isempty(find(perturb(inds) == 1, 1)) && ~isempty(find(Kd(inds) == 1e4, 1))
        if isempty( find( perturb(rangePast) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{1}{end+1} = heelStrikeInd(i):heelStrikeInd(i+cycles2view);
        end
    elseif ~isempty(find(perturb(inds) == 2, 1)) && ~isempty(find(Kd(inds) == 1e4, 1))
        if isempty( find( perturb(rangePast) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{2}{end+1} = heelStrikeInd(i):heelStrikeInd(i+cycles2view);
        end
    elseif ~isempty(find(perturb(inds) == 3, 1)) && ~isempty(find(Kd(inds) == 1e4, 1))
        if isempty( find( perturb(rangePast) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{3}{end+1} = heelStrikeInd(i):heelStrikeInd(i+cycles2view);
        end
    elseif ~isempty(find(perturb(inds) == 1, 1)) && ~isempty(find(Kd(inds) == 5e4, 1))
        if isempty( find( perturb(rangePast) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{4}{end+1} = heelStrikeInd(i):heelStrikeInd(i+cycles2view);
        end
    elseif ~isempty(find(perturb(inds) == 2, 1)) && ~isempty(find(Kd(inds) == 5e4, 1))
        if isempty( find( perturb(rangePast) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{5}{end+1} = heelStrikeInd(i):heelStrikeInd(i+cycles2view);
        end
    elseif ~isempty(find(perturb(inds) == 3, 1)) && ~isempty(find(Kd(inds) == 5e4, 1))
        if isempty( find( perturb(rangePast) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{6}{end+1} = heelStrikeInd(i):heelStrikeInd(i+cycles2view);
        end
    elseif ~isempty(find(perturb(inds) == 1, 1)) && ~isempty(find(Kd(inds) == 1e5, 1))
        if isempty( find( perturb(rangePast) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{7}{end+1} = heelStrikeInd(i):heelStrikeInd(i+cycles2view);
        end
    elseif ~isempty(find(perturb(inds) == 2, 1)) && ~isempty(find(Kd(inds) == 1e5, 1))
        if isempty( find( perturb(rangePast) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{8}{end+1} = heelStrikeInd(i):heelStrikeInd(i+cycles2view);
        end
    elseif ~isempty(find(perturb(inds) == 3, 1)) && ~isempty(find(Kd(inds) == 1e5, 1))
        if isempty( find( perturb(rangePast) > 0 , 1, 'first') ) % no perturbation right before
            type_w_inds{9}{end+1} = heelStrikeInd(i):heelStrikeInd(i+cycles2view);
        end
    else
    end
    clear range_past
    rangePast = range;
    clear range inds
end

clear temp
temp = type_w_inds;
clear type_w_inds
type_w_inds{1} = temp{1};
type_w_inds{2} = temp{4};
type_w_inds{3} = temp{7};
type_w_inds{4} = inf_inds;
%%

numTypesPerts = 3; % 3 different perturbation types (3 magnitudes)
totalPerts = 0;
for i = 1:numTypesPerts
    totalPerts = totalPerts + length(type_w_inds{i});
end
disp(['Total number of perturbations: ', num2str(totalPerts)]);
%%

for i = 1:numTypesPerts + 1 % for infinite at end
    for j = 1:length(type_w_inds{i})
        startCycleTime = time(type_w_inds{i}{j}(1));
        endCycleTime = time(type_w_inds{i}{j}(end));
        cycleDuration(i,j) = endCycleTime - startCycleTime;
        cycleTimeVals{i}{j}(1) = startCycleTime;
        cycleTimeVals{i}{j}(2) = endCycleTime; 
    end
end

% Find average time per cycle
aveTimePerCycle = mean(nonzeros(cycleDuration));

save([subject,'CycleTimeVals'],'cycleTimeVals');


%% Get EMG at correct times from above

timeEMG = B(:,1);
taRaw   = B(:,2);

% filter parameters
window = .25;
Hz = 2000;
method = 2;

% filter
taFilt  = AmplitudeEstimator( taRaw, window, Hz, method);

% normalize between 0 and 1
taNorm = mat2gray(taFilt);


%% Break into cycles
xx = linspace(0,100,10001);
pgcEMG = xx; % percent gait cycle

for i = 1:4 % number of types of gait cycles (i.e. # of perturbations + 1 for inf)
    for j = 1:length(cycleTimeVals{i}) % number of cycles for each type
                        
        pertTimeBegin = cycleTimeVals{i}{j}(1);
        pertTimeEnd = cycleTimeVals{i}{j}(2);
      
        % find sample at closest time to beginning and end of perturbation cycles
        [y1,beginIndex] = min( abs( timeEMG - pertTimeBegin ) );
        [y2,endIndex] = min( abs( timeEMG - pertTimeEnd ) );
        timingDifference = [y1 y2];
        if mean( timingDifference ) > 0.1
            disp(['Large Timing Difference at: {',num2str(i),'}{',num2str(j),'}']);
            return
        end
                
        % store data as function of percent gait cycle
        taData = taNorm( beginIndex:endIndex );

        temp = beginIndex:endIndex;
        x = 100*(temp - min(temp)) / ( max(temp) - min(temp) );    
        taAct{i}{j} = spline(x,taData,xx);

        clear taData 
        clear temp x
    end
end

%Plot muscle activity
for i = 1:4
    taave{i} = mean(cell2mat(taAct{i}'));
    tastd{i} = std(cell2mat(taAct{i}'));
end

disp('ready to plot full gait cycles');
%return

%% Check
% Select mean or std to plot
% flag = 1 ---> mean
% flag = 2 ---> std
flag = 2;

% Make std transparent??
% transparent = 0 ---> No
% transparent = 2 ---> Yes
transparent = 1;

% When is function being called?
% location = 1 ---> with full length cycles
% location = 2 ---> with trimmed cycles
location = 1;

plot_muscle_activity(pgcEMG,taave,tastd,flag,location,transparent);
disp('Plotted full cycles');
return
%% subtract off baseline (normal) voltages
taInf = mean(cell2mat(taAct{4}')); % Note: transpose important for correct calculations.

% pre allocate
taVdiff = cell( size(taAct));

for i = 1:3
    for j = 1:length(taAct{i})
        taVdiff{i}{j} = taAct{i}{j} - taInf;
    end
end

%% cut off delay
% just front delay
% delay = 20;
% delayInd = find(pgcEMG == delay);
% pgcEMG(1:delayInd) = [];
% pgcEMG = pgcEMG - pgcEMG(1); % zero out % gait cycle
% for i = 1:numCyclesTot
%     ta{i}(1:delayInd) = [];
% end

% cut to section
% delayStart = 15;
% delayEnd = 55;
delayInd1 = find(pgcEMG == delayStart);
delayInd2 = find(pgcEMG == delayEnd);

xx = linspace(0,100,10001);
pgcEMG = xx;
pgcEMG(delayInd2:end) = [];
pgcEMG(1:delayInd1) = [];
pgcEMG = pgcEMG - pgcEMG(1); % zero out % gait cycle

taInf(delayInd2:end) = [];
taInf(1:delayInd1) = [];

for i = 1:3
    for j = 1:length(taVdiff{i})
        taVdiff{i}{j}(delayInd2:end) = [];
        taVdiff{i}{j}(1:delayInd1) = [];
    end
end

for i = 1:4
    for j = 1:length(taAct{i})
        taAct{i}{j}(delayInd2:end) = [];
        taAct{i}{j}(1:delayInd1) = [];
    end
end


% each cycle with mean
for i = 1:3
    taVdiffave{i} = mean(cell2mat(taVdiff{i}'));
    taVdiffstd{i} = std(cell2mat(taVdiff{i}'));
end

% each cycle with mean
for i = 1:4
    taave{i} = mean(cell2mat(taAct{i}'));
    tastd{i} = std(cell2mat(taAct{i}'));
end

%% Look at individual cycles
val = 1;
figure(2); clf;
hold all;
for i = 1:length(taAct{val})
    plot(taAct{val}{i});
end
title('TA inf stiffness')
%%

% find correlation coeficient
rValues = cell(3,1);
for i = 1:3
    for j = 1:length(taAct{i})
        R = corrcoef(taAct{i}{j},taave{i});
        rValues{i}(end+1) = R(1,2);
    end
end
%


% rank r-values
for i = 1:3
    orderedRvalues{i} = sort(rValues{i});
end

disp('Find thresholds for outliers')
return
%% Find thresholds for cut offs
% orderedRvalues{i}
% thresh1 = .85;
% thresh2 = .8;
% thresh3 = .7;
thresh = [thresh1 thresh2 thresh3];

%%
stiff = 3;
rValues{stiff}
cycle = 1;
figure(79); clf;
hold all;
for i = 1:length(taAct{stiff})
    plot(taAct{stiff}{i})
    plot(taAct{stiff}{cycle},'k','LineWidth',2);
    plot(taave{stiff},'r','LineWidth',2);
end

%%

outliers = cell(3,1);
for i = 1:3
    outliers{i} = find(rValues{i} < thresh(i) );
end

if  strcmp(subject,'josh')
    outliers{1} = [1 12];
    outliers{3} = [1 2 3 5 10 11];
end

numOutliersTot = 0;
for i = 1:3
    for j = 1:length(outliers{i})
        numOutliersTot = numOutliersTot + 1;
    end
    numOutliersEachPert(i) = j;
end

disp(['Total number of outliers: ',num2str(numOutliersTot)]);

%%
% pre allocate
ta = cell(size(taAct));

numCyclesTot = 0;
for i = 1:3
    for j = 1:length(taAct{i})
        numCyclesTot = numCyclesTot + 1;
        ta{numCyclesTot} = taAct{i}{j} - taInf;
    end
    numCyclesEachPert(i) = j;
end



%% find when outliers occur in ta

clear outliers2remove
outliers2remove( 1:numOutliersEachPert(1) ) = outliers{1};
numCyclesEachPertAdded = numCyclesEachPert;

for i = 2:3;
    numCyclesEachPertAdded(i) = numCyclesEachPertAdded(i-1) + numCyclesEachPert(i);
    for j = 1:length(outliers{i})
        outliers2remove(end+1) = numCyclesEachPertAdded(i-1) + outliers{i}(j);
    end
end

%% Delete outliers 
for i = length(outliers2remove) : -1 : 1 % Important: remove higher indexes first
    ta(outliers2remove(i)) = [];
end

%% Save data
save([subject,'TA'],'ta','taave','taAct','taVdiff','pgcEMG');

disp('data saved to .mat')

%% Subtract off outliers from numbers
for i = 1:3
    numCyclesEachPert(i) = numCyclesEachPert(i) - numOutliersEachPert(i);
end
numCyclesTot = sum(numCyclesEachPert);

disp('Deleted the outliers')

%% plot shorter cycles w/o outliers
location = 2;
flag = 1;
transparent = 0;

plot_muscle_activity(pgcEMG,taave,tastd,flag,location,transparent);
disp('Plotted shorter cycles w/o outliers');
%return

%% Make input signals
perturbation = ones(size(pgcEMG));

% Find stiffness values
%cursor_info.Position;
%cursor_info(1).Position(2) - cursor_info(4).Position(2) 

% stiffnessVals = [.0959 .0578  .0275];
mag = cell(numCyclesTot,1);

for i = 1:numCyclesTot
    if i <= numCyclesEachPert(1)
        mag{i} = stiffnessVals(1)*perturbation;
    elseif i <= sum(numCyclesEachPert(1:2))
        mag{i} = stiffnessVals(2)*perturbation;
    else
        mag{i} = stiffnessVals(3)*perturbation;
    end
end

