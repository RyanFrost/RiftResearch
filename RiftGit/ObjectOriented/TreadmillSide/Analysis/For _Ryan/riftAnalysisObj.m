if exist('cycArray','var')
    cycArray(1).clearList();
end
clear all
close all

load('johnData.mat'); % main data
%load('erinKinematics_8-03-14_2.mat');
%load('erinEMG_8-03-14_2.mat'); % EMG data


lineNum = 1:length(xf);

time = VSTtime - zeroTime; % Zero time when EMG begins

tspeedMax = max( tspeed_d );
if (tspeedMax > 500)
    tspeedMax = 700;
end
maxSpeedIndUp = find( tspeed_d == tspeedMax, 1, 'first'); % First sample at max treadmill speed
maxSpeedIndDown = find( tspeed_d == tspeedMax, 1, 'last'); % Last sample at max treadmill speed


changes = diff(movingForward);
heelStrikeInd = find(changes<0);

% Don't include data before up to speed + a couple cycles
num2remove = find(heelStrikeInd < maxSpeedIndUp,1,'last') + 2;
heelStrikeInd( 1 : num2remove ) = [ ];
% Don't include data after coming down from speed
startSlowDown = find( heelStrikeInd > maxSpeedIndDown, 1, 'first' );
heelStrikeInd(startSlowDown:end) = [ ];

aveSamplesPerGaitCycle = mean(diff(heelStrikeInd));
tic;
cycArray = GaitCycle.empty(length(heelStrikeInd),0);

for i = 1:length(heelStrikeInd)-1
    cycleNumber = i; 
    
    cycleStartTime = time(heelStrikeInd(i));
    
    %perturbStatus = perturb(heelStrikeInd(i)+1);
    distanceOnHeelStrike = distance(heelStrikeInd(i));
    indices = heelStrikeInd(i):heelStrikeInd(i+1)-1;
    
    perturbStatus = mode(perturb(indices));
    
    angles = [hipAngleLeft(indices), ...
            kneeAngleLeft(indices), ...
            ankleAngleLeft(indices), ...
            hipAngleRight(indices), ...
            kneeAngleRight(indices), ...
            ankleAngleRight(indices)];
    
    cycArray(i) = GaitCycle(cycleNumber,cycleStartTime,indices,perturbStatus,xf(indices),angles,distanceOnHeelStrike);
    
end
toc;
% length(cycArray)
cycleAnalyzer = CycleAnalyzer(cycArray);
% 
cycleAnalyzer.plotMeanStd(1,1,[0,1,3],'right','hip');
% shg









