classdef CycleCollection
    
    
    properties
        anglesRaw;
        angles;
        footPos;
        cycArray = GaitCycle.empty;
        mainCycNum;   % cycle number of the cycle being looked at
        numCycs;
        isPlottable = 1;
        
        
        
    end
    
    methods
        function cycs = CycleCollection(cycle,cyclesBefore,cyclesAfter,totalCyclesInExperiment)
            
            cycs = cycs.createCycArray(cycle,totalCyclesInExperiment,cyclesBefore,cyclesAfter);
            
            
            if cycs.isPlottable == 0
                return
            end
            
            
            cycs.anglesRaw = [];
            cycs.footPos = [];
            
            
            
            
            for i = 1:length(cycs.cycArray)
                cycs.anglesRaw = [cycs.anglesRaw; cycs.cycArray(i).anglesRaw];
                %cycs.footPos = [cycs.footPos; cycs.cycArray(i).footPos];
            end
            
            cycs = cycs.checkNaNs();
            cycs = cycs.checkPert();
            
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
            
            
            
            
        end
        
        
        
        
    end
    
    
    methods (Access = private)
        function cycs = createCycArray(cycs,startCyc,totalCycs,cyclesBefore,cyclesAfter)
            
            cycle = startCyc;
            cycs.mainCycNum = cycle.cycleNum;
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
            longestNaN = zeros(1,size(cycs.anglesRaw,2));
            for i = 1:size(cycs.anglesRaw,2)
                longestNaN(i) = max(diff(find([1,diff(cycs.anglesRaw(:,i))',1])));
            end

            if ~ all(longestNaN < 2)
                cycs.isPlottable = 0;
                return;
            end
        
        end
        
        function cycs = checkPert(cycs)
            
            pertArray = [cycs.cycArray(1).Prev,cycs.cycArray,cycs.cycArray(end).Next];
            
            pertArray([pertArray.cycleNum] == cycs.mainCycNum) = [];
            if ~all(([pertArray.perturbType]) == 0)
                cycs.isPlottable = 0;
                return;
            end
        end    
        
    end
    
end