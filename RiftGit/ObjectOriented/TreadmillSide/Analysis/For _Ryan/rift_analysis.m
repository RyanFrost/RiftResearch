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

movingForward = A(:,26);
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
Data = kneeAngleLeft;
nanInd = find(Data>110 | Data < -100);
Data(nanInd) = NaN;
Data(tspeed_d < tspeedMax ) = NaN;


changes = diff(movingForward);
hsInd = find(changes<0);

[Maxima,MaxIdx] = findpeaks(Data,'MINPEAKDISTANCE',30,'MINPEAKHEIGHT',nanmean(Data)+10);
DataInv = 1.01*max(Data) - Data;
[~,MinIdx] = findpeaks(DataInv,'MINPEAKDISTANCE',30,'MINPEAKHEIGHT',nanmean(DataInv)+10);
Minima = Data(MinIdx);

heelStrikeInd = hsInd;%MinIdx; % indices where HS occurs

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


numCyclesBefore = 1;
numCyclesAfter = 1;
numCyclesPlot = numCyclesBefore+numCyclesAfter+1;
num_cycles_to_view_inf = numCyclesPlot;
count = 1;
range_past = heelStrikeInd(1) : heelStrikeInd(1+num_cycles_to_view_inf); 
for i = 1+numCyclesBefore:length(heelStrikeInd) - numCyclesAfter-1;
    range = heelStrikeInd(i-numCyclesBefore) : heelStrikeInd(i+1+numCyclesAfter); % take 1 gait cycle
    if isempty( find( perturb(range) > 0,1,'first') ) % no perturbation during this cycle
        if isempty( find( perturb(range_past) > 0 , 1, 'first') ) % no perturbation right before
            inf_inds{count}(1) = heelStrikeInd(i);
            inf_inds{count}(2) = heelStrikeInd(i+1);
            count = count + 1;
        end
    end
    range_past = range;
end

num_inf_cycs = count - 1;
ankleAngleInf = cell(num_inf_cycs,1);
kneeAngleInf = cell(num_inf_cycs,1);
hipAngleInf = cell(num_inf_cycs,1);
xx = linspace(0-numCyclesBefore*100, (1+numCyclesAfter)*100,1000 );
xx = linspace(0, 100,1000 );
pgc = xx; % percent gait cycle
pgc = linspace(0-numCyclesBefore*100, (1+numCyclesAfter)*100,num_cycles_to_view_inf*1000 );

clear infplots;

