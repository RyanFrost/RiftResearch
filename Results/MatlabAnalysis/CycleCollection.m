classdef CycleCollection
    
    
    properties
        anglesRaw;
        angles;
        angVelocityRaw;
        angVelocity;
        timeVec;
        footPos;
        cycArray = GaitCycle.empty;
        mainCycNum;   % cycle number of the cycle being looked at
        perturbType;
        distance;
        numCycs;
        isPlottable = 1;
        
        toeOffLocsLeft;
        toeOffLocsRight;
        heelStrikeLocsLeft;
        heelStrikeLocsRight;
        
        
    end
    
    methods
        function cycs = CycleCollection(cycle,cyclesBefore,cyclesAfter,totalCyclesInExperiment)
            
            %outlierArray = [22, 98, 506, 613, 657, 584, 387]; % John's
            
            %outlierArray = [202,203,204,207,445,439,235,236,149,150,155,156,171,177,178,179,496,497,453,454,191,193,119,364,271,275,127,548,550,573,565,499];  % Andrew's
            
            cycs = cycs.createCycArray(cycle,totalCyclesInExperiment,cyclesBefore,cyclesAfter);
            %cycs = cycs.checkOutlier(outlierArray);
            
            if cycs.isPlottable == 0
                return
            end
            
            
            cycs.anglesRaw = [];
            cycs.timeVec = [];
            cycs.footPos = [];
            movingBack = [];
            
            
            
            for i = 1:length(cycs.cycArray)
                cycs.anglesRaw = [cycs.anglesRaw; cycs.cycArray(i).anglesRaw];
                cycs.timeVec = [cycs.timeVec; cycs.cycArray(i).timeVec];
                movingBack = [movingBack; cycs.cycArray(i).movingBacks];
                
                %cycs.footPos = [cycs.footPos; cycs.cycArray(i).footPos];
            end
            
            leftToeOffLocs = [(find(diff(movingBack) < 0))];
            
            
            cycs = cycs.checkNaNs();
            cycs = cycs.checkPert();
            cycs = cycs.checkDistance();
            
            if cycs.isPlottable == 0
                return
            end
            
            % append data for each cycle to the end of the sequence
%             for i = 1:cycs.numCycs
%                 
%                 % if this cycle has lots of NaNs, discard entire cycle
%                 % collection
%                 if currentCycle.lowNaNs == 0
%                     cycs.isPlottable = 0;
%                     break;
%                 end
%                 
%                 
%                 cycs.anglesRaw = [cycs.anglesRaw, currentCycle.anglesRaw];
%                 cycs.footPos = [cycs.footPos, currentCycle.footPos];
%                 if i ~= cycs.numCycs
%                     currentCycle = currentCycle.Next; % advance to next cycle if not at end
%                 end
%             end
            
            
            
            xx = linspace((-100*cyclesBefore),(100*(1+cyclesAfter)),1000*cycs.numCycs);
            
            x = linspace((-100*cyclesBefore),(100*(1+cyclesAfter)),length(vertcat(cycs.cycArray.indices)));
            
            cycs.angles = spline(x,cycs.anglesRaw',xx)';
            for i = 1:8
                angGrad(:,i) = gradient(cycs.anglesRaw(:,i),mean(diff(cycs.timeVec)));
            end
            
            %angDiff
            
            cycs.angVelocityRaw = angGrad;
            cycs.angVelocity = spline(x,cycs.angVelocityRaw',xx)';
            
            [~,cycs.toeOffLocsRight] = max(cycs.angles(:,6));
            [~,cycs.heelStrikeLocsRight] = max(cycs.angles(:,8));
            cycs.toeOffLocsLeft = round(leftToeOffLocs*length(xx)/length(x));
            cycs.heelStrikeLocsLeft = 1:1000:1000*cycs.numCycs;
            
        end
        
        
        
        
    end
    
    
    methods (Access = private)
        function cycs = createCycArray(cycs,startCyc,totalCycs,cyclesBefore,cyclesAfter)
            
            cycle = startCyc;
            cycs.mainCycNum = cycle.cycleNum;
            cycs.perturbType = cycle.perturbType;
            cycs.distance = cycle.distance;
            
            if cycle.cycleNum - cyclesBefore < 2 || cycle.cycleNum + cyclesAfter + 1 > totalCycs
                cycs.isPlottable = 0;
                return;
            end
            
            
            cycs.numCycs = cyclesBefore + 1 + cyclesAfter;
            
            
            currentCycle = cycle;
            
            % navigate to first cycle in sequence
            
            for i = 1:cyclesBefore
                currentCycle = currentCycle.Prev;
            end
            
            % navigate thru cycles and add each to the cycArray
            for i = 1:cycs.numCycs
                cycs.cycArray(i) = currentCycle;
                
                if i ~= cycs.numCycs
                    currentCycle = currentCycle.Next;
                end
            end
            
        end
        
        function cycs = checkNaNs(cycs)
            
            % This finds the longest string of consecutive values that are
            % the same, because when two adjacent values are exactly the
            % same, it's because a marker was missing, so the angle was not
            % updated. If this string is too long, it removes the current
            % cycle collection from the plot.
            
            longestNaN = zeros(1,size(cycs.anglesRaw,2));
            for i = 1:size(cycs.anglesRaw,2)
                longestNaN(i) = max(diff(find([1,diff(cycs.anglesRaw(:,i))',1])));
            end

            if ~ all(longestNaN < 3)
                cycs.isPlottable = 0;
                return;
            end
        
        end
        
        function cycs = checkPert(cycs)
            
            pertArray = [cycs.cycArray(1).Prev,cycs.cycArray,cycs.cycArray(end).Next];
            pertArray = cycs.cycArray;
            pertArray([pertArray.cycleNum] == cycs.mainCycNum) = [];
            if ~all(([pertArray.perturbType]) == 0)
                cycs.isPlottable = 0;
                return;
            end
        end    
        
        function cycs = checkOutlier(cycs, outlierCycleArray)
            
            if ismember(cycs.mainCycNum,outlierCycleArray)
                cycs.isPlottable = 0;
            end
            
        end
        
        function cycs = checkDistance(cycs)
            
            if cycs.perturbType > 0 && cycs.perturbType ~= 3 && (cycs.distance > -0.04 || cycs.distance < -0.8)
                cycs.isPlottable = 0;
                return;
            end
            
        end
        
    end
    
end