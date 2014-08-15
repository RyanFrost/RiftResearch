classdef GaitCycle < dlnode
    properties
        cycleNum;
        startTime;
        indices;
        perturbType;

        
        footPos;
        anglesRaw;
        
    end
    

    methods
        function cyc = GaitCycle(cycleNumber,cycleStartTime,cycleIndices,perturbStatus,footPositions,anglesArray)
            
            cyc.startTime = cycleStartTime;
            cyc.cycleNum = cycleNumber;
            cyc.perturbType = perturbStatus;
            cyc.indices = cycleIndices';
            cyc.footPos = footPositions;
            cyc.anglesRaw = anglesArray;
            
            
            
            cyc.anglesRaw(cyc.anglesRaw > 100 | cyc.anglesRaw < -100) = NaN;
            
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