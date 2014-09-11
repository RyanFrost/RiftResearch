if exist('cycArray','var')
    cycArray(1).clearList();
end
clear all
close all

load('johnData_8-15-14.mat'); % main data
%load('erinData_8-03-14_2.mat');
%load('andrewData_8-21-14.mat');
%load('carlosData_8-29-14.mat');

lineNum = 1:length(xf);

time = VSTtime - zeroTime; % Zero time when EMG begins

tspeedMax = max( tspeed_d );
if (tspeedMax > 500)
    tspeedMax = 700;
end
maxSpeedIndUp = find( tspeed_d == tspeedMax, 1, 'first'); % First sample at max treadmill speed
maxSpeedIndDown = find( tspeed_d == tspeedMax, 1, 'last'); % Last sample at max treadmill speed


hsChanges = diff(movingForward);
heelStrikeInd = find(hsChanges<0);

toChanges = diff(movingBackward);
toeOffInd = find(toChanges>0);


% % Don't include data before up to speed + a couple cycles
num2remove = find(heelStrikeInd < maxSpeedIndUp,1,'last') + 2;
heelStrikeInd( 1 : num2remove ) = [ ];

% % Don't include data after coming down from speed
startSlowDown = find( heelStrikeInd > maxSpeedIndDown, 1, 'first' );
heelStrikeInd(startSlowDown:end) = [ ];

aveSamplesPerGaitCycle = mean(diff(heelStrikeInd));
cycArray = GaitCycle.empty(length(heelStrikeInd),0);

for i = 1:length(heelStrikeInd)-1
    cycleNumber = i; 
    
    %perturbStatus = perturb(heelStrikeInd(i)+1);
    distanceOnHeelStrike = distance(heelStrikeInd(i));
    indices = heelStrikeInd(i):heelStrikeInd(i+1)-1;
    cycleTimes = time(indices);
    perturbStatus = mode(perturb(indices));
    movingBacks = movingBackward(indices);

    angles = [hipAngleLeft(indices), ...
            kneeAngleLeft(indices), ...
            -ankleAngleLeft(indices), ...
            hipAngleRight(indices), ...
            kneeAngleRight(indices), ...
            -ankleAngleRight(indices)];
    
    cycArray(i) = GaitCycle(cycleNumber,cycleTimes,indices,perturbStatus,xf(indices),angles,distanceOnHeelStrike,movingBacks);
    
end



cycleAnalyzer = CycleAnalyzer(cycArray);




%% Call cycleAnalyzer.plotMeanStd to show the mean with a shaded std dev
% input arguments:  (cyclesBefore,cyclesAfter,perturbationTypes,leg,joint)
% cyclesBefore: number of cycles before the perturbation to plot
% cyclesAfter: number of cycles after " " " "
% perturbationTypes: types of perturbations to plot. 
    % Types:    0 -> unperturbed
    %           1 -> perturbation with visual warning
    %           2 -> visual warning, no perturbation
    %           3 -> perturbation, no visual warning
% leg: which leg to plot data for - can be 'right' or 'left'
% joint: which joint to plot data for - can be 'hip', 'knee', or 'ankle'

figure
cycleAnalyzer.plotMeanStd(0,0,[0,1,2,3],'right','hip');
figure
cycleAnalyzer.plotMeanStd(0,0,[0,1,2,3],'right','knee');
figure
cycleAnalyzer.plotMeanStd(0,0,[0,1,2,3],'right','ankle');


savefig(findobj('Type','figure'),'rightLegPhasePlots.fig');

%% Call cycleAnalyzer.plotRaw to show each individual spline
% input arguments are the same as plotMeanStd


%cycleAnalyzer.plotRaw(1,1,[0,1,3],'left','ankle');





%% Plots all joints for each leg
%{
legStrings = {'left','right'};
jointStrings = {'ankle','knee','hip'};

for leg = 1:length(legStrings)
    
    for joint = 1:length(jointStrings)
        k = 0;
        while k == 0
            k = waitforbuttonpress;
        end
        clf
        cycleAnalyzer.plotMeanStd(1,1,[0,1,2,3],legStrings{leg},jointStrings{joint});
        
        
    end
end
%}







