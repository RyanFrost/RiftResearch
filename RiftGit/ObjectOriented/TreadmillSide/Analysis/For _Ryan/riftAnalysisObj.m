if exist('cycArray','var')
    cycArray(1).clearList();
end
clear all
figure
close all

%load('johnData_8-15-14.mat'); % main data
%load('erinData_8-03-14_2.mat');
%load('andrewData_8-21-14.mat');
%load('carlosData_8-29-14.mat');
%load('JeremyNewData.mat');
load('erinData3_22_15.mat');
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


%cycleAnalyzer.plotMeanStd(0,0,[0,1,2,3],'right','knee');

 figure
angss = cycleAnalyzer.plotMeanStd(0,0,[0,1,2,3],'right','hip');
%cycleAnalyzer.plotRaw(0,0,[0,1,2,3],'right','knee');
% figure
% cycleAnalyzer.plotMeanStd(0,0,[0,1,2,3],'right','ankle');
% 
% 
% savefig(findobj('Type','figure'),'rightLegPhasePlots.fig');

%% Call cycleAnalyzer.plotRaw to show each individual spline
% input arguments are the same as plotMeanStd


%cycleAnalyzer.plotRaw(1,1,[0,1,3],'left','ankle');





%% Plots all joints for each leg

legStrings = {'left','right'};
jointStrings = {'ankle','knee','hip'};

% for leg = 1:length(legStrings)
%     
%     for joint = 1:length(jointStrings)
%         
%         figure
%         ang(:,joint+3*(leg-1)) = cycleAnalyzer.plotMeanStd(1,1,[0,1],legStrings{leg},jointStrings{joint});
%         
%         
%     end
% end

meanAngs=squeeze(angss(1,:,:));
meanAngVels=squeeze(angss(2,:,:));
meanAngs = (meanAngs-min(meanAngs(:)))./(max(meanAngs(:))-min(meanAngs(:)))-0.5;
meanAngVels = (meanAngVels-min(meanAngVels(:)))./(max(meanAngVels(:))-min(meanAngVels(:)))-0.5;
    
for i = 2:4
    %meanAngs(:,i)=(meanAngs(:,i)-min(meanAngs(:,i)))./(max(meanAngs(:,i))-min(meanAngs(:,i)));
    %meanAngVels(:,i)=(meanAngVels(:,i)-min(meanAngVels(:,i)))./(max(meanAngVels(:,i))-min(meanAngVels(:,i)));
    A = [meanAngs(:,i)-meanAngs(:,1),meanAngVels(:,i)-meanAngVels(:,1)];
    s = sum(A.^2,2);
    mag(:,i-1)=sqrt(sum(A.^2,2));
    if (i > 1)
        %dist(:,i-1) = mag(:,i)-mag(:,1);
    end
end


%%
%figure
%plot(linspace(0,mean([cycArray.duration]),1000),mag,'LineWidth',2)
% title('Normalized Phase-Space Distance from Unperturbed', 'FontSize', 24)
% xlabel('Time (s)');
% ylabel('Normalized Distance');
% legend('VP','VO','PO')
% 
%             set(gca,'FontSize',24);
%             set(gcf,'Units','Normalized');
%             set(gcf,'Position', [0.05,0.05,0.8,0.8]);








