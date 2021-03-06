classdef GaitCycle < dlnode
    properties
        cycleNum;
        timeVec;
        duration;
        indices;
        numSamples;
        perturbType;
        distance;
        movingBacks;
        
        footPos;
        anglesRaw;
        
    end
    

    methods
        function cyc = GaitCycle(cycleNumber,cycleTimes,cycleIndices,perturbStatus,footPositions,anglesArray,distanceToPatchOnHeelstrike,movingBack)
            
            cyc.timeVec = cycleTimes;
            cyc.duration = cyc.timeVec(end)-cyc.timeVec(1);
            cyc.cycleNum = cycleNumber;
            cyc.perturbType = perturbStatus;
            cyc.indices = cycleIndices';
            cyc.numSamples = length(cyc.indices);
            cyc.distance = distanceToPatchOnHeelstrike;
            cyc.footPos = footPositions;
            cyc.anglesRaw = anglesArray;
            cyc.movingBacks = movingBack;
            
            
            inds = find(cyc.anglesRaw > 100 | cyc.anglesRaw < -100 | abs(cyc.anglesRaw-12.54)<0.01);
            
            if ~isempty(inds)
            
                for i = 1:length(inds)
                    if inds(i) == 1
                        cyc.anglesRaw(inds(i)) = cyc.anglesRaw(inds(i)+1);
                    else
                        cyc.anglesRaw(inds(i)) = cyc.anglesRaw(inds(i)-1);
                    end
                end
            end
            
            cyc.anglesRaw(:,7) = sum(cyc.anglesRaw(:,1:3),2);
            cyc.anglesRaw(:,8) = sum(cyc.anglesRaw(:,4:6),2);
            
        end
        
        
        
        
    end
    
    methods (Access = private)
        function cyc = loadRawAngles(cyc,anglesArray)
            
            cyc.anglesRaw = anglesArray;
            
%             cyc.anglesRaw.ankleL = anglesArray(:,3);
%             cyc.anglesRaw.kneeL = anglesArray(:,2);
%             cyc.anglesRaw.hipL = anglesArray(:,1);
%             
%             cyc.anglesRaw.ankleR = anglesArray(:,6);
%             cyc.anglesRaw.kneeR = anglesArray(:,5);
%             cyc.anglesRaw.hipR = anglesArray(:,4);
            
            % = cyc.upsampleAngles();
        end
        
        
        function cyc = upsampleAngles(cyc)
            
            xx = linspace(0,100,1000);
             
            
            x = linspace(0,100,length(cyc.indices));
            
            
            cyc.angles = spline(x,cyc.anglesRaw',xx);
            
            
%             cyc.angles.ankleL = anglesUpsampled(3,:);
%             cyc.angles.kneeL = anglesUpsampled(2,:);
%             cyc.angles.hipL = anglesUpsampled(1,:);
%             cyc.angles.ankleR = anglesUpsampled(6,:);
%             cyc.angles.kneeR = anglesUpsampled(5,:);
%             cyc.angles.hipR = anglesUpsampled(4,:);
            
%             
%             cyc.angles.ankleL = spline(1:length(cyc.anglesRaw.ankleL),cyc.anglesRaw.ankleL,xx);
%             cyc.angles.kneeL = spline(1:length(cyc.anglesRaw.kneeL),cyc.anglesRaw.kneeL,xx);
%             cyc.angles.hipL = spline(1:length(cyc.anglesRaw.hipL),cyc.anglesRaw.hipL,xx);
%             cyc.angles.ankleR = spline(1:length(cyc.anglesRaw.ankleR),cyc.anglesRaw.ankleR,xx);
%             cyc.angles.kneeR = spline(1:length(cyc.anglesRaw.kneeR),cyc.anglesRaw.kneeR,xx);
%             cyc.angles.hipR = spline(1:length(cyc.anglesRaw.hipR),cyc.anglesRaw.hipR,xx);

            
        end
        
    end

end