for i = 1+numCyclesBefore:num_inf_cycs-numCyclesAfter-1
    ind1 = inf_inds{i}(1);
    ind2 = inf_inds{i}(2);

    y_ankle = ankleAngleLeft(ind1:ind2);
    longestAnkleNaN = max(diff(find([1,diff(y_ankle'),1])));
    y_knee = kneeAngleLeft(ind1:ind2);
    longestKneeNaN = max(diff(find([1,diff(y_knee'),1])));
    y_hip = hipAngleLeft(ind1:ind2);
    longestHipNaN = max(diff(find([1,diff(y_hip'),1])));
    
    longestVec = [longestAnkleNaN, longestKneeNaN, longestHipNaN];
    cutoff = 3;
    
    if ( all(longestVec < cutoff) )
    
        % normalize each cycle over gait cycle
        temp = ind1:ind2;
        x = 100*(temp - min(temp)) / ( max(temp) - min(temp) );
        ankleAngleInf{i} = spline(x,y_ankle,xx);
        kneeAngleInf{i} = spline(x,y_knee,xx);
        hipAngleInf{i} = spline(x,y_hip,xx);
        %infplots(i)=plot(ankleAngleInf{i},'DisplayName',num2str(ind1));hold on;
    end
    clear y_ankle y_knee y_hip

end
%return
hold off;

ankleAngleInfAvg = mean(cell2mat(ankleAngleInf)); % <----- may or may not need to transpose data for finding mean.
ankleAngleInfStd = std(cell2mat(ankleAngleInf));
kneeAngleInfAvg = mean(cell2mat(kneeAngleInf));
kneeAngleInfStd = std(cell2mat(kneeAngleInf));
hipAngleInfAvg = mean(cell2mat(hipAngleInf));
hipAngleInfStd = std(cell2mat(hipAngleInf));

anklePlotInf = [];% ankleAngleInf = ankleAngleInfAvg;
kneePlotInf = []; %kneeAngleInf = kneeAngleInfAvg;
hipPlotInf = []; %hipAngleInf = hipAngleInfAvg;
ankleStd = [];
kneeStd = [];
hipStd = [];

for i = 1:(numCyclesBefore+1+numCyclesAfter)
    anklePlotInf = [anklePlotInf, ankleAngleInfAvg];
    ankleStd = [ankleStd, ankleAngleInfStd];
    kneePlotInf = [kneePlotInf, kneeAngleInfAvg];
    kneeStd = [kneeStd, kneeAngleInfStd];
    hipPlotInf = [hipPlotInf, hipAngleInfAvg];
    hipStd = [hipStd, hipAngleInfStd];
end


%% find perturbation sections

type_w_inds = cell(3,1);
for cycle = 1+numCyclesBefore : length(heelStrikeInd) - numCyclesAfter -2
    hsInd = heelStrikeInd(cycle);
        
    noPertRange = [heelStrikeInd(cycle-numCyclesBefore:cycle-1);heelStrikeInd(cycle+1:cycle+numCyclesAfter+2)];
    
    if perturb(hsInd+1) == 1 
        
        type_w_inds{1}{end+1} = heelStrikeInd(cycle - numCyclesBefore) : heelStrikeInd(cycle + 1 + numCyclesAfter);
    
    elseif perturb(hsInd+1) == 2 
        
        type_w_inds{2}{end+1} = heelStrikeInd(cycle - numCyclesBefore) : heelStrikeInd(cycle + 1 + numCyclesAfter);
    
    elseif perturb(hsInd+1) == 3 
        
        type_w_inds{3}{end+1} = heelStrikeInd(cycle - numCyclesBefore) : heelStrikeInd(cycle + 1 +numCyclesAfter);
    
    end
end

num_norm_perts = length(type_w_inds{1});
num_type0_perts = length(type_w_inds{2});
num_type1_perts = length(type_w_inds{3});


disp(['Number of normal perturbations: ', num2str(num_norm_perts)]);
disp(['Number of type zero perturbations: ', num2str(num_type0_perts)]);
disp(['Number of type one perturbations: ', num2str(num_type1_perts)]);

num_types_perts = 3;


for i = 1:num_types_perts
    figure(i+5)
    for j = 1:length(type_w_inds{i})
        
        data = type_w_inds{i}{j};
                       
        y_ankle = ankleAngleLeft(data);
        longestAnkleNaN = max(diff(find([1,diff(y_ankle'),1])));
        y_knee = kneeAngleLeft(data);
        longestKneeNaN = max(diff(find([1,diff(y_knee'),1])));
        y_hip = hipAngleLeft(data);
        longestHipNaN = max(diff(find([1,diff(y_hip'),1])));

        
        longestVec = [longestAnkleNaN, longestKneeNaN, longestHipNaN];
        cutoff = 10;
        
        if ( all(longestVec < cutoff) )
            x = numCyclesPlot*100*(data - min(data)) / ( max(data) - min(data) ) - 100*numCyclesBefore;
       
            ankleAngle{i}{j} = spline(x,y_ankle,pgc);
            kneeAngle{i}{j} = spline(x,y_knee,pgc);
            hipAngle{i}{j} = spline(x,y_hip,pgc);
        
            anklePlots(j) = plot(ankleAngle{i}{j},'DisplayName',num2str(data(1)));hold on;    
            
        end
        
    end
    
    clear y_ankle y_knee y_hip data
end
hold off;
clear ankle knee hip







for i = 1:3
    i
    ankle{i}(1,:) = mean(cell2mat(ankleAngle{i}')); % Note: transpose important for correct calculations.
    ankle{i}(2,:) = std(cell2mat(ankleAngle{i}'));
    knee{i}(1,:) = mean(cell2mat(kneeAngle{i}'));
    knee{i}(2,:) = std(cell2mat(kneeAngle{i}'));
    hip{i}(1,:) = mean(cell2mat(hipAngle{i}'));
    hip{i}(2,:) = std(cell2mat(hipAngle{i}'));
end



ankle{4} = [anklePlotInf; ankleStd];
knee{4} = [kneePlotInf; kneeStd];
hip{4} = [hipPlotInf; hipStd];



yval = -10;
yval2 = .01;
bws_amount = {'10','20','30'};
HS = 'HS';
TO = 'TO';
type = {'mean','std'};
loc = {'Heel Strike Pert','Mid Stance Pert','Toe Off Pert'};
stiff = {'10k (N/m)','50k (N/m)','100k (N/m)'};
jointStr = {'Ankle','Knee','Hip'};

yAxisLow = [-30, -15, -15];
yAxisHigh = [10, 60, 20];
yval2 = -15;
joints = {ankle,knee,hip};

colors = [1, 0, 0; 0, 0, 1; 0, .4, 0];


% Inline function for shading std dev
plotVariance = @(x,lower,upper,color) set(fill([x,x(end:-1:1)],[upper,lower(end:-1:1)],color),'FaceAlpha',0.4);


for j=1
    
    
    figs(j) = figure(j+1);
    
    
    mean = joints{j}{4}(1,:);
    stdev = joints{j}{4}(2,:);

    top = mean+stdev;
    bottom = mean-stdev;
    
    
    meanPlots(1) = plot(pgc,mean,'k--','LineWidth',2); hold on;
%     plot(pgc,top,'k','LineWidth',1,'LineStyle','-');
%     plot(pgc,bottom,'k','LineWidth',1,'LineStyle','-');
    
    plotVariance(pgc,bottom,top,[0,0,0]);
    
    for i=[1,3]
        
        mean = joints{j}{i}(1,:);
        stdev = joints{j}{i}(2,:);

        top = mean+stdev;
        bottom = mean-stdev;
        
        meanPlots(i+1) = plot(pgc,mean,'Color',colors(i,:),'LineWidth',2);
%         plot(pgc,top,'Color',colors(i,:),'LineWidth',1,'LineStyle','-');
%         plot(pgc,bottom,'Color',colors(i,:),'LineWidth',1,'LineStyle','-');
        
        plotVariance(pgc,bottom,top,colors(i,:));
        
    end
    hold off;
    legend(meanPlots,'Unperturbed Gait','Regular Perturbation','Visual Warning, No Perturbation','Location','SouthWest');
    
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
    % horizontal line
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


%savefig(figs,'JustinKinFigs.fig');
figure;
plotyy(lineNum,Data,lineNum,perturb); hold on;
for i = 1:length(heelStrikeInd)
    plot([heelStrikeInd(i), heelStrikeInd(i)], [10,70],'-k');
end
for i = 1:length(nanInd)
    plot([nanInd(i), nanInd(i)], [10,70],'-r');
end
hold off;





return;


















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

